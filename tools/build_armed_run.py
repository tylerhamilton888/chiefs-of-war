"""Register two carried weapons to the painted run, retaining the existing armor coverage."""

import json
import math
from pathlib import Path

from weapon_views import turn_sheet

import numpy as np
from PIL import Image, ImageChops, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "assets/ogre"
RIG = ROOT / "resources/equipment"
SOURCE = "res://assets/ogre/hearthlord_run.png"
WIDTH, HEIGHT = 480, 304
LEFT_PAD = (WIDTH - 320) // 2
# At full size, the fist center, weapon pitch, and upper-body translation.
# Opposite boot contacts get different pitches. Both hands keep their anatomical side.
POSES = [
    [
        (204, 136, 10, 8, 17),
        (240, 140, 13, -8, 14),
        (238, 146, 16, -10, 19),
        (198, 140, 9, 7, 13),
    ],
    [
        (96, 160, 39, 22, 16),
        (233, 108, 24, 17, 11),
        (267, 98, 17, 25, 15),
        (111, 158, 36, 19, 10),
    ],
    [
        (235, 135, 26, -7, 7),
        (235, 128, 18, 7, 3),
        (233, 158, 30, 9, 6),
        (232, 136, 23, -6, 3),
    ],
]


def weapon_strip(weapon):
    # Reconstruct the handle across the fingers using an unobstructed section
    # of the same painted haft. The blade and hammer retain their original finish.
    image = Image.open(ART / (weapon + "_walk.png")).convert("RGBA")
    axe = weapon == "hunting_axe"
    grip_y = 119 if axe else 115
    head = (
        [
            (142, 113),
            (154, 111),
            (155, 105),
            (153, 97),
            (168, 89),
            (174, 95),
            (176, 107),
            (180, 107),
            (184, 120),
            (183, 135),
            (176, 147),
            (159, 156),
            (144, 156),
            (150, 143),
            (153, 130),
            (142, 129),
        ]
        if axe
        else [
            (124, 107),
            (132, 106),
            (133, 93),
            (161, 86),
            (170, 94),
            (172, 135),
            (161, 144),
            (133, 141),
            (131, 127),
            (124, 124),
        ]
    )
    mask = Image.new("L", image.size)
    ImageDraw.Draw(mask).polygon(head, fill=255)
    result = Image.new("RGBA", (176, 88))
    # The head sockets to the haft at (104, 43) in this horizontal strip.
    handle = image.crop((70, grip_y - 5, 96, grip_y + 6)).resize((95, 11))
    result.paste(handle, (13, 38))
    pommel = image.crop((28, 114, 39, 131) if axe else (3, 108, 15, 126))
    result.paste(pommel, (5, 35), pommel)
    edge = image.copy()
    edge.putalpha(ImageChops.multiply(edge.getchannel("A"), mask))
    left = min(x for x, y in head)
    edge = edge.crop((left, grip_y - 42, max(x for x, y in head) + 1, grip_y + 45))
    result.alpha_composite(edge, (104, 1))
    return result


def draw_cell(body, weapon, pose, row):
    gx, gy, angle, dx, dy = pose
    # Preserve the face, chest, fur, and their sockets as one rigid drawing.
    # Transfer the lean through the belt while leaving the planted boots fixed.
    yy = np.arange(288)
    blend = np.clip((218 - yy) / 72, 0, 1)
    blend = blend * blend * (3 - 2 * blend)
    dest_y = yy + dy * blend
    source_y = np.interp(np.arange(HEIGHT), dest_y, yy, left=-10, right=300)
    shifts = np.interp(source_y, yy, dx * blend)
    cell = Image.new("RGBA", (WIDTH, HEIGHT))
    mesh = []
    for y in range(HEIGHT):
        sy = source_y[y]
        sy2 = source_y[y + 1] if y + 1 < HEIGHT else sy + 1
        x = -LEFT_PAD - shifts[y]
        mesh.append(
            ((0, y, WIDTH, y + 1), (x, sy, x, sy2, x + WIDTH, sy2, x + WIDTH, sy))
        )
    # Straight-alpha edges are premultiplied by Pillow during resampling.
    cell = body.transform(
        cell.size, Image.Transform.MESH, mesh, Image.Resampling.BICUBIC
    )
    k = float(blend[gy])
    grip = (gx + LEFT_PAD + dx * k, gy + dy * k)
    rad = math.radians(angle)
    c, s = math.cos(rad), math.sin(rad)
    scale = 280 / 192  # Same physical head size as the armed walk.
    # Project the haft along its length about the fist. Its thickness stays fixed.
    shaft_scale = scale * (1.0, 0.62, 0.85)[row]
    a, b = c / shaft_scale, s / shaft_scale
    cross_x, cross_y = -s / scale, c / scale
    carried = weapon.transform(
        cell.size,
        Image.Transform.AFFINE,
        (a, b, 85 - a * grip[0] - b * grip[1], cross_x, cross_y, 43 - cross_x * grip[0] - cross_y * grip[1]),
        Image.Resampling.BICUBIC,
    )
    head_mount = [round(grip[0] + 19 * c * shaft_scale, 2), round(grip[1] + 19 * s * shaft_scale, 2), angle, 280]
    if row == 2:
        # The shaft passes in front of his belly, hidden from the rear camera.
        return Image.alpha_composite(carried, cell), head_mount
    # Only the clenched fist covers the haft. This also keeps the weapon in front of the leg.
    hand = Image.new("L", cell.size)
    x, y = grip
    ImageDraw.Draw(hand).ellipse((x - 15, y - 14, x + 14, y + 14), fill=255)
    result = Image.alpha_composite(cell, carried)
    result.paste(cell, (0, 0), ImageChops.multiply(hand, cell.getchannel("A")))
    return result, head_mount


