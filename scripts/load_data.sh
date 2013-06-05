#!/bin/bash

# Assumes that the current directory is the root of the FishMap data directory
# containing FMM_Data, HabitatLayers directories etc.

set -o errexit
set -o verbose

# Project Area
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' Project_Area/Project_Area_Boundaryline.TAB -nln project_area -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# Habitat
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "HabitatLayers/Intertidal/INTERTIDAL Fisheries Habitats.TAB" -nln intertidal_habitats -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "HabitatLayers/Subtidal/SUBTIDAL Fisheries Habitats.tab" -nln subtidal_habitats -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "HabitatLayers/Subtidal/confidencelayer.tab" -nln subtidal_habitats_confidence -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "RestrictedZones/ClosedAreas_WG_Scallop.TAB" -nln restricted_closed_scalloping -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# Explicitly set the characher encoding to match the TAB file due to symbols outside ASCII range
export PGCLIENTENCODING=LATIN1
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "RestrictedZones/Sev_and_ reg_orders_Wales_polyv_3_region.tab" -nln several_and_regulatory_orders -s_srs "EPSG:27700" -a_srs "EPSG:27700"
export PGCLIENTENCODING=UTF-8

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/RSA_Sites/RSA_sites_poly_new.TAB" -nln rsa_standing_areas -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/RSA_Sites/RSA_Sites_Casting_New.TAB" -nln rsa_casting_sites -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# Mixture of polylines and multi-polylines hence the -explodecollections to get only polylines
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "BaseMapping/Hydrospatial/szSE_UK_NATIONAL_LIMITS.TAB" -nln national_limits -s_srs "EPSG:4326" -a_srs "EPSG:4326" -explodecollections

# Generic GEOMETRY as points and polygons
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "BaseMapping/Hydrospatial/szSO_WRECKS.TAB" -sql "select *, OGR_STYLE from szSO_WRECKS" -nln wrecks -s_srs "EPSG:4326" -a_srs "EPSG:4326" -nlt GEOMETRY
# Create a buffered polygon layer for wrecks so that info is reliably returned
psql -h localhost -U fishmap_webapp -W -d fishmap -c "drop table if exists wrecks_polygon; create table wrecks_polygon as select st_buffer(st_transform(wkb_geometry, 27700), 100) as wkb_geometry, ogc_fid, classf, catwrk from wrecks where st_geometrytype(wkb_geometry) = 'ST_Point';"


# Intensity
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_Cas_Hand_Gath_General.tab" -nln intensity_lvls_cas_hand_gath_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_Cas_Hand_Gath.tab" -nln intensity_lvls_cas_hand_gath_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_Fixed_Pots_General.tab" -nln intensity_lvls_fixed_pots_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_Fixed_Pots.tab" -nln intensity_lvls_fixed_pots_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
# Ignore lines
# FMM_Data/Outputs/Intensity_Lvls_Fixed_Pots_Lines.tab

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_Foot_Access_General.tab" -nln intensity_lvls_foot_access_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_Foot_Access.tab" -nln intensity_lvls_foot_access_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_King_Scallops_General.tab" -nln intensity_lvls_king_scallops_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_King_Scallops.tab" -nln intensity_lvls_king_scallops_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_LOT_Genera.tab" -nln intensity_lvls_lot_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_LOT.tab" -nln intensity_lvls_lot_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_Mussels_General.tab" -nln intensity_lvls_mussels_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_Mussels.tab" -nln intensity_lvls_mussels_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_Nets_Polygons_generalised.tab" -nln intensity_lvls_nets_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_Nets_Polygons.tab" -nln intensity_lvls_nets_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
# Ignore lines
# FMM_Data/Outputs/Intensity_Lvls_Nets_Lines_Generalised.tab

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_Pro_Hand_Gath_General.tab" -nln intensity_lvls_pro_hand_gath_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_Pro_Hand_Gath.tab" -nln intensity_lvls_pro_hand_gath_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_Queen_Scallops_General.tab" -nln intensity_lvls_queen_scallops_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_Queen_Scallops.tab" -nln intensity_lvls_queen_scallops_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_RSA_CharterBoats_Generalised.tab" -nln intensity_lvls_rsa_charterboats_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_RSA_CharterBoats.tab" -nln intensity_lvls_rsa_charterboats_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_RSA_Comm_Generalised.tab" -nln intensity_lvls_rsa_commercial_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_RSA_Commercial.tab" -nln intensity_lvls_rsa_commercial_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_RSA_nonCharter_Generalised.tab" -nln intensity_lvls_rsa_noncharter_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_RSA_nonCharter.tab" -nln intensity_lvls_rsa_noncharter_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_RSA_shore_Generalised.tab" -nln intensity_lvls_rsa_shore_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity_Lvls_RSA_shore.tab" -nln intensity_lvls_rsa_shore_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# Sensitivity
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_CasHandGather_Generalised.tab" -nln sensitivity_lvls_cas_hand_gath -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvll_Potting_Generalised.tab" -nln sensitivity_lvls_fixed_pots -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_FootAccess_Generalised.tab" -nln sensitivity_lvls_foot_access -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvll_Scallops_Generalised.tab" -nln sensitivity_lvls_king_scallops -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvll_LOT_Generalised.tab" -nln sensitivity_lvls_lot -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvll_Mussels_Generalised.tab" -nln sensitivity_lvls_mussels -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvll_Nets_Generalised.tab" -nln sensitivity_lvls_nets -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_ProHandGather_Generalised.tab" -nln sensitivity_lvls_pro_hand_gath -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvll_Scallops_Generalised.tab" -nln sensitivity_lvls_queen_scallops -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvll_RSA_CharterBoat_Gen.tab" -nln sensitivity_lvls_rsa_charterboats -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvll_RSA_Generalised.tab" -nln sensitivity_lvls_rsa_commercial -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvll_RSA_nonCharterBoat_Gen.tab" -nln sensitivity_lvls_rsa_noncharter -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvll_RSA_Generalised.tab" -nln sensitivity_lvls_rsa_shore -s_srs "EPSG:27700" -a_srs "EPSG:27700"
