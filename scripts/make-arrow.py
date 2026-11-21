# TomTom's modern crazy arrow, rebuilt as our own picture.
# 9 columns by 12 rows, 108 squares. Cell 0 points up. Each next cell turns clockwise.
# Sheet is 2304 by 3072, each cell 256. Same grid as TomTom's modern theme.

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
CELL = 256
COLS = 9
ROWS = 12
CELLS = COLS * ROWS
TEX_W = COLS * CELL
TEX_H = ROWS * CELL


def arrow_picture():
    size = CELL * 4
    drawn = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(drawn)
    # A chevron, drawn large and then centered so every turn stays in the cell.
    outline = [(512, 220), (900, 860), (690, 860), (512, 620), (334, 860), (124, 860)]
    body = [(512, 280), (820, 800), (650, 800), (512, 600), (374, 800), (204, 800)]
    light = [(512, 330), (680, 620), (512, 540), (344, 620)]
    draw.polygon(outline, fill=(32, 24, 12, 255))
    draw.polygon(body, fill=(232, 186, 74, 255))
    draw.polygon(light, fill=(255, 236, 190, 255))
    box = drawn.getbbox()
    left, top, right, bottom = box
    wide = right - left
    high = bottom - top
    fitted = int(size * 0.72)
    scale = fitted / max(wide, high)
    resized = drawn.crop(box).resize(
        (max(1, int(wide * scale)), max(1, int(high * scale))),
        Image.Resampling.LANCZOS,
    )
    base = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    base.paste(
        resized,
        ((size - resized.width) // 2, (size - resized.height) // 2),
        resized,
    )
    return base.resize((CELL, CELL), Image.Resampling.LANCZOS)


def main():
    base = arrow_picture()
    sheet = Image.new("RGBA", (TEX_W, TEX_H), (0, 0, 0, 0))
    step = 360.0 / CELLS
    for index in range(CELLS):
        turned = base.rotate(-index * step, resample=Image.Resampling.BICUBIC, expand=False)
        column = index % COLS
        row = index // COLS
        sheet.paste(turned, (column * CELL, row * CELL), turned)

    dist = ROOT / "dist"
    dist.mkdir(exist_ok=True)
    sheet.resize((COLS * 48, ROWS * 48), Image.Resampling.LANCZOS).save(dist / "arrow-nav-preview.png")
    strip = Image.new("RGBA", (CELL * 4, CELL), (0, 0, 0, 255))
    for place, index in enumerate((0, 27, 54, 81)):
        column = index % COLS
        row = index // COLS
        strip.paste(sheet.crop((column * CELL, row * CELL, (column + 1) * CELL, (row + 1) * CELL)), (place * CELL, 0))
    strip.save(dist / "arrow-nav-cells.png")

    raw = np.array(sheet, dtype=np.uint8)
    bgra = np.flipud(raw[:, :, [2, 1, 0, 3]])
    header = bytearray(18)
    header[2] = 2
    header[12:14] = TEX_W.to_bytes(2, "little")
    header[14:16] = TEX_H.to_bytes(2, "little")
    header[16] = 32
    header[17] = 8
    out = ROOT / "Media" / "arrow-nav.tga"
    out.write_bytes(bytes(header) + bgra.tobytes())
    print(f"wrote {out} ({out.stat().st_size} bytes) {CELLS} turns")


if __name__ == "__main__":
    main()
