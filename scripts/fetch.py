#!/usr/bin/env python3
"""Pull the Khronos Sponza into `source/`.

The model is CC BY 4.0 and 50 MB, so it is fetched rather than committed: this
repository holds the staging and the commands, not somebody else's art."""

import concurrent.futures
import json
import pathlib
import urllib.request

LISTING = (
    "https://api.github.com/repos/KhronosGroup/glTF-Sample-Assets"
    "/contents/Models/Sponza/glTF"
)
OUT = pathlib.Path(__file__).resolve().parent.parent / "source"


def main():
    OUT.mkdir(exist_ok=True)
    with urllib.request.urlopen(LISTING) as page:
        files = json.load(page)

    def get(entry):
        urllib.request.urlretrieve(entry["download_url"], OUT / entry["name"])
        return entry["size"]

    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
        sizes = list(pool.map(get, files))
    print(f"{len(sizes)} files, {sum(sizes) / 1024 / 1024:.1f} MB into {OUT}")


if __name__ == "__main__":
    main()
