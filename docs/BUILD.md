# Building

Install Godot 4.4.1 and its matching official export templates. Import the project, run the tests, create `builds/windows`, then export:

```
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/foundation_test.gd -- --fresh
godot --headless --path . --export-release "Windows Desktop" builds/windows/ChiefsOfWar.exe
```

The Windows executable embeds its PCK. Package it with README and THIRD_PARTY_NOTICES. Source-only folders and tests are excluded from export. Keep build binaries out of Git. Use `-- --fresh` to ignore a save while testing. The optional `-- --capture` flag writes an actual viewport PNG to the path in CHIEFS_CAPTURE, then exits; it requires a graphical display.
