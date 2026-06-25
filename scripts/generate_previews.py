#!/usr/bin/env python3
"""Generate deterministic preview art for every shader.

Requires Pillow and NumPy. The generated images are illustrative previews of
what the corresponding LÖVE shaders do; the actual shader code remains the
source of truth.
"""

from __future__ import annotations

import colorsys
import json
import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
SHADERS = ROOT / "shaders"
SIZE = (640, 360)
SEED = 20260625
RNG = np.random.default_rng(SEED)


def hex_color(value: str, alpha: int = 255) -> tuple[int, int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[index:index + 2], 16) for index in (0, 2, 4)) + (alpha,)


def make_scene() -> Image.Image:
    width, height = SIZE
    y = np.linspace(0.0, 1.0, height, dtype=np.float32)[:, None, None]
    top = np.array([8, 9, 30], dtype=np.float32)[None, None, :]
    bottom = np.array([31, 24, 78], dtype=np.float32)[None, None, :]
    rgb = top * (1.0 - y) + bottom * y
    rgb = np.repeat(rgb, width, axis=1)
    alpha = np.full((height, width, 1), 255, dtype=np.float32)
    scene = Image.fromarray(np.concatenate([rgb, alpha], axis=2).astype(np.uint8), "RGBA")
    draw = ImageDraw.Draw(scene, "RGBA")

    # Sparse stars.
    stars = np.random.default_rng(SEED + 1)
    for index in range(72):
        x = int(stars.uniform(0, width))
        yy = int(stars.uniform(10, height * 0.58))
        radius = 1 if index % 5 else 2
        opacity = int(stars.uniform(90, 220))
        draw.ellipse((x - radius, yy - radius, x + radius, yy + radius), fill=(145, 238, 255, opacity))

    # Sun and glow on a separate layer.
    glow = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow, "RGBA")
    sx, sy = int(width * 0.78), int(height * 0.27)
    for radius, opacity, color in [
        (84, 24, (61, 210, 232)),
        (58, 38, (255, 92, 147)),
        (33, 230, (255, 92, 147)),
        (25, 245, (255, 190, 103)),
    ]:
        gdraw.ellipse((sx - radius, sy - radius, sx + radius, sy + radius), fill=(*color, opacity))
    glow = glow.filter(ImageFilter.GaussianBlur(16))
    scene = Image.alpha_composite(scene, glow)
    draw = ImageDraw.Draw(scene, "RGBA")
    draw.ellipse((sx - 29, sy - 29, sx + 29, sy + 29), fill=(255, 91, 145, 250))
    draw.ellipse((sx - 22, sy - 26, sx + 22, sy + 18), fill=(255, 200, 111, 230))

    # Mountains.
    draw.polygon([(0, 258), (118, 139), (222, 258)], fill=(21, 17, 58, 255))
    draw.polygon([(120, 258), (294, 112), (438, 258)], fill=(24, 19, 67, 255))
    draw.polygon([(350, 258), (500, 146), (640, 258)], fill=(19, 16, 55, 255))
    draw.polygon([(0, 278), (154, 186), (286, 278)], fill=(34, 27, 86, 255))
    draw.polygon([(230, 278), (414, 164), (594, 278)], fill=(39, 30, 94, 255))
    draw.polygon([(470, 278), (572, 205), (640, 278)], fill=(34, 27, 85, 255))

    # Perspective grid.
    horizon = 246
    for index in range(15):
        t = index / 14
        gy = int(horizon + (height - horizon) * t * t)
        draw.line((0, gy, width, gy), fill=(61, 210, 232, 44), width=1)
    for index in range(-14, 15):
        xb = int(width / 2 + index * 52)
        draw.line((width / 2, horizon, xb, height), fill=(61, 210, 232, 42), width=1)

    # Floating lights.
    for index, (x, yy, color) in enumerate([
        (84, 205, (124, 245, 233)),
        (164, 236, (255, 209, 102)),
        (485, 214, (124, 245, 233)),
        (548, 254, (255, 92, 147)),
    ]):
        radius = 7 + index % 3
        light = Image.new("RGBA", SIZE, (0, 0, 0, 0))
        ldraw = ImageDraw.Draw(light, "RGBA")
        ldraw.ellipse((x - radius * 4, yy - radius * 4, x + radius * 4, yy + radius * 4), fill=(*color, 45))
        light = light.filter(ImageFilter.GaussianBlur(radius * 2))
        scene = Image.alpha_composite(scene, light)
        ImageDraw.Draw(scene, "RGBA").ellipse((x - radius, yy - radius, x + radius, yy + radius), fill=(*color, 225))

    # Subtle noise texture keeps grain and blur previews legible.
    array = np.asarray(scene).astype(np.int16)
    noise = np.random.default_rng(SEED + 2).normal(0, 1.2, (height, width, 1))
    array[:, :, :3] = np.clip(array[:, :, :3] + noise, 0, 255)
    return Image.fromarray(array.astype(np.uint8), "RGBA")


