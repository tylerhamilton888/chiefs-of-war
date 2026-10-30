# 0.2 QA

Godot 4.4.1 Linux import and actual OpenGL viewport rendering checked. Native Windows execution is unavailable; Windows export is verified as an export/package only.

- 35 existing foundation checks pass: object state, fire ignition/spread/wetness/barriers, collision, movement and persistence.
- 27 camp integration checks pass: movement, attack windup/contact/recovery, range and facing, duplicate-safe resources, material gates, staged construction, room collision/return point, forging, mitigation, dodge, defeat rewards, worker cargo/storage, progress save/restore, modal pausing.
- Actual worker navigation/gather/deposit test passes: Bren cut a tree, removed its bundle, returned and deposited three timber. Actual engine hall/dialogue/strike captures were inspected.

Art is not final: generated directional sheets have uneven poses and armor continuity; metadata corrects reversed side rows. Cut-off recovery cells are omitted, returning to the ready pose. This does not constitute approval of final animation quality. Interiors share a compact layout and building destruction uses visual columns pending authored damage art. No hunting or narrative invasion yet.

Commands:
```
godot --headless --path . --script tests/foundation_test.gd -- --fresh
godot --headless --path . --script tests/camp_test.gd -- --fresh
godot --headless --path . --script tests/worker_test.gd -- --fresh
```
Use an isolated XDG_DATA_HOME for automated tests. Test scripts and the old harness are excluded from release packaging where possible; the 3D prototype is ignored.
