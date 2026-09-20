#!/usr/bin/env bash
# The still and the clip this repository ships, from one offscreen walk.
#
# The scene's `frames` and `shot` props name where each goes; a normal run
# leaves both empty and writes nothing. Needs a GPU and ffmpeg.
set -euo pipefail
cd "$(dirname "$0")/.."

balaur=${BALAUR:-balaur}
command -v ffmpeg >/dev/null || { echo "ffmpeg is needed (brew install ffmpeg)" >&2; exit 1; }

# `--reel <path>`: also write the walk at the full 1920x1080, for the release
# reel the website cuts. The reel concatenates by stream copy, so a clip that
# is not the frame size it works at cannot go in; the site's own copy stays
# halved, because a page carries it and the reel's source is not served.
reel=""
while [ $# -gt 0 ]; do
  case $1 in
    --reel) reel=$2; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

work=$(mktemp -d)
python3 scripts/stage.py >/dev/null

held=$(cat scenes/main.toml)
restore() { printf '%s\n' "$held" >scenes/main.toml; }
# The scene is always put back; the frames are kept when something went wrong,
# because the log beside them is the only account of it.
trap 'restore' EXIT

# One run each, because a frame carries one screenshot request: asking for the
# still and a clip frame on the same frame writes only the second.
# A fixed tick, so both runs walk the same eight seconds every time.
rm -f sponza.png
printf '%s\n' "${held/shot = \"\"/shot = \"$PWD/sponza.png\"}" >scenes/main.toml
"$balaur" run . --offscreen --fixed-tick --frames 30 >"$work/still.log" 2>&1 || true
restore
[ -f sponza.png ] || { echo "no still written; see $work/still.log" >&2; exit 1; }

printf '%s\n' "${held/frames = \"\"/frames = \"$work\"}" >scenes/main.toml
"$balaur" run . --offscreen --fixed-tick --frames 260 >"$work/run.log" 2>&1 || true
restore

ls "$work"/*.png >/dev/null 2>&1 || { echo "no frames written; see $work/run.log" >&2; exit 1; }
trap 'restore; rm -rf "$work"' EXIT
# 30 fps, the rate the frames were stepped at. The still keeps the full
# 1920x1080; the clip is halved and encoded hard, because a camera moving
# through this much detail costs an order of magnitude more than a UI clip.
#
# `flags=area` because ffmpeg's default bicubic overshoots on the way down, and
# a floor of dark grout lines comes out fringed with white. The encoders are
# given room for the same reason: at crf 32 h264 rings by forty levels around
# those lines, which is the white seam it looks like.
ffmpeg -y -loglevel error -framerate 30 -pattern_type glob -i "$work/*.png" \
  -vf scale=1280:-2:flags=area -c:v libvpx-vp9 -crf 34 -b:v 0 -pix_fmt yuv420p sponza_walk.webm
ffmpeg -y -loglevel error -framerate 30 -pattern_type glob -i "$work/*.png" \
  -vf scale=1280:-2:flags=area -c:v libx264 -crf 24 -pix_fmt yuv420p -movflags +faststart sponza_walk.mp4
if [ -n "$reel" ]; then
  mkdir -p "$(dirname "$reel")"
  ffmpeg -y -loglevel error -framerate 30 -pattern_type glob -i "$work/*.png" \
    -c:v libx264 -crf 24 -pix_fmt yuv420p -movflags +faststart "$reel"
  echo "reel source $reel ($(du -h "$reel" | cut -f1))"
fi
echo "sponza.png, sponza_walk.webm ($(du -h sponza_walk.webm | cut -f1)), sponza_walk.mp4"