def register_wearables(table):
    # The head and entire shoulder panel move rigidly. Preserve both the
    # original occlusion stencils and the precise per-drawing skull fit.
    for weapon in ("hunting_axe", "iron_maul"):
        sheet = {}
        for row, poses in enumerate(POSES):
            for col, (_, _, _, dx, dy) in enumerate(poses):
                original = table[SOURCE][f"{col * 320},{row * 288}"]
                socket = original.copy()
                socket[0] = round(socket[0] + LEFT_PAD + dx, 2)
                socket[1] = round(socket[1] + dy, 2)
                if len(socket) == 6 and isinstance(socket[5], list):
                    socket[5] = [
                        [[x + LEFT_PAD + dx, y + dy] for x, y in contour]
                        for contour in socket[5]
                    ]
                sheet[f"{col * WIDTH},{row * HEIGHT}"] = socket
        table[f"res://assets/ogre/{weapon}_run.png"] = sheet


def write_rig(path):
    table = json.loads(path.read_text())
    register_wearables(table)
    groups = []
    for name, sheet in table.items():
        cells = [
            f"    {json.dumps(k)}: {json.dumps(v, separators=(',', ':'))}"
            for k, v in sheet.items()
        ]
        groups.append("  " + json.dumps(name) + ": {\n" + ",\n".join(cells) + "\n  }")
    path.write_text("{\n" + ",\n".join(groups) + "\n}\n")


def main():
    run = Image.open(ART / "hearthlord_run.png").convert("RGBA")
    run_heads = {}
    for weapon in ("hunting_axe", "iron_maul"):
        atlas = Image.new("RGBA", (4 * WIDTH, 3 * HEIGHT))
        prop = weapon_strip(weapon)
        head = prop.crop((104, 0, 155, 88))
        turn_sheet(head, weapon).save(ROOT / "assets/equipment" / (weapon + "_head.png"), optimize=True)
        prop.paste((0, 0, 0, 0), (104, 0, prop.width, prop.height))
        sockets = {}
        for row, poses in enumerate(POSES):
            for col, pose in enumerate(poses):
                body = run.crop(
                    (col * 320, row * 288, (col + 1) * 320, (row + 1) * 288)
                )
                cell, mount = draw_cell(body, prop, pose, row)
                sockets[f"{col * WIDTH},{row * HEIGHT}"] = mount
                x0, y0, x1, y1 = cell.getbbox()
                if min(x0, y0, WIDTH - x1, HEIGHT - y1) < 2:
                    raise ValueError(
                        f"{weapon} run touches the atlas edge in pose {row}, {col}"
                    )
                atlas.paste(cell, (col * WIDTH, row * HEIGHT))
        atlas.save(ART / (weapon + "_run.png"), optimize=True)
        run_heads[f"res://assets/ogre/{weapon}_run.png"] = sockets
    (RIG / "run_weapon_sockets.json").write_text(json.dumps(run_heads, indent=2) + "\n")
    for slot in ("head", "shoulder"):
        write_rig(RIG / (slot + "_sockets.json"))


if __name__ == "__main__":
    main()
