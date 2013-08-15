#!/bin/bash

# Assumes that the current directory is the directory that contains the tile
# sets (nomap, os, charts)
#
# Therefore normally run like:
# cd webapp/static/tiles/1.0.0
# ../../../../scripts/ziptiles.sh

set -o errexit

if [ ! -d "./nomap" ]; then
    echo "Looks like you're not in the tile directory, aborting..."
    exit 1
fi

set -o verbose

cd charts
7z a ../charts-0-4.7z 0 1 2 3 4
7z a ../charts-5.7z 5
7z a ../charts-6.7z 6 single_color_tiles/

cd ../nomap
7z a ../nomap-0-4.7z 0 1 2 3 4
7z a ../nomap-5.7z 5
7z a ../nomap-6.7z 6 single_color_tiles/

cd ../os
7z a ../os-0-4.7z 0 1 2 3 4
7z a ../os-5.7z 5
7z a ../os-6.7z 6 single_color_tiles/
