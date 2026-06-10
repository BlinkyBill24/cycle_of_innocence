#!/usr/bin/env python3
"""Generate light textures for the vision system (PointLight2D needs
gradient textures): a radial glow and a forward cone.
"""
import math
from PIL import Image

SIZE = 256


def radial(falloff: float = 2.2) -> Image.Image:
    img = Image.new("L", (SIZE, SIZE), 0)
    c = SIZE / 2
    for y in range(SIZE):
        for x in range(SIZE):
            d = math.hypot(x - c, y - c) / c
            if d < 1.0:
                img.putpixel((x, y), int(255 * (1.0 - d) ** falloff))
    return img


def cone(half_angle_deg: float = 60.0, falloff: float = 1.6) -> Image.Image:
    """Cone pointing +X from the texture center."""
    img = Image.new("L", (SIZE, SIZE), 0)
    c = SIZE / 2
    half = math.radians(half_angle_deg)
    for y in range(SIZE):
        for x in range(SIZE):
            dx, dy = x - c, y - c
            d = math.hypot(dx, dy) / c
            if d >= 1.0 or d == 0.0:
                continue
            ang = abs(math.atan2(dy, dx))
            if ang > half:
                continue
            radial_part = (1.0 - d) ** falloff
            edge_part = (1.0 - ang / half) ** 0.7
            img.putpixel((x, y), int(255 * radial_part * edge_part))
    return img


radial().save("assets/sprites/light/glow_radial.png")
cone().save("assets/sprites/light/glow_cone.png")
print("wrote glow_radial.png + glow_cone.png")
