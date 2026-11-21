# Theme art: a logo and a corner piece for each theme, plus the shared effect
# textures. Sources are painted on flat magenta, green, or blue in art/theme-src. This
# keys the backdrop out, crops, and writes 32-bit TGAs into Media. Mist, flame,
# and the particles are drawn here.
# Run: uv run --no-project --with pillow --with numpy scripts/make-theme-art.py

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "art" / "theme-src"
MEDIA = ROOT / "Media"
DIST = ROOT / "dist"


def write_tga(image: Image.Image, path: Path) -> None:
    """Write an RGBA image as an uncompressed bottom-up 32-bit TGA."""
    raw = np.array(image.convert("RGBA"), dtype=np.uint8)
    height, width = raw.shape[:2]
    bgra = np.flipud(raw[:, :, [2, 1, 0, 3]])
    header = bytearray(18)
    header[2] = 2
    header[12:14] = width.to_bytes(2, "little")
    header[14:16] = height.to_bytes(2, "little")
    header[16] = 32
    header[17] = 8
    path.write_bytes(bytes(header) + bgra.tobytes())
    print(f"wrote {path.relative_to(ROOT)} {width}x{height}")


def screen_strength(rgb: np.ndarray, screen: str) -> np.ndarray:
    """How strongly each pixel looks like the backdrop colour."""
    red, green, blue = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    if screen == "green":
        return green - np.maximum(red, blue)
    if screen == "blue":
        return blue - np.maximum(red, green)
    return np.minimum(red, blue) - green


def key_screen(path: Path, screen: str = "magenta") -> np.ndarray:
    """Return float RGBA in 0..1 with the magenta or green backdrop removed and despilled."""
    rgb = np.asarray(Image.open(path).convert("RGB"), dtype=np.float32) / 255.0
    corners = np.concatenate([rgb[:16, :16].reshape(-1, 3), rgb[-16:, -16:].reshape(-1, 3)])
    backdrop = corners.mean(axis=0)
    strength = screen_strength(rgb, screen)
    full = float(screen_strength(backdrop[None, None, :], screen)[0, 0])
    clear, solid = full * 0.8, full * 0.35
    alpha = np.clip((clear - strength) / (clear - solid), 0.0, 1.0)
    safe = np.maximum(alpha, 1e-3)[..., None]
    color = np.clip((rgb - (1.0 - alpha[..., None]) * backdrop) / safe, 0.0, 1.0)
    edge = alpha < 0.98
    if screen == "green":
        # Smoke over green leaves a green cast well inside the art, so cap it everywhere.
        cap = np.maximum(color[..., 0], color[..., 2]) + 0.06
        spill = color[..., 1] > cap
        color[..., 1][spill] = cap[spill]
    elif screen == "blue":
        cap = np.maximum(color[..., 0], color[..., 1]) + 0.06
        spill = edge & (color[..., 2] > cap)
        color[..., 2][spill] = cap[spill]
    else:
        cap = color[..., 1] + 0.18
        spill = edge & (np.minimum(color[..., 0], color[..., 2]) > cap)
        color[..., 0][spill] = cap[spill]
        color[..., 2][spill] = cap[spill]
    return np.dstack([color, alpha])


def to_image(rgba: np.ndarray) -> Image.Image:
    return Image.fromarray((np.clip(rgba, 0.0, 1.0) * 255.0 + 0.5).astype(np.uint8), "RGBA")


