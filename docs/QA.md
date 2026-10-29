# Verification — 0.1.0

Godot 4.4.1 imported and parsed the project successfully. A graphical Linux run using the compatibility renderer was captured and inspected. The automated Godot suite passed 35 checks, including: player movement normalization, live wall collision removed on destruction, terrain-water collision creation/removal, whole-outfit visual swap, world save/load, no duplicate timber, contained hearth safety, stone nonflammability, explicit ignition, heat-based spread, wet protection, earth/water firebreaks, spread toggle and burning-state persistence.

Windows x86_64 release export is provided with embedded PCK. Native Windows execution has not been tested here. This is not a performance benchmark, combat playtest, or acceptance of animation quality.

Known limits: walk cycles have weak passing poses; only two whole outfits; no work/attack animations accepted; tree felling switches state rather than animating a fall; terrain edges are visibly grid-based; roofs are independent test parts with incomplete assembly/support behavior; flame visuals are placeholders; no NPCs, enemy AI, hunting, production construction, weather simulation or settlement-scale fire optimization. Extinguishing and damage use labeled test tools.
