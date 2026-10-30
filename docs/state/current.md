# Current implementation state

Updated 2026-10-30. Default branch: `warlord`. Active expansion: `feature/orc-customization`, based on recovery head `7c9f30a24a2dae923765581eb827e40f177d9192`. Original recovery workspace and its uncommitted files were preserved; the customization checkout is separate.

## Implemented in this branch

Existing village/hunting/gathering opener and recovered combat feel changes; independent face/hair/beard/mustache selectors, 8 hair colors, 12 skin tones, 12 cloth colors, color swatches, pose/direction/outfit preview, randomization, and Pause → Appearance for existing campaigns. Old save identity remains intact until explicitly edited. Cancel restores identity and edits do not reset progression. See engineering/customization.md.

Recovered spaced hero/enemy finisher art and gathering transparency fixes are carried forward. The new cosmetic choices use the existing full-body action frames. This is not a new directional combat-animation set or a finished full prologue.

## Validation and delivery

Customization: 73 headless / 74 rendered checks passed. Fresh opener 48, edges 17, motion 20, feel 10 and execution 28 passed; rendered practice isolation/menu passed. Front/left/right/back, both outfits, axe frames and mirrored finisher frames have been rendered for inspection. Windows export succeeded. Release publication is pending its CI gates; check the actual release before claiming delivery. Native Windows and human playfeel remain unverified.

## Remaining broader scope

Block/parry/heavy combat; richer social schedules/family; full invasion/chieftain duel/adoption prologue; expanded world and industry. Male Orc player scope remains; female NPCs remain important characters.
