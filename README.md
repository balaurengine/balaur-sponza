# Sponza in Balaur

The scene every renderer is compared against, imported into
[Balaur](https://balaurengine.org) and lit by its own sky.

![The atrium, drawn by Balaur](sponza.png)

One `balaur import` reads the file's 25 materials, keeps each one's factors and
maps, writes a `material` asset per material and a mesh node per material, and
carries every texture's sampler across. Nothing here was authored by hand
except the camera, the sun and the environment, which `scripts/stage.py` adds.

## Running it

    python3 scripts/fetch.py                     # the model, 50 MB, into source/
    balaur import source/Sponza.gltf --project . # 25 materials, 103 primitives
    python3 scripts/stage.py                     # the camera, the sun, the sky
    balaur run .

`balaur run . --offscreen --frames 70` writes `sponza.png` without a window.

## What the picture shows

- **Image-based lighting.** The whole atrium is lit by the sky; there is one
  directional light for the sun and nothing else.
- **Screen-space occlusion.** The creases where the columns meet the floor.
- **A reflection probe** over the court, so the marble reflects the arcade
  around it rather than the sky above the building.
- **The finishing passes** on `camera.post`: bloom, a vignette, and FXAA.

## Licence

The model is
[Sponza](https://github.com/KhronosGroup/glTF-Sample-Assets/tree/main/Models/Sponza)
from the Khronos glTF sample assets, CC BY 4.0, after the original by Frank
Meinl for Crytek. It is fetched rather than committed; nothing in this
repository is derived from it. The staging scripts are MIT.
