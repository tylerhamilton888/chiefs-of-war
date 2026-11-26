"""Build the original mono fire, wagon and cooking sounds (NumPy, SciPy, ffmpeg)."""
from pathlib import Path
import subprocess
import tempfile

import numpy as np
from scipy import signal
from scipy.io import wavfile

OUTPUT = Path(__file__).resolve().parents[2] / "assets/audio/hearth"
SR = 24000
RNG = np.random.default_rng(71374)


def clock(seconds):
    return np.arange(round(SR * seconds)) / SR


def noise(n, lo, hi):
    bands = signal.butter(2, [lo, hi], fs=SR, btype="bandpass", output="sos")
    sound = signal.sosfilt(bands, RNG.normal(size=n))
    return sound / np.sqrt(np.mean(sound ** 2))


def pulse(out, at, sound):
    i = round(at * SR)
    n = min(len(sound), len(out) - i)
    out[i:i+n] += sound[:n]


def struck(seconds, modes, attack=0.0012):
    t = clock(seconds)
    sound = np.zeros_like(t)
    for hz, volume, decay in modes:
        sound += volume * np.sin(2 * np.pi * hz * t) * np.exp(-t / decay)
    return sound * np.minimum(t / attack, 1)


def finish(sound, peak=0.84):
    sound *= np.minimum(np.arange(len(sound))[::-1] / 200, 1.0)
    return np.int16(np.clip(sound * (peak / np.max(np.abs(sound))), -1, 1) * 32767)


def hammer(pitch):
    t = clock(0.36)
    body = [(119, .39, .066), (218, .58, .045), (438, .37, .052), (711, .22, .039),
            (1444, .11, .083), (2077, .06, .046)]
    out = struck(.36, [(hz * pitch, amp, decay) for hz, amp, decay in body])
    out += .42 * noise(len(t), 270, 3600) * np.exp(-t / .011) * np.minimum(t / .0007, 1)
    pulse(out, .026, struck(.17, [(1805, .07, .036), (628, .10, .019)]))
    return finish(out)


def spoon(stir):
    out = np.zeros_like(clock(.61 if stir else .77))
    # The spoon drags along one part of the pot, then touches the opposite rim.
    if stir:
        for at, amount, length in [(0.04, 0.29, .24), (.30, .13, .13)]:
            t = clock(length)
            friction = noise(len(t), 420, 1900) * (.7 + .3 * np.sin(2*np.pi*(48*t + 17*t*t)))
            pulse(out, at, amount * friction * np.sin(t * np.pi / length)**1.7)
        pulse(out, .46, struck(.14, [(457, .29, .038), (1272, .26, .042), (2184, .15, .020)]))
    else:
        t = clock(.40)
        pulse(out, .10, .17 * noise(len(t), 300, 1600) * np.sin(t * np.pi / .40)**1.5)
        # Short rising bubble resonances, interspersed through the liquid pour.
        for at in [.12, .146, .185, .258, .32, .413, .51]:
            bt = clock(.065)
            hz = RNG.uniform(370, 790)
            bubble = np.sin(2*np.pi*(hz * bt + 2100 * bt**2)) * np.exp(-bt/.009) * np.minimum(bt/.001, 1)
            pulse(out, at, RNG.uniform(.16, .38) * bubble)
        pulse(out, .54, struck(.18, [(301, .46, .043), (678, .18, .030), (1734, .10, .032)]))
    return finish(out, .77)


def fire():
    seconds = 14.0
    t = clock(seconds)
    # Cyclic slow variations keep the fire breathing across the loop boundary.
    bed = .031 * noise(len(t), 50, 300) + .014 * noise(len(t), 450, 1650)
    out = bed * (1.0 + .29*np.sin(t*2*np.pi/seconds*3) + .14*np.cos(t*2*np.pi/seconds*5))
    for at in np.sort(RNG.uniform(.10, seconds-.25, 164)):
        ct = clock(RNG.uniform(.026, .095))
        decay = RNG.uniform(.004, .018)
        char = noise(len(ct), RNG.uniform(310,560), RNG.uniform(1800,4600))
        amp = .055 + .37 * RNG.random()**3
        pulse(out, at, amp * char * np.exp(-ct/decay) * np.minimum(ct/.0007, 1))
    # Blend the ends of the noise bed instead of cutting to silence each loop.
    cross = int(.12 * SR)
    gain = np.linspace(0, 1, cross)
    out[:cross] = out[-cross:] * (1-gain) + out[:cross] * gain
    out = out[:-cross]
    return np.int16(out / max(abs(out)) * 30100)


if __name__ == "__main__":
    OUTPUT.mkdir(parents=True, exist_ok=True)
    wavfile.write(OUTPUT / "axle_strike.wav", SR, hammer(1.0))
    wavfile.write(OUTPUT / "axle_strike_low.wav", SR, hammer(.92))
    wavfile.write(OUTPUT / "stir.wav", SR, spoon(True))
    wavfile.write(OUTPUT / "serve.wav", SR, spoon(False))
    with tempfile.TemporaryDirectory() as directory:
        source = Path(directory) / "fire.wav"
        wavfile.write(source, SR, fire())
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(source),
                        "-c:a", "libvorbis", "-q:a", "4", str(OUTPUT / "small_fire.ogg")], check=True)
