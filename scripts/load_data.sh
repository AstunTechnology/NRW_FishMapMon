#!/bin/bash

# Assumes that the current directory is the root of the FishMap data directory
# containing FMM_Data, HabitatLayers directories etc.

# Project Area
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=postgres password=postgres' Project_Area/Project_Area_Boundaryline.TAB -nln project_area -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# Habitat
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=postgres password=postgres' "HabitatLayers/Intertidal/INTERTIDAL Fisheries Habitats.TAB" -nln intertidal_habitats -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=postgres password=postgres' "HabitatLayers/Subtidal/SUBTIDAL Fisheries Habitats.tab" -nln subtidal_habitats -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=postgres password=postgres' "HabitatLayers/Subtidal/confidencelayer.tab" -nln subtidal_habitats_confidence -s_srs "EPSG:27700" -a_srs "EPSG:27700"
