#!/bin/bash

# Assumes that the current directory is the root of the FishMap data directory
# containing FMM_Data, HabitatLayers directories etc.

# Project Area
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=postgres password=postgres' Project_Area/Project_Area_Boundaryline.TAB -nln project_area -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# Habitat
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=postgres password=postgres' "HabitatLayers/Intertidal/INTERTIDAL Fisheries Habitats.TAB" -nln intertidal_habitats -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=postgres password=postgres' "HabitatLayers/Subtidal/SUBTIDAL Fisheries Habitats.tab" -nln subtidal_habitats -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=postgres password=postgres' "HabitatLayers/Subtidal/confidencelayer.tab" -nln subtidal_habitats_confidence -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=postgres password=postgres' "RestrictedZones/ClosedAreas_WG_Scallop.TAB" -nln restricted_closed_scalloping -s_srs "EPSG:27700" -a_srs "EPSG:27700"

export PGCLIENTENCODING=LATIN1
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=postgres password=postgres' "RestrictedZones/Sev_and_ reg_orders_Wales_polyv_3_region.tab" -nln several_and_regulatory_orders -s_srs "EPSG:27700" -a_srs "EPSG:27700"
export PGCLIENTENCODING=UTF-8