def make_robot(scale: int = 2) -> Image.Image:
    size = 128 * scale
    robot = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(robot, "RGBA")

    def rect(box, fill, radius=0):
        box = tuple(int(v * scale) for v in box)
        if radius:
            draw.rounded_rectangle(box, radius=radius * scale, fill=fill)
        else:
            draw.rectangle(box, fill=fill)

    draw.ellipse(tuple(v * scale for v in (29, 97, 99, 113)), fill=(12, 7, 31, 105))
    rect((36, 39, 92, 91), hex_color("#1c1638"), 8)
    rect((43, 28, 85, 47), hex_color("#1c1638"), 5)
    rect((31, 49, 39, 77), hex_color("#1c1638"), 3)
    rect((89, 49, 97, 77), hex_color("#1c1638"), 3)
    rect((40, 43, 88, 87), hex_color("#3dd2e8"), 6)
    rect((47, 32, 81, 45), hex_color("#3dd2e8"), 3)
    rect((34, 53, 41, 71), hex_color("#3dd2e8"), 2)
    rect((87, 53, 94, 71), hex_color("#3dd2e8"), 2)
    rect((45, 47, 83, 59), hex_color("#7cf5e9"), 3)
    rect((49, 66, 79, 80), hex_color("#7cf5e9"), 3)
    rect((51, 50, 58, 56), hex_color("#ff5c93"), 2)
    rect((70, 50, 77, 56), hex_color("#ff5c93"), 2)
    rect((59, 70, 69, 76), hex_color("#ff5c93"), 2)
    rect((53, 51, 56, 54), hex_color("#f8f2ff"))
    rect((72, 51, 75, 54), hex_color("#f8f2ff"))
    rect((47, 88, 60, 100), hex_color("#1c1638"), 3)
    rect((68, 88, 81, 100), hex_color("#1c1638"), 3)
    rect((61, 22, 67, 32), hex_color("#1c1638"), 2)
    draw.ellipse(tuple(v * scale for v in (60, 17, 68, 25)), fill=hex_color("#ffd166"))
    return robot


def place_robot(scene: Image.Image, robot: Image.Image | None = None) -> Image.Image:
    result = scene.copy()
    robot = robot or make_robot(2)
    x = (result.width - robot.width) // 2
    y = int(result.height * 0.47) - robot.height // 2
    result.alpha_composite(robot, (x, y))
    return result


def outline_sprite(sprite: Image.Image) -> Image.Image:
    alpha = sprite.getchannel("A")
    expanded = alpha.filter(ImageFilter.MaxFilter(17))
    outline_mask = ImageChops.subtract(expanded, alpha)
    layer = Image.new("RGBA", sprite.size, hex_color("#ffd166"))
    layer.putalpha(outline_mask.point(lambda p: min(255, int(p * 1.4))))
    return Image.alpha_composite(layer, sprite)


