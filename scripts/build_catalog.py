#!/usr/bin/env python3
"""Build generated Lua, Markdown, and GitHub Pages catalog files."""

from __future__ import annotations

import argparse
import json
import shutil
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHADERS = ROOT / "shaders"


def load_specs() -> list[dict]:
    specs = []
    for metadata_path in sorted(SHADERS.glob("*/metadata.json")):
        spec = json.loads(metadata_path.read_text(encoding="utf-8"))
        spec["folder"] = metadata_path.parent
        spec["shaderSource"] = (metadata_path.parent / "shader.glsl").read_text(encoding="utf-8")
        spec["usageSource"] = make_usage(spec)
        specs.append(spec)
    return specs


def lua_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def lua_value(value, level: int = 0) -> str:
    if value is None:
        return "nil"
    if value is True:
        return "true"
    if value is False:
        return "false"
    if isinstance(value, (int, float)):
        return repr(value)
    if isinstance(value, str):
        return lua_string(value)
    if isinstance(value, list):
        if not value:
            return "{}"
        return "{" + ", ".join(lua_value(item, level + 1) for item in value) + "}"
    if isinstance(value, dict):
        if not value:
            return "{}"
        fields = []
        for key, item in value.items():
            if key == "folder":
                continue
            fields.append(f"{key} = {lua_value(item, level + 1)}")
        return "{" + ", ".join(fields) + "}"
    raise TypeError(type(value))


def make_usage(spec: dict) -> str:
    source_name = "image" if spec["target"] == "sprite" else "canvas"
    lines = []
    if spec["target"] == "screen":
        lines.extend([
            "-- Draw your scene to a Canvas first.",
            "local canvas = love.graphics.newCanvas()",
            "",
            "local function drawScene()",
            "    -- Draw the game world here.",
            "end",
            "",
        ])
    else:
        lines.append("-- Assume `image` is a loaded love.graphics.Image.")
        lines.append("")

    lines.append(f'local shader = love.graphics.newShader("shaders/{spec["id"]}/shader.glsl")')
    lines.append("")
    lines.append("local function updateShader()")
    for uniform in spec["uniforms"]:
        name = uniform["name"]
        source = uniform.get("source")
        if source == "time":
            value = "love.timer.getTime()"
        elif source == "texture_texel_size":
            value = f"{{1 / {source_name}:getWidth(), 1 / {source_name}:getHeight()}}"
        elif source == "texture_aspect":
            value = f"{source_name}:getWidth() / {source_name}:getHeight()"
        else:
            value = lua_value(uniform["default"])
        lines.append(f'    shader:send("{name}", {value})')
    lines.append("end")
    lines.append("")

    if spec["target"] == "screen":
        lines.extend([
            "function love.draw()",
            "    love.graphics.setCanvas(canvas)",
            "    love.graphics.clear()",
            "    drawScene()",
            "    love.graphics.setCanvas()",
            "",
            "    updateShader()",
            "    love.graphics.setShader(shader)",
            "    love.graphics.draw(canvas)",
            "    love.graphics.setShader()",
            "end",
        ])
    else:
        lines.extend([
            "function love.draw()",
            "    updateShader()",
            "    love.graphics.setShader(shader)",
            "    love.graphics.draw(image, 100, 100)",
            "    love.graphics.setShader()",
            "end",
        ])
    return "\n".join(lines) + "\n"


def make_shader_readme(spec: dict) -> str:
    lines = [
        f"# {spec['name']}",
        "",
        f"![{spec['name']} preview](preview.png)",
        "",
        spec["description"],
        "",
        f"- **Category:** `{spec['category']}`",
        f"- **Target:** `{spec['target']}`",
        f"- **Passes:** `{spec['passes']}`",
        f"- **LÖVE:** `{spec['loveVersion']}`",
        f"- **License:** `{spec['license']}`",
        "",
        "## Uniforms",
        "",
        "| Name | Type | Default | Description |",
        "|---|---|---|---|",
    ]
    for uniform in spec["uniforms"]:
        default = json.dumps(uniform["default"], ensure_ascii=False)
        lines.append(f"| `{uniform['name']}` | `{uniform['type']}` | `{default}` | {uniform['description']} |")
    if spec.get("notes"):
        lines.extend(["", "## Notes", ""])
        lines.extend(f"- {note}" for note in spec["notes"])
    lines.extend([
        "",
        "## Minimal usage",
        "",
        "```lua",
        spec["usageSource"].rstrip(),
        "```",
        "",
        "The shader source is in [`shader.glsl`](shader.glsl).",
        "",
    ])
    return "\n".join(lines)


