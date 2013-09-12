#!/bin/bash

# Assumes that the current directory is the directory that contains a src
# directory full of tif images
#
# Therefore normally run like:
# cd data/BaseMapping/Hydrospatial/ChartedRaster/small
# ../../../../../scripts/translate.sh

if [ ! -d "./src" ]; then
	echo "No src directory found, aborting..."
	exit 1
fi

for FILE in ./src/*.tif
do
    OUTFILE=$(basename $FILE .tif)
    echo "Processing: $FILE"
    # gdal_translate -a_srs "EPSG:3395" -of PNG -co WORLDFILE=YES $FILE $OUTFILE
    gdal_translate -a_srs "EPSG:3395" -of PNG $FILE $OUTFILE.png
done
