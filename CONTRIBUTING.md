# Contributing

Contributions are welcome, especially small effects that are broadly useful in
2D games and can be copied into an existing LÖVE project without a dependency.

## Before opening a pull request

1. Create one folder under `shaders/<shader-id>/`.
2. Add `shader.glsl` and `metadata.json` using an existing shader as a model.
3. Use only code you wrote or code whose license is compatible and clearly
   documented. Do not submit an unattributed Shadertoy or engine port.
4. Run `python3 scripts/generate_previews.py` if the shader needs a preview,
   then run `python3 scripts/build_catalog.py`.
5. Run `python3 scripts/validate.py`.
6. Verify the shader in LÖVE 11.5. `LOVE_SHADER_KIT_VALIDATE=1 love .` compiles
   every shader and exits.

## Design expectations

- Prefer a standalone, single-pass effect when it remains useful and readable.
- Name uniforms clearly and document their units.
- Preserve alpha unless changing alpha is the purpose of the effect.
- Avoid dynamic loop bounds and desktop-only GLSL features when possible.
- Include a practical default for every uniform.
- Keep previews and descriptions representative rather than exaggerated.

By contributing, you agree that your contribution is licensed under the MIT
License used by this repository.
