# Sponza in Balaur

https://github.com/user-attachments/assets/bb9c06ff-6c6c-4853-a7bb-a24f1ded9b26

Everything was imported automatically, except a camera, a sun, an environment and a
player. One `balaur import` did the rest.

## Running it

```sh
    python3 scripts/fetch.py                                # 50 MB, beside this repo
    balaur import ../sponza-source/Sponza.gltf --project .  # 25 materials
    python3 scripts/stage.py                                # the staging over the import
    balaur run .
```

**W A S D** to walk, mouse to look, **space** to jump.

Run `scripts/media.sh` to write an automated clip.

## What the import does

`balaur import` reads the file and writes a scene beside it. Of each of
Sponza's 25 materials it keeps:

- **Every factor and map.** Base colour, metallic, roughness, emissive, the
  normal and occlusion maps, the alpha mode and its cutoff, the index of
  refraction and the volume. Each becomes a `material` asset over one stock
  shader, `shaders/imported.wesl`.
- **One mesh node per material,** so each surface draws with its own.

Nothing is tuned. The staging names a camera, a sun, a sky, a probe
and a player, and every number those carry is the engine's own except
`shadow_distance`, which is in world units.

`scenes/sponza.toml` is that output, committed so it can be read without
running anything.

`scripts/stage.py` writes `scenes/main.toml` from it plus
the staging below.

## What the engine can do

- **Image-based lighting.** The sky lights the whole atrium; there is one
  directional light for the sun and nothing else. It replaces the flat
  ambient rather than adding to it.
- **Screen-space occlusion**, in the creases where the columns meet the floor
  and under the plinths.
- **A reflection probe** over the court, so the marble reflects the arcade
  around it rather than the sky above the building.
- **The finishing passes** on `camera.post`: bloom, a vignette, and FXAA,
  drawn in the order the list gives.

## The player, and what it collides with

```conf
    [nodes.collider3d]
    kind = "trimesh"
    mesh = "#sponza_shell"
    fix_internal_edges = true
```

That is the whole collider: the model's own triangles, no body, so it is
static geometry. `fix_internal_edges` smooths the seams between them.

The player is the editor library's own first-person rig — a capsule, a
`character3d`, and a camera on one node.


## Licence

The model is
[Sponza](https://github.com/KhronosGroup/glTF-Sample-Assets/tree/main/Models/Sponza)
from the Khronos glTF sample assets, CC BY 4.0, after the original by Frank
Meinl for Crytek. It is fetched rather than committed, and nothing here is
derived from it. Everything else in this repository is [MIT](LICENSE).
