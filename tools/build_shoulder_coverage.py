"""Pack the playable Ogre's visible fur panels for the shared shoulder slot.

Offline art utility. Run with Pillow, NumPy and SciPy installed. Each source
body pose also needs a registered head socket. Inspect the result in motion
after changing the base costume, adding poses, or adjusting its palette.
"""

import json
from pathlib import Path

from build_armed_run import register_wearables

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter
from scipy import ndimage


ROOT = Path(__file__).resolve().parents[1]
RUNTIME = ROOT / "assets" / "equipment"
SOCKETS = ROOT / "resources" / "equipment"
PAGE_LIMIT = 1536
VIEWS = ("front", "side", "rear")
REGISTERED_BODIES = (
    "assets/chapter/player_combat_nordic.png",
    "assets/chapter/player_maul_nordic.png",
    "assets/ogre/hearthlord_motion_nordic.png",
)


def read(path):
    return json.loads(path.read_text())


def body_frames():
    registry = read(ROOT / "resources" / "ogre_frame_registration.json")
    for source in REGISTERED_BODIES:
        path = "res://" + source
        data = registry[path]
        walk = "hearthlord_motion" in path
        for index, frame in enumerate(data["frames"]):
            row = index // 4
            view = ("front", "side", "side", "rear")[row] if walk else VIEWS[row]
            raised_arms = not walk and index == 1
            yield path, frame["rect"], data["height"], view, frame["polygons"], raised_arms

    for row, view in enumerate(VIEWS):
        for col in range(4):
            yield "res://assets/ogre/hearthlord_run.png", (col * 320, row * 288, 320, 288), 280, view, None, False

    for kind in ("walk", "dodge"):
        for weapon in ("hunting_axe", "iron_maul"):
            sheet = f"{weapon}_{kind}"
            data = read(ROOT / "resources" / "ogre" / (sheet + ".json"))
            for tracks in (data["rows"], data.get("strafe_rows", [])):
                for view, cells in zip(VIEWS, tracks):
                    for cell in cells:
                        yield f"res://assets/ogre/{sheet}.png", cell[:4], data["height"], view, None, False

    for name in sorted((ROOT / "resources" / "chapter").glob("player_*_swing.json")):
        data = read(name)
        view = "side" if "_side_" in name.stem else "front" if "_front_" in name.stem else "rear"
        for index, cell in enumerate(data["frames"]):
            if cell:
                raised_arms = name.stem == "player_axe_front_swing" and index == 1
                yield data["texture"], cell[:4], data["height"], view, None, raised_arms


def isolate_body(texture, rect, polygons):
    x, y, w, h = rect
    crop = texture.crop((x, y, x + w, y + h))
    if polygons:
        mask = Image.new("L", (w, h))
        draw = ImageDraw.Draw(mask)
        for contour in polygons:
            draw.polygon([(px - x, py - y) for px, py in contour], fill=255)
        crop.putalpha(ImageChops.multiply(crop.getchannel("A"), mask))
    return crop