def make_logo(name: str, screen: str, icy: bool = False) -> Image.Image:
    rgba = key_screen(SRC / name, screen)
    if icy:
        # Mist painted over magenta comes out lavender. Pull red down to ice blue.
        lavender = rgba[..., 0] > rgba[..., 1]
        rgba[..., 0][lavender] = rgba[..., 1][lavender] * 0.92
    image = to_image(rgba)
    box = image.getchannel("A").point(lambda value: 255 if value > 24 else 0).getbbox()
    image = image.crop(box)
    side = int(max(image.size) * 1.04)
    square = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    square.paste(image, ((side - image.width) // 2, (side - image.height) // 2), image)
    return square.resize((256, 256), Image.Resampling.LANCZOS)


def make_corner(name: str, screen: str, crop: int, fade: int) -> Image.Image:
    """Crop the top-left ornament and fade the cut ends of both arms."""
    rgba = key_screen(SRC / name, screen)[:crop, :crop].copy()
    ys, xs = np.mgrid[0:crop, 0:crop]
    reach = np.maximum(xs, ys).astype(np.float32)
    rgba[..., 3] *= np.clip((crop - reach) / fade, 0.0, 1.0)
    return to_image(rgba).resize((256, 256), Image.Resampling.LANCZOS)


def make_bottom_corner(name: str, screen: str, crop: int, fade: int) -> Image.Image:
    """Like make_corner, for art painted upright in the bottom-left so characters are not flipped."""
    rgba = key_screen(SRC / name, screen)
    rgba = rgba[rgba.shape[0] - crop :, :crop].copy()
    ys, xs = np.mgrid[0:crop, 0:crop]
    reach = np.maximum(xs, crop - 1 - ys).astype(np.float32)
    rgba[..., 3] *= np.clip((crop - reach) / fade, 0.0, 1.0)
    return to_image(rgba).resize((256, 256), Image.Resampling.LANCZOS)


def periodic_noise(size: int, sigma: float, seed: int) -> np.ndarray:
    """Smooth noise that wraps at the edges, so the texture tiles with no seam."""
    rng = np.random.default_rng(seed)
    white = rng.standard_normal((size, size))
    freq = np.fft.fftfreq(size)
    fx, fy = np.meshgrid(freq, freq)
    blur = np.exp(-(fx ** 2 + fy ** 2) * (2 * (np.pi * sigma) ** 2))
    field = np.real(np.fft.ifft2(np.fft.fft2(white) * blur))
    field -= field.min()
    return field / field.max()


def make_mist() -> Image.Image:
    size = 256
    field = (
        0.55 * periodic_noise(size, 18.0, 7)
        + 0.30 * periodic_noise(size, 8.0, 11)
        + 0.15 * periodic_noise(size, 3.0, 19)
    )
    field = (field - field.min()) / (field.max() - field.min())
    alpha = np.clip((field - 0.38) / 0.5, 0.0, 1.0) ** 1.6
    rgba = np.dstack([np.ones_like(alpha), np.ones_like(alpha), np.ones_like(alpha), alpha])
    return to_image(rgba)


def make_flame() -> Image.Image:
    """A soft white teardrop with a bright core. The game tints it and adds it."""
    size = 128
    ys, xs = np.mgrid[0:size, 0:size].astype(np.float32)
    nx = (xs - size / 2) / (size / 2)
    ny = (ys - size * 0.62) / (size / 2)
    # Narrow toward the top so the glow reads as a flame tongue.
    width = 0.62 * (1 - 0.6 * np.clip(-ny, 0, 1))
    dist = np.sqrt((nx / width) ** 2 + (ny / np.where(ny < 0, 1.1, 0.5)) ** 2)
    glow = np.clip(1.0 - dist, 0.0, 1.0) ** 1.8
    core = np.clip(1.0 - dist * 2.2, 0.0, 1.0) ** 1.2
    alpha = np.clip(glow * 0.85 + core * 0.6, 0.0, 1.0)
    rgba = np.dstack([np.ones_like(alpha), np.ones_like(alpha), np.ones_like(alpha), alpha])
    return to_image(rgba)


def white_with(alpha: np.ndarray) -> Image.Image:
    ones = np.ones_like(alpha)
    return to_image(np.dstack([ones, ones, ones, np.clip(alpha, 0.0, 1.0)]))


def particle_grid(size: int) -> tuple[np.ndarray, np.ndarray]:
    ys, xs = np.mgrid[0:size, 0:size].astype(np.float32)
    half = (size - 1) / 2
    return (xs - half) / half, (ys - half) / half


def make_spark() -> Image.Image:
    """Soft round mote with a hot centre, for embers, motes, and wisps."""
    nx, ny = particle_grid(64)
    dist = np.sqrt(nx ** 2 + ny ** 2)
    return white_with(np.clip(1 - dist, 0, 1) ** 2.2 + np.clip(1 - dist * 3, 0, 1) ** 1.5 * 0.6)


def make_star() -> Image.Image:
    """Four-point twinkle."""
    nx, ny = particle_grid(64)
    dist = np.sqrt(nx ** 2 + ny ** 2)
    rays = np.exp(-np.abs(nx) * 14) * np.exp(-(ny ** 2) * 2) + np.exp(-np.abs(ny) * 14) * np.exp(-(nx ** 2) * 2)
    return white_with(rays * np.clip(1 - dist, 0, 1) + np.clip(1 - dist * 2.5, 0, 1) ** 2)


def make_snow() -> Image.Image:
    """Six-armed snowflake, drawn large and shrunk so the thin arms stay smooth."""
    big = 256
    sheet = Image.new("L", (big, big), 0)
    draw = ImageDraw.Draw(sheet)
    centre = big / 2
    for arm in range(6):
        angle = np.pi / 3 * arm
        dx, dy = np.cos(angle), np.sin(angle)
        tip = (centre + dx * 110, centre + dy * 110)
        draw.line([(centre, centre), tip], fill=255, width=14)
        for along, reach in ((0.45, 36), (0.72, 26)):
            base = (centre + dx * 110 * along, centre + dy * 110 * along)
            for side in (-1, 1):
                twig = angle + side * np.pi / 4
                draw.line([base, (base[0] + np.cos(twig) * reach, base[1] + np.sin(twig) * reach)], fill=255, width=10)
    sheet = sheet.filter(ImageFilter.GaussianBlur(3)).resize((64, 64), Image.Resampling.LANCZOS)
    return white_with(np.asarray(sheet, dtype=np.float32) / 255.0)


def make_leaf() -> Image.Image:
    """Pointed leaf with a midrib, tilted so a spin reads as tumbling."""
    nx, ny = particle_grid(64)
    tilt = 0.6
    u = nx * np.cos(tilt) - ny * np.sin(tilt)
    v = nx * np.sin(tilt) + ny * np.cos(tilt)
    half_width = 0.42 * np.clip(1 - u ** 2, 0, 1) ** 0.8
    body = np.clip((half_width - np.abs(v)) * 18, 0, 1) * (np.abs(u) < 0.95)
    rib = np.exp(-(v ** 2) * 900) * (np.abs(u) < 0.9)
    return white_with(body * 0.85 - rib * 0.35)


def make_feather() -> Image.Image:
    """Soft white feather: a thin shaft with a vane that tapers to the tip."""
    nx, ny = particle_grid(64)
    tilt = -0.5
    u = nx * np.cos(tilt) - ny * np.sin(tilt)
    v = nx * np.sin(tilt) + ny * np.cos(tilt)
    reach = np.clip(0.95 - np.abs(u), 0, 1)
    vane_width = 0.30 * np.clip(np.sin(np.clip((u + 0.95) / 1.7, 0, 1) * np.pi), 0, 1) ** 0.7
    vane = np.clip((vane_width - np.abs(v)) * 14, 0, 1) * (u > -0.75)
    shaft = np.exp(-(v ** 2) * 1500) * (reach > 0)
    barbs = 0.8 + 0.2 * np.sin(u * 60 + np.abs(v) * 30)
    return white_with(np.maximum(vane * barbs * 0.8, shaft))


def make_bubble() -> Image.Image:
    """Thin ring with a highlight, for rising poison bubbles."""
    nx, ny = particle_grid(64)
    dist = np.sqrt(nx ** 2 + ny ** 2)
    ring = np.exp(-((dist - 0.78) ** 2) * 220)
    fill = np.clip(0.78 - dist, 0, 1) * 0.35
    shine = np.exp(-((nx + 0.32) ** 2 + (ny + 0.32) ** 2) * 40)
    return white_with(ring + fill + shine * 0.9)


def make_heart() -> Image.Image:
    """Solid heart from the classic implicit curve, with a soft rim."""
    nx, ny = particle_grid(64)
    x, y = nx * 1.5, -ny * 1.5 + 0.1
    curve = (x ** 2 + y ** 2 - 1) ** 3 - x ** 2 * y ** 3
    body = np.clip(-curve * 30, 0, 1)
    shine = np.exp(-((nx + 0.35) ** 2 + (ny + 0.3) ** 2) * 30)
    return white_with(np.clip(body * 0.85 + shine * 0.3 * body, 0, 1))


def make_paw() -> Image.Image:
    """Paw print: a pad and four toe beans."""
    big = 256
    sheet = Image.new("L", (big, big), 0)
    draw = ImageDraw.Draw(sheet)
    draw.ellipse([68, 120, 188, 220], fill=255)
    for cx, cy in ((52, 92), (100, 52), (156, 52), (204, 92)):
        draw.ellipse([cx - 26, cy - 32, cx + 26, cy + 32], fill=255)
    sheet = sheet.filter(ImageFilter.GaussianBlur(3)).resize((64, 64), Image.Resampling.LANCZOS)
    return white_with(np.asarray(sheet, dtype=np.float32) / 255.0)


def make_gear() -> Image.Image:
    """Eight-toothed cog with an axle hole, for spinning gnome gears."""
    nx, ny = particle_grid(64)
    dist = np.sqrt(nx ** 2 + ny ** 2)
    angle = np.arctan2(ny, nx)
    teeth = np.clip(np.cos(angle * 8) * 3, -1, 1) * 0.5 + 0.5
    rim = 0.62 + 0.24 * teeth
    body = np.clip((rim - dist) * 30, 0, 1) * np.clip((dist - 0.22) * 30, 0, 1)
    return white_with(body)


def make_cat() -> Image.Image:
    """Cat face: round head, pointed ears, eyes and nose cut out so it reads at small sizes."""
    big = 256
    sheet = Image.new("L", (big, big), 0)
    draw = ImageDraw.Draw(sheet)
    draw.ellipse([40, 70, 216, 222], fill=255)
    draw.polygon([(48, 130), (56, 22), (118, 82)], fill=255)
    draw.polygon([(208, 130), (200, 22), (138, 82)], fill=255)
    draw.ellipse([82, 122, 112, 156], fill=0)
    draw.ellipse([144, 122, 174, 156], fill=0)
    draw.polygon([(116, 168), (140, 168), (128, 182)], fill=0)
    sheet = sheet.filter(ImageFilter.GaussianBlur(2)).resize((64, 64), Image.Resampling.LANCZOS)
    return white_with(np.asarray(sheet, dtype=np.float32) / 255.0)


def make_bat() -> Image.Image:
    """Bat silhouette with scalloped wings."""
    big = 256
    sheet = Image.new("L", (big, big), 0)
    draw = ImageDraw.Draw(sheet)
    wing = [(128, 110), (180, 70), (240, 80), (250, 130), (222, 122), (204, 150), (180, 136), (160, 160), (128, 140)]
    draw.polygon(wing, fill=255)
    draw.polygon([(big - x, y) for x, y in wing], fill=255)
    draw.ellipse([110, 96, 146, 164], fill=255)
    draw.polygon([(112, 104), (116, 80), (126, 98)], fill=255)
    draw.polygon([(144, 104), (140, 80), (130, 98)], fill=255)
    sheet = sheet.filter(ImageFilter.GaussianBlur(2)).resize((64, 64), Image.Resampling.LANCZOS)
    return white_with(np.asarray(sheet, dtype=np.float32) / 255.0)


# theme, backdrop colour of its sources, corner crop, corner fade.
# Purple themes are painted on green, since a magenta key would eat their purples.
THEMES = [
    ("undead", "magenta", 600, 150),
    ("horde", "magenta", 660, 60),
    ("alliance", "magenta", 640, 150),
    ("nightelf", "green", 640, 150),
    ("arcane", "green", 640, 120),
    ("frost", "magenta", 600, 150),
    ("warrior", "magenta", 640, 150),
    ("paladin", "green", 640, 150),
    ("hunter", "magenta", 640, 150),
    ("rogue", "magenta", 640, 150),
    ("priest", "magenta", 640, 150),
    ("shaman", "magenta", 640, 150),
    ("mage", "green", 600, 120),
    ("warlock", "green", 640, 150),
    ("druid", "magenta", 640, 150),
    ("fire", "magenta", 640, 150),
    ("hallowsend", "green", 640, 150),
    ("winterveil", "magenta", 640, 150),
    ("lunarfestival", "green", 640, 150),
    ("loveintheair", "blue", 640, 150),
    ("kitty", "green", 820, 90),
    ("blizzard", "magenta", 640, 120),
    ("human", "magenta", 640, 150),
    ("dwarf", "magenta", 640, 150),
    ("gnome", "magenta", 640, 150),
    ("orc", "magenta", 640, 150),
    ("troll", "magenta", 640, 150),
    ("tauren", "magenta", 640, 150),
    ("skyborne", "magenta", 640, 150),
]


# Themes whose corners have characters on them get their own upright bottom corner.
BOTTOM_CORNERS = [
    ("kitty", "green", 820, 90),
]


def preview(images: dict[str, Image.Image]) -> None:
    DIST.mkdir(exist_ok=True)
    cell, cols = 192, 6
    rows = (len(images) + cols - 1) // cols
    sheet = Image.new("RGBA", (cell * cols, cell * rows), (14, 11, 18, 255))
    for place, image in enumerate(images.values()):
        shown = image.resize((cell, int(cell * image.height / image.width)), Image.Resampling.LANCZOS)
        column, row = place % cols, place // cols
        sheet.alpha_composite(shown, (column * cell, row * cell + (cell - shown.height) // 2))
    out = DIST / "theme-art-preview.png"
    sheet.save(out)
    print(f"wrote {out.relative_to(ROOT)}")


def main() -> None:
    images = {}
    for theme, screen, crop, fade in THEMES:
        images[f"theme-{theme}-logo"] = make_logo(f"{theme}-logo-src.jpg", screen, icy=theme == "frost")
        images[f"theme-{theme}-corner"] = make_corner(f"{theme}-corner-src.jpg", screen, crop, fade)
    for theme, screen, crop, fade in BOTTOM_CORNERS:
        images[f"theme-{theme}-bottom"] = make_bottom_corner(f"{theme}-bottom-src.jpg", screen, crop, fade)
    images["theme-mist"] = make_mist()
    images["theme-flame"] = make_flame()
    images["theme-spark"] = make_spark()
    images["theme-star"] = make_star()
    images["theme-snow"] = make_snow()
    images["theme-leaf"] = make_leaf()
    images["theme-feather"] = make_feather()
    images["theme-bubble"] = make_bubble()
    images["theme-heart"] = make_heart()
    images["theme-paw"] = make_paw()
    images["theme-bat"] = make_bat()
    images["theme-gear"] = make_gear()
    images["theme-cat"] = make_cat()
    for name, image in images.items():
        write_tga(image, MEDIA / f"{name}.tga")
    preview(images)


if __name__ == "__main__":
    main()