def build_outputs(destination: Path) -> None:
    specs = load_specs()
    destination.mkdir(parents=True, exist_ok=True)

    # Lua catalog used by the desktop demo and optional helper module.
    lua_specs = []
    for spec in specs:
        item = {key: value for key, value in spec.items() if key not in {"folder", "shaderSource", "usageSource", "schemaVersion"}}
        item["path"] = f"shaders/{spec['id']}/shader.glsl"
        lua_specs.append(item)
    lua = "-- Generated by scripts/build_catalog.py. Do not edit by hand.\nreturn {\n"
    for item in lua_specs:
        lua += "    " + lua_value(item) + ",\n"
    lua += "}\n"
    (destination / "shader_catalog.lua").write_text(lua, encoding="utf-8")

    # Per-shader snippets and readmes.
    for spec in specs:
        shader_dir = destination / "shaders" / spec["id"]
        shader_dir.mkdir(parents=True, exist_ok=True)
        (shader_dir / "usage.lua").write_text(spec["usageSource"], encoding="utf-8")
        (shader_dir / "README.md").write_text(make_shader_readme(spec), encoding="utf-8")

    # Static web catalog. Sources are embedded so details work without extra requests.
    docs_data = destination / "docs" / "data"
    docs_previews = destination / "docs" / "assets" / "previews"
    docs_data.mkdir(parents=True, exist_ok=True)
    docs_previews.mkdir(parents=True, exist_ok=True)
    for stale_preview in docs_previews.glob("*.png"):
        stale_preview.unlink()
    web_catalog = []
    for spec in specs:
        item = {key: value for key, value in spec.items() if key not in {"folder", "schemaVersion"}}
        item["preview"] = f"assets/previews/{spec['id']}.png"
        web_catalog.append(item)
        source_preview = spec["folder"] / "preview.png"
        if source_preview.exists():
            shutil.copy2(source_preview, docs_previews / f"{spec['id']}.png")
    (docs_data / "catalog.json").write_text(json.dumps(web_catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def collect_generated(root: Path) -> dict[str, bytes]:
    paths = [root / "shader_catalog.lua", root / "docs" / "data" / "catalog.json"]
    paths.extend(root.glob("shaders/*/README.md"))
    paths.extend(root.glob("shaders/*/usage.lua"))
    paths.extend(root.glob("docs/assets/previews/*.png"))
    return {str(path.relative_to(root)): path.read_bytes() for path in paths if path.exists()}


def check() -> int:
    before = collect_generated(ROOT)
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_root = Path(temp_dir)
        # Copy only the source tree required by the generator, plus committed previews.
        shutil.copytree(ROOT / "shaders", temp_root / "shaders")
        build_outputs(temp_root)
        after = collect_generated(temp_root)

    changed = sorted(set(before) | set(after))
    mismatches = [path for path in changed if before.get(path) != after.get(path)]
    if mismatches:
        print("Generated files are out of date:", file=sys.stderr)
        for path in mismatches:
            print(f"  {path}", file=sys.stderr)
        print("Run: python3 scripts/build_catalog.py", file=sys.stderr)
        return 1
    print(f"Generated catalog is current ({len(load_specs())} shaders).")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="fail when generated files differ")
    args = parser.parse_args()
    if args.check:
        return check()
    build_outputs(ROOT)
    print(f"Built catalog for {len(load_specs())} shaders.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
