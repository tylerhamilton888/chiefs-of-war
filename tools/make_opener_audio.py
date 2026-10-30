from pathlib import Path
import numpy as np,wave
from scipy.signal import butter,sosfilt
r=Path(__file__).resolve().parents[1]/'assets/opener'; rate=22050; rng=np.random.default_rng(37)
def save(name,a):
 a=np.clip(a,-.95,.95)
 with wave.open(str(r/(name+'.wav')),'wb') as f: f.setnchannels(1); f.setsampwidth(2); f.setframerate(rate); f.writeframes((a*32767).astype('<i2').tobytes())
t=np.arange(int(rate*.25))/rate;n=rng.normal(0,.5,len(t));n=sosfilt(butter(2,[300,2800],btype='bandpass',fs=rate,output='sos'),n);save('swing',n*np.sin(np.pi*t/.25)**2*.65)
t=np.arange(int(rate*.7))/rate;a=np.zeros_like(t)
for delay,freq in [(0,146.83),(.08,220),(.16,293.66)]:
 u=np.maximum(t-delay,0);a+=(t>=delay)*np.sin(2*np.pi*freq*u)*np.exp(-u*9)*.13
save('success',a)
t=np.arange(int(rate*.52))/rate;n=sosfilt(butter(2,550,fs=rate,output='sos'),rng.normal(0,.7,len(t)));save('growl',(n*.65+np.sin(2*np.pi*(70*t-12*t*t))*.12)*np.sin(np.pi*t/.52)**.5)
t=np.arange(rate*12)/rate;n=sosfilt(butter(2,[120,1400],btype='bandpass',fs=rate,output='sos'),rng.normal(0,.2,len(t)));env=.2+.1*np.sin(2*np.pi*t/12);a=n*env
for start in [1.8,5.3,9.5]:
 u=t-start;sel=(u>=0)&(u<.22);a[sel]+=.016*np.sin(2*np.pi*(1400*u[sel]+800*u[sel]**2))*np.sin(np.pi*u[sel]/.22)**2
a[:rate//10]*=np.linspace(0,1,rate//10);a[-rate//10:]*=np.linspace(1,0,rate//10);save('ambient',a)
