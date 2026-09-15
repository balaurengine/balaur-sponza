#!/usr/bin/env bash
# The still and the clip this repository ships, from one offscreen walk.
#
# The scene's `frames` and `shot` props name where each goes; a normal run
# leaves both empty and writes nothing. Needs a GPU and ffmpeg.
set -euo pipefail
cd "$(dirname "$0")/.."

balaur=${BALAUR:-balaur}
command -v ffmpeg >/dev/null || { echo "ffmpeg is needed (brew install ffmpeg)" >&2; exit 1; }

work=$(mktemp -d)
python3 scripts/stage.py >/dev/null

held=$(cat scenes/main.toml)
restore() { printf '%s\n' "$held" >scenes/main.toml; }
# The scene is always put back; the frames are kept when something went wrong,
# because the log beside them is the only account of it.
trap 'restore' EXIT
printf '%s\n' "${held//frames = \"\"/frames = \"$work\"}" >scenes/main.toml
printf '%s\n' "$(sed 's|^shot = ""$|shot = "'"$PWD"'/sponza.png"|' scenes/main.toml)" >scenes/main.toml

# A fixed tick, so the walk is the same eight seconds every run.
"$balaur" run . --offscreen --fixed-tick --frames 260 >"$work/run.log" 2>&1 || true
restore

ls "$work"/*.png >/dev/null 2>&1 || { echo "no frames written; see $work/run.log" >&2; exit 1; }
trap 'restore; rm -rf "$work"' EXIT
# 30 fps, the rate the frames were stepped at. The still keeps the full
# 1920x1080; the clip is halved and encoded hard, because a camera moving
# through this much detail costs an order of magnitude more than a UI clip.
ffmpeg -y -loglevel error -framerate 30 -pattern_type glob -i "$work/*.png" \
  -vf scale=1280:-2 -c:v libvpx-vp9 -crf 42 -b:v 0 -pix_fmt yuv420p sponza_walk.webm
ffmpeg -y -loglevel error -framerate 30 -pattern_type glob -i "$work/*.png" \
  -vf scale=1280:-2 -c:v libx264 -crf 32 -pix_fmt yuv420p -movflags +faststart sponza_walk.mp4
echo "sponza.png, sponza_walk.webm ($(du -h sponza_walk.webm | cut -f1)), sponza_walk.mp4"
