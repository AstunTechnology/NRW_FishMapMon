#!/bin/bash

# Assumes that the current directory is the root of the FishMap data directory
# containing FMM_Data, HabitatLayers directories etc.

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=postgres password=postgres' Project_Area/PROJECT_AREA.TAB -nln project_area -s_srs "EPSG:27700" -a_srs "EPSG:27700"
