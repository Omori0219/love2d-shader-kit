#!/usr/bin/env python3
"""Create a .love archive containing the interactive demo and shader catalog."""

from __future__ import annotations

import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "dist" / "love2d-shader-kit-demo.love"
INCLUDE = [
    "conf.lua", "main.lua", "love_shader_kit.lua", "shader_catalog.lua",
    "demo", "shaders",
]
EXCLUDED_NAMES = {"README.md", "metadata.json", "preview.png", "usage.lua"}


def main() -> int:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(OUTPUT, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for item in INCLUDE:
            path = ROOT / item
            if path.is_file():
                archive.write(path, path.relative_to(ROOT))
                continue
            for child in sorted(path.rglob("*")):
                if child.is_file() and child.name not in EXCLUDED_NAMES:
                    archive.write(child, child.relative_to(ROOT))
    print(OUTPUT.relative_to(ROOT))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
