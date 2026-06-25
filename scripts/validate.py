#!/usr/bin/env python3
"""Validate shader folders, metadata, generated assets, and source conventions."""

from __future__ import annotations

import json
import re
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHADERS = ROOT / "shaders"
REQUIRED_KEYS = {
    "schemaVersion", "id", "name", "summary", "description", "category",
    "target", "tags", "passes", "loveVersion", "license", "notes", "uniforms",
}
VALID_CATEGORIES = {"sprite", "screen", "color", "transition"}
VALID_TARGETS = {"sprite", "screen"}
VALID_TYPES = {"float", "vec2", "vec3", "vec4"}
UNIFORM_PATTERN = re.compile(r"\bextern\s+(?:float|number|vec2|vec3|vec4)\s+([A-Za-z_][A-Za-z0-9_]*)\s*;")


def png_dimensions(path: Path) -> tuple[int, int]:
    data = path.read_bytes()[:24]
    if len(data) < 24 or data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("not a PNG")
    return struct.unpack(">II", data[16:24])


def validate() -> list[str]:
    errors: list[str] = []
    ids: set[str] = set()
    metadata_paths = sorted(SHADERS.glob("*/metadata.json"))
    if not metadata_paths:
        return ["No shaders were found."]

    for metadata_path in metadata_paths:
        folder = metadata_path.parent
        prefix = str(folder.relative_to(ROOT))
        try:
            spec = json.loads(metadata_path.read_text(encoding="utf-8"))
        except Exception as exc:
            errors.append(f"{prefix}: invalid metadata.json: {exc}")
            continue

        missing = REQUIRED_KEYS - set(spec)
        if missing:
            errors.append(f"{prefix}: missing metadata keys: {', '.join(sorted(missing))}")
        shader_id = spec.get("id")
        if shader_id != folder.name:
            errors.append(f"{prefix}: id must match folder name")
        if not isinstance(shader_id, str) or not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", shader_id or ""):
            errors.append(f"{prefix}: id must use lowercase kebab-case")
        if shader_id in ids:
            errors.append(f"{prefix}: duplicate id {shader_id}")
        ids.add(shader_id)

        if spec.get("category") not in VALID_CATEGORIES:
            errors.append(f"{prefix}: unknown category {spec.get('category')!r}")
        if spec.get("target") not in VALID_TARGETS:
            errors.append(f"{prefix}: unknown target {spec.get('target')!r}")
        if spec.get("passes") != 1:
            errors.append(f"{prefix}: this catalog currently accepts single-pass shaders only")
        if spec.get("license") != "MIT":
            errors.append(f"{prefix}: shader license must be MIT")
        if not isinstance(spec.get("tags"), list) or not spec.get("tags"):
            errors.append(f"{prefix}: tags must be a non-empty array")

        shader_path = folder / "shader.glsl"
        usage_path = folder / "usage.lua"
        readme_path = folder / "README.md"
        preview_path = folder / "preview.png"
        for required in [shader_path, usage_path, readme_path, preview_path]:
            if not required.exists():
                errors.append(f"{prefix}: missing {required.name}")

        if shader_path.exists():
            source = shader_path.read_text(encoding="utf-8")
            if "SPDX-License-Identifier: MIT" not in source:
                errors.append(f"{prefix}: shader.glsl needs an SPDX MIT header")
            if not re.search(r"\bvec4\s+effect\s*\(", source):
                errors.append(f"{prefix}: shader.glsl needs a vec4 effect function")
            if "Texel(" not in source:
                errors.append(f"{prefix}: shader.glsl must sample its source texture")

            declared = set(UNIFORM_PATTERN.findall(source))
            documented = {uniform.get("name") for uniform in spec.get("uniforms", [])}
            if declared != documented:
                missing_docs = declared - documented
                missing_code = documented - declared
                if missing_docs:
                    errors.append(f"{prefix}: undocumented uniforms: {', '.join(sorted(missing_docs))}")
                if missing_code:
                    errors.append(f"{prefix}: metadata uniforms not declared: {', '.join(sorted(missing_code))}")

        uniform_names: set[str] = set()
        for index, uniform in enumerate(spec.get("uniforms", []), start=1):
            label = f"{prefix}: uniform #{index}"
            name = uniform.get("name")
            if name in uniform_names:
                errors.append(f"{label}: duplicate name {name}")
            uniform_names.add(name)
            if uniform.get("type") not in VALID_TYPES:
                errors.append(f"{label}: unsupported type {uniform.get('type')!r}")
            for key in ["name", "type", "default", "description"]:
                if key not in uniform:
                    errors.append(f"{label}: missing {key}")
            control = uniform.get("control")
            if control:
                if uniform.get("type") != "float":
                    errors.append(f"{label}: only float uniforms can expose a control")
                if set(control) != {"min", "max", "step"}:
                    errors.append(f"{label}: control needs min, max, and step")
                elif not control["min"] <= uniform.get("default", 0) <= control["max"]:
                    errors.append(f"{label}: default is outside control range")

        if preview_path.exists():
            try:
                width, height = png_dimensions(preview_path)
                if (width, height) != (640, 360):
                    errors.append(f"{prefix}: preview.png must be 640x360, found {width}x{height}")
            except Exception as exc:
                errors.append(f"{prefix}: invalid preview.png: {exc}")

    generated_preview_ids = {path.stem for path in (ROOT / "docs" / "assets" / "previews").glob("*.png")}
    if generated_preview_ids != ids:
        errors.append("docs/assets/previews does not match the shader folders; rebuild the catalog")

    try:
        catalog = json.loads((ROOT / "docs" / "data" / "catalog.json").read_text(encoding="utf-8"))
        if [item["id"] for item in catalog] != sorted(ids):
            errors.append("docs/data/catalog.json ids are not current or sorted")
    except Exception as exc:
        errors.append(f"docs/data/catalog.json is invalid: {exc}")

    return errors


def main() -> int:
    errors = validate()
    if errors:
        print(f"Validation failed with {len(errors)} error(s):", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        return 1
    count = len(list(SHADERS.glob("*/metadata.json")))
    print(f"Validated {count} shader folders.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