def hit_flash_sprite(sprite: Image.Image) -> Image.Image:
    array = np.asarray(sprite).copy().astype(np.float32)
    alpha = array[:, :, 3:4] / 255.0
    flash = np.array([255, 244, 198], dtype=np.float32)
    amount = 0.78
    array[:, :, :3] = array[:, :, :3] * (1 - amount * alpha) + flash * amount * alpha
    return Image.fromarray(np.clip(array, 0, 255).astype(np.uint8), "RGBA")


def value_noise(width: int, height: int, cells: int = 14) -> np.ndarray:
    rng = np.random.default_rng(SEED + 11)
    grid = (rng.random((cells + 1, cells + 1)) * 255).astype(np.uint8)
    small = Image.fromarray(grid, "L")
    return np.asarray(small.resize((width, height), Image.Resampling.BICUBIC)).astype(np.float32) / 255.0


def dissolve_sprite(sprite: Image.Image) -> Image.Image:
    array = np.asarray(sprite).copy()
    alpha = array[:, :, 3].astype(np.float32) / 255.0
    noise = value_noise(sprite.width, sprite.height)
    threshold = 0.49
    softness = 0.04
    visible = np.clip((noise - threshold + softness) / (2 * softness), 0, 1)
    edge = np.clip(1 - np.abs(noise - threshold) / 0.10, 0, 1) * (noise >= threshold)
    edge_color = np.array([90, 245, 255], dtype=np.float32)
    rgb = array[:, :, :3].astype(np.float32)
    rgb = rgb * (1 - edge[:, :, None]) + edge_color * edge[:, :, None]
    array[:, :, :3] = np.clip(rgb, 0, 255).astype(np.uint8)
    array[:, :, 3] = np.clip(alpha * visible * 255, 0, 255).astype(np.uint8)
    return Image.fromarray(array, "RGBA")


def wave_sprite(sprite: Image.Image) -> Image.Image:
    source = np.asarray(sprite)
    output = np.zeros_like(source)
    height, width = source.shape[:2]
    for yy in range(height):
        shift = int(round(math.sin(yy / 13.0) * 8))
        if shift >= 0:
            output[yy, shift:] = source[yy, :width - shift]
        else:
            output[yy, :width + shift] = source[yy, -shift:]
    return Image.fromarray(output, "RGBA")


def silhouette_sprite(sprite: Image.Image) -> Image.Image:
    layer = Image.new("RGBA", sprite.size, hex_color("#5a2a94", 225))
    layer.putalpha(sprite.getchannel("A"))
    return layer


def color_replace_sprite(sprite: Image.Image) -> Image.Image:
    array = np.asarray(sprite).copy().astype(np.float32)
    target = np.array([61, 210, 232], dtype=np.float32)
    replacement = np.array([255, 92, 147], dtype=np.float32)
    distance = np.linalg.norm(array[:, :, :3] - target, axis=2)
    match = np.clip((95 - distance) / 55, 0, 1)[:, :, None]
    array[:, :, :3] = array[:, :, :3] * (1 - match) + replacement * match
    return Image.fromarray(np.clip(array, 0, 255).astype(np.uint8), "RGBA")


