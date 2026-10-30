# Current implementation state

Updated 2026-10-30. Default branch: `warlord`. Customization and recovered combat are merged into canonical `warlord`. Feature/recovery branches are retained historical checkpoints; new development starts from warlord.

## Implemented on warlord

Existing village/hunting/gathering opener and recovered combat feel changes; independent face/hair/beard/mustache selectors, 8 hair colors, 12 skin tones, 12 cloth colors, color swatches, pose/direction/outfit preview, randomization, and Pause → Appearance for existing campaigns. Old save identity remains intact until explicitly edited. Cancel restores identity and edits do not reset progression. See engineering/customization.md.

Recovered spaced hero/enemy finisher art and gathering transparency fixes are carried forward. The new cosmetic choices use the existing full-body action frames. This is not a new directional combat-animation set or a finished full prologue.

## Validation and delivery

Customization: 73 headless / 74 rendered checks passed. Fresh opener 48, edges 17, motion 20, feel 10 and execution 28 passed; rendered practice isolation/menu passed. Front/left/right/back, both outfits, axe frames and mirrored finisher frames have been rendered for inspection. Windows export and packaged-resource smoke test passed. Published GitHub prerelease: [v0.4.1](https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.4.1), source `339183d219d89a4a497d3eb2b9dae1def686cfc2`. CI run `41094541852` passed all gates; ZIP integrity passed. Asset: `Chiefs-of-War-0.4.1-Windows.zip`, 78,926,376 bytes; SHA-256 `c7dad59b295069f4f3ba13f8039e7b55851da837915ff17721d3f8cc12320b81`. Release is published, not draft. Native Windows and human playfeel remain unverified.

## Remaining broader scope

Block/parry/heavy combat; richer social schedules/family; full invasion/chieftain duel/adoption prologue; expanded world and industry. Male Orc player scope remains; female NPCs remain important characters.
