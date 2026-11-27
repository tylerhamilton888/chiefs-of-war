"""Extract body patches beneath the replaceable weapon heads from the painted atlases."""

import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw
from scipy import ndimage

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "art_source/equipment"
OUT = ROOT / "assets/equipment"
PAGE_SIZE = 2048


def body_patch(sheet, origin, outline):
    # Pale fur and warm leather can extend into the stencil on a planted boot.
    # Select the contiguous painted iron, including its dark inked edge.
    polygon = np.array(outline, dtype=float).reshape((-1, 2)) + origin
    left, top = np.maximum(0, np.floor(polygon.min(axis=0)).astype(int) - 7)
    right, bottom = np.minimum(sheet.size, np.ceil(polygon.max(axis=0)).astype(int) + 8)
    box = tuple(map(int, (left, top, right, bottom)))
    patch = sheet.crop(box)
    support = Image.new("L", patch.size)
    ImageDraw.Draw(support).polygon([tuple(pt) for pt in polygon - (left, top)], fill=255)
    stencil = ndimage.binary_dilation(np.array(support) > 0, iterations=3)
    rgba = np.array(patch).astype(float)
    r, g, b, alpha = rgba.transpose(2, 0, 1)
    steel = (r - b < 0.33*r + 4) & (g - b < 0.18*g + 4) & (alpha > 35)
    labels, n = ndimage.label(stencil & steel, structure=np.ones((3, 3)))
    if not n:
        raise ValueError(f"Missing painted iron at {origin}")
    sizes = np.bincount(labels.ravel())
    metal = labels == (np.argmax(sizes[1:]) + 1)
    metal = ndimage.binary_fill_holes(ndimage.binary_closing(metal, iterations=2))
    remove = ndimage.binary_dilation(metal, iterations=3) & stencil
    a = np.array(patch.getchannel("A"))
    a[remove] = 0
    patch.putalpha(Image.fromarray(a))
    return patch, box


def restore_planted_boot(sheet, patch, box):
    # The original contact blade obscured the shin completely. Restore the
    # same Ogre's rear boot from the preceding front drawing, behind the arm.
    source = sheet.crop((769 + 183, 1 + 202, 769 + 275, 1 + 325))
    silhouette = Image.new("L", source.size)
    ImageDraw.Draw(silhouette).polygon(
        [(13, 0), (44, 2), (75, 23), (91, 74), (91, 122), (0, 122),
         (0, 67), (0, 45), (8, 23)], fill=255)
    source.putalpha(ImageChops.multiply(source.getchannel("A"), silhouette))
    source = source.resize((104, 118), Image.Resampling.LANCZOS)
    under = Image.new("RGBA", patch.size)
    under.alpha_composite(source, (1 + 131 - box[0], 401 + 180 - box[1]))
    under.alpha_composite(patch)
    return under


def main():
    rig = json.loads((ART / "weapon_head_registration.json").read_text())
    page = Image.new("RGBA", (PAGE_SIZE, PAGE_SIZE))
    x = y = row_height = 1
    for name, poses in rig.items():
        sheet = Image.open(ROOT / name.removeprefix("res://")).convert("RGBA")
        for key, data in poses.items():
            origin = np.array([int(v) for v in key.split(",")])
            patch, (left, top, _, _) = body_patch(sheet, origin, data[4:])
            if name.endswith("/player_axe_front_swing.png") and key == "1,401":
                patch = restore_planted_boot(sheet, patch, (left, top))
            w, h = patch.size
            if x + w + 1 > PAGE_SIZE:
                x, y, row_height = 1, y + row_height + 2, 0
            if y + h + 1 > PAGE_SIZE:
                raise ValueError("Weapon patches exceed runtime texture budget")
            page.paste(patch, (x, y))
            poses[key] = data[:4] + [int(left-origin[0]), int(top-origin[1]), w, h, x, y]
            x += w + 2
            row_height = max(row_height, h)
    page.crop((0, 0, PAGE_SIZE, y + row_height + 1)).save(OUT / "weapon_body_patches.png", optimize=True)
    lines = []
    for name, poses in rig.items():
        cells = [f'    "{k}": {json.dumps(v, separators=(",", ":"))}' for k, v in poses.items()]
        lines.append("  " + json.dumps(name) + ": {\n" + ",\n".join(cells) + "\n  }")
    (ROOT / "resources/equipment/weapon_head_sockets.json").write_text("{\n" + ",\n".join(lines) + "\n}\n")


if __name__ == "__main__":
    main()
