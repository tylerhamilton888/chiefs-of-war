"""Check runtime textures and generated review images before packaging."""
import argparse
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
TEXTURE_EDGE = 2048
PREVIEW_EDGE = 1280
PREVIEW_BYTES = 750_000


def check_images(paths, edge, preview=False):
    count = 0
    for path in paths:
        with Image.open(path) as image:
            if max(image.size) > edge:
                raise ValueError(f"{path}: {image.size} exceeds {edge}px on one side")
            if preview and (image.format != "WEBP" or path.stat().st_size > PREVIEW_BYTES):
                raise ValueError(f"{path}: review images must be WebP and at most {PREVIEW_BYTES} bytes")
            image.verify()
        count += 1
    if not count:
        raise ValueError("No images found to check")
    return count


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--previews", type=Path)
    args = parser.parse_args()
    if args.previews:
        files = sorted(p for p in args.previews.iterdir() if p.is_file())
        print(f"Checked {check_images(files, PREVIEW_EDGE, preview=True)} review images")
    else:
        if not (ROOT / "art_source" / ".gdignore").is_file():
            raise ValueError("art_source must be excluded from Godot imports")
        extensions = set(Image.registered_extensions())
        images = (p for p in (ROOT / "assets").rglob("*") if p.suffix.lower() in extensions)
        print(f"Checked {check_images(images, TEXTURE_EDGE)} runtime textures")