def shoulder_panel(body, head, height, raised_arms):
    pixels = np.asarray(body, dtype=np.float32)
    red, green, blue, alpha = pixels.transpose((2, 0, 1))
    y, x = np.indices(alpha.shape)
    head_x, head_y = head[:2]

    # Find large, warm ivory patches attached to the upper body. The extended
    # shade range fills fur in shadow after the light patches have been found.
    upper = (alpha > 100) & (y > head_y - height * .065) & (y < head_y + height * .5)
    upper &= np.abs(x - head_x) < height * .65
    light = (red > 145) & (green > red * .77) & (blue > green * .68) & (blue < green * .973) & (red > green * 1.012)
    shade = (red > 100) & (green > red * .697) & (blue > green * .575) & (blue < green * .995) & (red > green * 1.007)
    labels, _ = ndimage.label(ndimage.binary_opening(upper & light))
    large = np.flatnonzero(np.bincount(labels.ravel()) > max(12, height * height * .0013))
    mask = ndimage.binary_propagation(np.isin(labels, large[large != 0]), mask=upper & shade)
    mask |= ndimage.binary_closing(mask, iterations=max(1, round(height / 110)))
    mask = ndimage.binary_fill_holes(mask) & (alpha > 100)

    # Reject isolated highlights on weapons and the lower pelt hanging from
    # the belt. Keep occluding forearms, weapons, hair and chest transparent.
    groups, total = ndimage.label(mask)
    for index in range(1, total + 1):
        part = groups == index
        ys = np.nonzero(part)[0]
        if ys.size < height * height * .001 or ys.min() > head_y + height * .26 or np.median(red[part]) < 217:
            mask[part] = False
    bounds = Image.fromarray(mask).getbbox()
    if bounds is None:
        raise ValueError("Could not identify a shoulder panel")
    x1, y1, x2, y2 = bounds
    if raised_arms:
        # The long fur edge beneath the bracer remains exposed when the
        # Ogre lifts both arms. The fitted plates end at his upper back.
        y2 = min(y2, round(y1 + height * .23))
    matte = Image.fromarray(mask[y1:y2, x1:x2].astype("uint8") * 255)
    coverage = np.asarray(matte.filter(ImageFilter.GaussianBlur(.42)))

    light = ndimage.gaussian_filter(red[y1:y2, x1:x2], sigma=.7)
    shade = np.clip(201 + 54 * light / 242, 205, 255).astype("uint8")
    luminance = np.where(coverage > 0, np.clip(np.round(shade / 4) * 4, 0, 255), 0).astype("uint8")
    panel = Image.merge("LA", (Image.fromarray(luminance), Image.fromarray(coverage)))
    return panel, x1, y1


def build():
    heads = read(SOCKETS / "head_sockets.json")
    textures = {}
    panels = []
    for path, bounds, height, view, polygons, raised_arms in body_frames():
        if path not in textures:
            textures[path] = Image.open(ROOT / path.removeprefix("res://")).convert("RGBA")
        rect = tuple(map(int, bounds))
        key = f"{rect[0]},{rect[1]}"
        body = isolate_body(textures[path], rect, polygons)
        try:
            panel, left, top = shoulder_panel(body, heads[path][key], height, raised_arms)
        except (ValueError, KeyError) as error:
            raise ValueError(f"Cannot register shoulder on {path} at {key}: {error}") from error
        panels.append((path, key, left, top, view, panel))

    # Sort by height, then resource and frame to keep pack output deterministic.
    panels.sort(key=lambda entry: (-entry[-1].height, entry[0], entry[1]))
    pages = [[]]
    x, y, row_height = 2, 2, 0
    slots = {}
    for path, key, left, top, view, panel in panels:
        w, h = panel.size
        if x + w + 2 > PAGE_LIMIT:
            x, y, row_height = 2, y + row_height + 4, 0
        if y + h + 2 > PAGE_LIMIT:
            pages.append([])
            x, y, row_height = 2, 2, 0
        pages[-1].append((x, y, panel))
        slots.setdefault(path, {})[key] = [left, top, w, h, view, len(pages) - 1, x, y, w, h]
        x += w + 4
        row_height = max(row_height, h)
    for i, page in enumerate(pages):
        size = (max(x + img.width for x, y, img in page) + 2, max(y + img.height for x, y, img in page) + 2)
        atlas = Image.new("LA", size)
        for x, y, panel in page:
            atlas.paste(panel, (x, y))
        atlas.save(RUNTIME / f"shoulder_coverage_{i}.png", optimize=True)
    register_wearables(slots)
    groups = []
    for path, poses in sorted(slots.items()):
        pairs = [f"    {json.dumps(k)}: {json.dumps(v, separators=(',', ':'))}" for k, v in sorted(poses.items())]
        groups.append(f"  {json.dumps(path)}: {{\n" + ",\n".join(pairs) + "\n  }")
    (SOCKETS / "shoulder_sockets.json").write_text("{\n" + ",\n".join(groups) + "\n}\n")
    print(f"Packed {len(panels)} shoulder panels in {len(pages)} coverage atlas(es).")


if __name__ == "__main__":
    build()