def pixelate(image: Image.Image, block: int = 8) -> Image.Image:
    small = image.resize((max(1, image.width // block), max(1, image.height // block)), Image.Resampling.BILINEAR)
    return small.resize(image.size, Image.Resampling.NEAREST)


def vignette(image: Image.Image, strength: float = 0.80) -> Image.Image:
    array = np.asarray(image).copy().astype(np.float32)
    yy, xx = np.mgrid[0:image.height, 0:image.width]
    nx = (xx - image.width / 2) / (image.width / 2)
    ny = (yy - image.height / 2) / (image.height / 2)
    distance = np.sqrt(nx * nx + ny * ny)
    mask = np.clip((distance - 0.42) / 0.62, 0, 1) * strength
    tint = np.array([7, 4, 22], dtype=np.float32)
    array[:, :, :3] = array[:, :, :3] * (1 - mask[:, :, None]) + tint * mask[:, :, None]
    return Image.fromarray(np.clip(array, 0, 255).astype(np.uint8), "RGBA")


def shift_channel(channel: np.ndarray, dx: int, dy: int = 0) -> np.ndarray:
    output = np.zeros_like(channel)
    y1_src = max(0, -dy)
    y2_src = channel.shape[0] - max(0, dy)
    x1_src = max(0, -dx)
    x2_src = channel.shape[1] - max(0, dx)
    y1_dst = max(0, dy)
    y2_dst = y1_dst + (y2_src - y1_src)
    x1_dst = max(0, dx)
    x2_dst = x1_dst + (x2_src - x1_src)
    output[y1_dst:y2_dst, x1_dst:x2_dst] = channel[y1_src:y2_src, x1_src:x2_src]
    return output


def chromatic(image: Image.Image, amount: int = 5) -> Image.Image:
    array = np.asarray(image).copy()
    output = array.copy()
    output[:, :, 0] = shift_channel(array[:, :, 0], amount, 1)
    output[:, :, 2] = shift_channel(array[:, :, 2], -amount, -1)
    return Image.fromarray(output, "RGBA")


def scanlines(image: Image.Image, strength: float = 0.32, spacing: int = 4) -> Image.Image:
    array = np.asarray(image).copy().astype(np.float32)
    for yy in range(image.height):
        phase = (math.sin(yy * math.tau / spacing) + 1) / 2
        factor = 1 - strength * (1 - phase)
        array[yy, :, :3] *= factor
    return Image.fromarray(np.clip(array, 0, 255).astype(np.uint8), "RGBA")


def film_grain(image: Image.Image) -> Image.Image:
    array = np.asarray(image).copy().astype(np.int16)
    noise = np.random.default_rng(SEED + 33).normal(0, 14, (image.height, image.width, 1))
    array[:, :, :3] = np.clip(array[:, :, :3] + noise, 0, 255)
    return Image.fromarray(array.astype(np.uint8), "RGBA")


def directional_blur(image: Image.Image, radius: int = 10) -> Image.Image:
    accum = np.zeros((image.height, image.width, 4), dtype=np.float32)
    weights = np.array([1, 2, 3, 4, 3, 2, 1], dtype=np.float32)
    weights /= weights.sum()
    for index, weight in enumerate(weights):
        offset = int(round((index - 3) / 3 * radius))
        shifted = ImageChops.offset(image, offset, int(offset * 0.22))
        accum += np.asarray(shifted).astype(np.float32) * weight
    return Image.fromarray(np.clip(accum, 0, 255).astype(np.uint8), "RGBA")


def bloom(image: Image.Image) -> Image.Image:
    array = np.asarray(image).astype(np.float32)
    luminance = array[:, :, :3] @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
    mask = np.clip((luminance - 145) / 85, 0, 1)[:, :, None]
    bright = np.zeros_like(array)
    bright[:, :, :3] = array[:, :, :3] * mask
    bright[:, :, 3] = 255
    glow = Image.fromarray(np.clip(bright, 0, 255).astype(np.uint8), "RGBA").filter(ImageFilter.GaussianBlur(13))
    base = np.asarray(image).astype(np.float32)
    glow_array = np.asarray(glow).astype(np.float32)
    base[:, :, :3] = np.clip(base[:, :, :3] + glow_array[:, :, :3] * 0.95, 0, 255)
    return Image.fromarray(base.astype(np.uint8), "RGBA")


def grayscale(image: Image.Image) -> Image.Image:
    array = np.asarray(image).copy().astype(np.float32)
    lum = array[:, :, :3] @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
    array[:, :, :3] = lum[:, :, None]
    return Image.fromarray(array.astype(np.uint8), "RGBA")


def posterize(image: Image.Image, levels: int = 5) -> Image.Image:
    array = np.asarray(image).copy().astype(np.float32)
    array[:, :, :3] = np.round(array[:, :, :3] / 255 * (levels - 1)) / (levels - 1) * 255
    return Image.fromarray(np.clip(array, 0, 255).astype(np.uint8), "RGBA")


def radial_wipe(image: Image.Image) -> Image.Image:
    array = np.asarray(image).copy()
    yy, xx = np.mgrid[0:image.height, 0:image.width]
    center_x, center_y = image.width * 0.50, image.height * 0.52
    dist = np.sqrt((xx - center_x) ** 2 + (yy - center_y) ** 2)
    max_dist = math.sqrt(max(center_x, image.width - center_x) ** 2 + max(center_y, image.height - center_y) ** 2)
    normalized = dist / max_dist
    progress, softness, edge_width = 0.63, 0.025, 0.055
    visible = np.clip((progress + softness - normalized) / softness, 0, 1)
    edge = np.clip(1 - np.abs(normalized - progress) / edge_width, 0, 1) * visible
    edge_color = np.array([102, 245, 255], dtype=np.float32)
    rgb = array[:, :, :3].astype(np.float32)
    rgb = rgb * (1 - edge[:, :, None]) + edge_color * edge[:, :, None]
    array[:, :, :3] = np.clip(rgb, 0, 255).astype(np.uint8)
    background = np.array([8, 7, 24], dtype=np.float32)
    composed = array[:, :, :3] * visible[:, :, None] + background * (1 - visible[:, :, None])
    array[:, :, :3] = np.clip(composed, 0, 255).astype(np.uint8)
    return Image.fromarray(array, "RGBA")


def glitch(image: Image.Image) -> Image.Image:
    array = np.asarray(image).copy()
    output = array.copy()
    rng = np.random.default_rng(SEED + 44)
    for _ in range(18):
        y = int(rng.integers(0, image.height - 3))
        height = int(rng.integers(2, 16))
        shift = int(rng.integers(-34, 35))
        y2 = min(image.height, y + height)
        output[y:y2] = np.roll(array[y:y2], shift, axis=1)
    glitched = Image.fromarray(output, "RGBA")
    return chromatic(glitched, 4)


def crt(image: Image.Image) -> Image.Image:
    result = chromatic(image, 2)
    result = scanlines(result, 0.26, 4)
    result = vignette(result, 0.72)
    # Slight horizontal dark bands mimic display roll without obscuring content.
    array = np.asarray(result).copy().astype(np.float32)
    yy = np.arange(result.height)[:, None]
    roll = 0.96 + 0.04 * np.sin(yy / 19.0)
    array[:, :, :3] *= roll[:, :, None]
    return Image.fromarray(np.clip(array, 0, 255).astype(np.uint8), "RGBA")


def sprite_preview(scene: Image.Image, transform) -> Image.Image:
    sprite = make_robot(2)
    transformed = transform(sprite)
    return place_robot(scene, transformed)


def build_previews() -> dict[str, Image.Image]:
    scene = make_scene()
    full = place_robot(scene)
    previews = {
        "outline": sprite_preview(scene, outline_sprite),
        "hit-flash": sprite_preview(scene, hit_flash_sprite),
        "dissolve": sprite_preview(scene, dissolve_sprite),
        "wave": sprite_preview(scene, wave_sprite),
        "silhouette": sprite_preview(scene, silhouette_sprite),
        "color-replace": sprite_preview(scene, color_replace_sprite),
        "pixelate": pixelate(full, 9),
        "vignette": vignette(full),
        "chromatic-aberration": chromatic(full, 6),
        "scanlines": scanlines(full),
        "crt": crt(full),
        "film-grain": film_grain(full),
        "directional-blur": directional_blur(full, 13),
        "bloom": bloom(full),
        "grayscale": grayscale(full),
        "posterize": posterize(full, 5),
        "radial-wipe": radial_wipe(full),
        "glitch": glitch(full),
    }
    return previews


def rounded_card(image: Image.Image, width: int, radius: int = 24) -> Image.Image:
    ratio = width / image.width
    resized = image.resize((width, int(image.height * ratio)), Image.Resampling.LANCZOS)
    mask = Image.new("L", resized.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, resized.width - 1, resized.height - 1), radius=radius, fill=255)
    card = Image.new("RGBA", resized.size, (0, 0, 0, 0))
    card.paste(resized, mask=mask)
    border = Image.new("RGBA", resized.size, (0, 0, 0, 0))
    ImageDraw.Draw(border).rounded_rectangle((1, 1, resized.width - 2, resized.height - 2), radius=radius, outline=(255, 255, 255, 42), width=2)
    return Image.alpha_composite(card, border)


def make_cover(previews: dict[str, Image.Image]) -> Image.Image:
    width, height = 960, 600
    yy, xx = np.mgrid[0:height, 0:width]
    base = np.zeros((height, width, 4), dtype=np.uint8)
    base[:, :, 0] = np.clip(8 + yy / height * 8, 0, 255)
    base[:, :, 1] = np.clip(9 + yy / height * 8, 0, 255)
    base[:, :, 2] = np.clip(28 + yy / height * 26, 0, 255)
    base[:, :, 3] = 255
    cover = Image.fromarray(base, "RGBA")

    # Ambient color glows.
    glow = Image.new("RGBA", cover.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(glow, "RGBA")
    draw.ellipse((-120, 120, 520, 760), fill=(255, 92, 147, 70))
    draw.ellipse((410, -180, 1120, 520), fill=(61, 210, 232, 74))
    glow = glow.filter(ImageFilter.GaussianBlur(90))
    cover = Image.alpha_composite(cover, glow)

    cards = [
        ("crt", 520, -7, (50, 128)),
        ("dissolve", 500, 5, (400, 48)),
        ("bloom", 480, -2, (250, 308)),
    ]
    for shader_id, card_width, angle, position in cards:
        card = rounded_card(previews[shader_id], card_width)
        shadow = Image.new("RGBA", (card.width + 80, card.height + 80), (0, 0, 0, 0))
        ImageDraw.Draw(shadow).rounded_rectangle((40, 40, 40 + card.width, 40 + card.height), radius=32, fill=(0, 0, 0, 155))
        shadow = shadow.filter(ImageFilter.GaussianBlur(22)).rotate(angle, resample=Image.Resampling.BICUBIC, expand=True)
        card_rotated = card.rotate(angle, resample=Image.Resampling.BICUBIC, expand=True)
        x, y = position
        cover.alpha_composite(shadow, (x - 40, y - 30))
        cover.alpha_composite(card_rotated, (x, y))

    # Small decorative chips.
    draw = ImageDraw.Draw(cover, "RGBA")
    for x, y, color in [(86, 72, "#7cf5e9"), (112, 72, "#ff5c93"), (138, 72, "#ffd166")]:
        draw.ellipse((x - 7, y - 7, x + 7, y + 7), fill=hex_color(color, 235))
    return cover.convert("RGB")


def main() -> int:
    previews = build_previews()
    metadata_ids = {path.parent.name for path in SHADERS.glob("*/metadata.json")}
    if set(previews) != metadata_ids:
        missing = metadata_ids - set(previews)
        extra = set(previews) - metadata_ids
        raise SystemExit(f"Preview map mismatch. Missing={sorted(missing)}, extra={sorted(extra)}")

    for shader_id, image in previews.items():
        output = SHADERS / shader_id / "preview.png"
        image.convert("RGB").save(output, "PNG", optimize=True)
        print(output.relative_to(ROOT))

    cover = make_cover(previews)
    cover.save(ROOT / "docs" / "assets" / "cover.png", "PNG", optimize=True)
    print("docs/assets/cover.png")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
