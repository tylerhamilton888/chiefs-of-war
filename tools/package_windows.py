"""Build and inspect the player-facing Windows ZIP; no source project required."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import struct
import zipfile


def package(exe: Path, output: Path, version: str, source: str) -> Path:
    if not re.fullmatch(r'\d+\.\d+\.\d+', version):
        raise ValueError('Expected a numeric x.y.z release version')
    if not re.fullmatch(r'[0-9a-f]{40}', source):
        raise ValueError('Expected the exact 40-character source commit')
    binary = exe.read_bytes()
    if binary[:2] != b'MZ':
        raise ValueError('ChiefsOfWar.exe is not a Windows executable')
    pe = struct.unpack_from('<I', binary, 0x3c)[0]
    if binary[pe:pe + 4] != b'PE\0\0' or struct.unpack_from('<H', binary, pe + 4)[0] != 0x8664:
        raise ValueError('Expected a Windows x86-64 PE executable')
    if struct.unpack_from('<H', binary, pe + 24 + 68)[0] != 2:
        raise ValueError('Expected a GUI game executable, not a console launcher')
    project = Path(__file__).resolve().parents[1]
    settings = json.loads((project / 'release.json').read_text())
    game_exe = settings.get('executable', 'ChiefsOfWar.exe')
    prefix = settings.get('archive_prefix', 'ChiefsOfWar')
    notices = project / 'builds/windows/THIRD_PARTY_NOTICES.txt'
    output.mkdir(parents=True, exist_ok=True)
    archive = output / f'{prefix}-Windows-{version}.zip'
    readme = (project / 'packaging/START-HERE.txt').read_text(encoding='utf-8')
    practice = f'@echo off\r\ncd /d "%~dp0.."\r\nstart "" "{game_exe}" --combat-yard\r\n'
    build = f"{settings.get('game_name', 'Chiefs of War')} {version}\nSource commit: {source}\nEngine: Godot 4.4.1\nPlatform: Windows x86-64\n"
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        z.writestr(game_exe, binary)
        z.writestr('START HERE.txt', readme.replace('\n', '\r\n'))
        if settings.get('package_layout') != 'ogre-only':
            z.writestr('Extras/Combat Practice.bat', practice)
        z.writestr('Support/BUILD.txt', build)
        z.write(notices, 'Support/THIRD_PARTY_NOTICES.txt')
    expected = {game_exe, 'START HERE.txt', 'Support/BUILD.txt', 'Support/THIRD_PARTY_NOTICES.txt'}
    if settings.get('package_layout') != 'ogre-only':
        expected.add('Extras/Combat Practice.bat')
    with zipfile.ZipFile(archive) as z:
        if set(z.namelist()) != expected or z.testzip() is not None:
            raise ValueError('Distribution layout or ZIP integrity failed')
        if z.read(game_exe) != binary:
            raise ValueError('Archived game differs from the exported executable')
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    (output / f'SHA256SUMS-{version}.txt').write_text(f'{digest}  {archive.name}\n')
    print(f'PACKAGE VERIFIED: {archive.name}; one GUI game executable; {archive.stat().st_size} bytes; SHA256 {digest}')
    return archive


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--exe', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--version', required=True)
    parser.add_argument('--source', required=True)
    args = parser.parse_args()
    package(args.exe, args.output, args.version, args.source)
