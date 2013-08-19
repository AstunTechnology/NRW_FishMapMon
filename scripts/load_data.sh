#!/bin/bash

# Assumes that the current directory is the root of the FishMap data directory
# containing FMM_Data, HabitatLayers directories etc.

set -o errexit

if [ ! -d "./FMM_Data" ]; then
    echo "Looks like you're not in the data directory, aborting..."
    exit 1
fi

set -o verbose

# Assume LATIN1 Encoding for all input files
export PGCLIENTENCODING=LATIN1

# Project Area
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' Project_Area/PROJECT_AREA_Line.TAB -nln project_area -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# Mask
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' BaseMapping/12nm_Mask/12nm_Mask.TAB -nln mask -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# High Water (used with No Map base map)
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' BaseMapping/high_water_wales.TAB -nln high_water_wales -s_srs "EPSG:27700" -a_srs "EPSG:27700"

#1km Grid
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' 1km_Grid/1km_Sea_Grid.TAB -nln grid -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# Habitat
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "HabitatLayers/Combined_Seabed_Habitat.TAB" -nln habitats -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# Restricted Zones
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "RestrictedZones/Closed_Scallop_Fishing.TAB" -nln restricted_closed_scalloping -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "RestrictedZones/Sev_and_ reg_orders_Wales.TAB" -nln several_and_regulatory_orders -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# Detailed Fishing Activity
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Combined_tranches/CF_Polygon_Combined.TAB" -nln activity_commercial_fishing_polygon -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Combined_tranches/NCF_Point_combined.TAB" -nln activity_noncommercial_fishing_point -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Combined_tranches/NCF_Polygon_Combined.TAB" -nln activity_noncommercial_fishing_polygon -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# Mixture of polylines and multi-polylines hence the -explodecollections to get only polylines
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "BaseMapping/Hydrospatial/szSE_UK_NATIONAL_LIMITS.TAB" -nln national_limits -s_srs "EPSG:4326" -a_srs "EPSG:4326" -explodecollections

# Generic GEOMETRY as points and polygons
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "BaseMapping/Hydrospatial/szSO_WRECKS.TAB" -sql "select *, OGR_STYLE from szSO_WRECKS" -nln wrecks -s_srs "EPSG:4326" -a_srs "EPSG:4326" -nlt GEOMETRY

# Fishing Extents
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Extents/Extents_CasHandGath.TAB" -nln extents_cas_hand_gath -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Extents/Extents_KingScallops.TAB" -nln extents_king_scallops -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Extents/Extents_LOT.TAB" -nln extents_lot -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Extents/Extents Mussels.TAB" -nln extents_mussels -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Extents/Extents_Netting.TAB" -nln extents_nets -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Extents/Extents_Potting_Commercial.TAB" -nln extents_pots_commercial -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Extents/Extents_Potting_NonCommercial.TAB" -nln extents_pots_recreational -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Extents/Extents_Potting.TAB" -nln extents_pots_combined -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Extents/Extents_ProHandGath.TAB" -nln extents_pro_hand_gath -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Extents/Extents_QueenScallops.TAB" -nln extents_queen_scallops -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Extents/Extents_RSA_CB.TAB" -nln extents_rsa_charterboats -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Extents/Extents_RSA_NCB.TAB" -nln extents_rsa_noncharter -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Extents/Extents_RSA_Combined.TAB" -nln extents_rsa_combined -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Extents/Extents_RSA_Shore.TAB" -nln extents_rsa_shore -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# Intensity
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_Cas_Hand_Gath_General.tab" -nln intensity_lvls_cas_hand_gath_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_Cas_Hand_Gath.tab" -nln intensity_lvls_cas_hand_gath_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_Potting_Combined_Generalised.tab" -nln intensity_lvls_pots_combined_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_Potting_Combined.tab" -nln intensity_lvls_pots_combined_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_Pots_Commercial_General.tab" -nln intensity_lvls_pots_commercial_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_Pots_Commercial.tab" -nln intensity_lvls_pots_commercial_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_Pots_Non_Commercial_General.tab" -nln intensity_lvls_pots_recreational_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_Pots_Non_Commercial.tab" -nln intensity_lvls_pots_recreational_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_King_Scallops_General.tab" -nln intensity_lvls_king_scallops_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_King_Scallops.tab" -nln intensity_lvls_king_scallops_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_LOT_Genera.tab" -nln intensity_lvls_lot_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_LOT.tab" -nln intensity_lvls_lot_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_Mussels_General.tab" -nln intensity_lvls_mussels_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_Mussels.tab" -nln intensity_lvls_mussels_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_Nets_Generalised.tab" -nln intensity_lvls_nets_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_Nets.tab" -nln intensity_lvls_nets_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_Pro_Hand_Gath_General.tab" -nln intensity_lvls_pro_hand_gath_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_Pro_Hand_Gath.tab" -nln intensity_lvls_pro_hand_gath_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_Queen_Scallops_General.tab" -nln intensity_lvls_queen_scallops_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_Queen_Scallops.tab" -nln intensity_lvls_queen_scallops_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_RSA_CharterBoats_Generalised.tab" -nln intensity_lvls_rsa_charterboats_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_RSA_CharterBoats.tab" -nln intensity_lvls_rsa_charterboats_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_RSA_Combined_Generalised.tab" -nln intensity_lvls_rsa_combined_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_RSA_Combined.tab" -nln intensity_lvls_rsa_combined_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_RSA_nonCharter_Generalised.tab" -nln intensity_lvls_rsa_noncharter_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_RSA_nonCharter.tab" -nln intensity_lvls_rsa_noncharter_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_RSA_shore_Generalised.tab" -nln intensity_lvls_rsa_shore_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Intensity/Intensity_Lvls_RSA_shore.tab" -nln intensity_lvls_rsa_shore_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# Sensitivity
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_CasHandGather.tab" -nln sensitivity_lvls_cas_hand_gath_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_Potting_Commercial.tab" -nln sensitivity_lvls_pots_commercial_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_Potting_Recreational.tab" -nln sensitivity_lvls_pots_recreational_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_Potting_Combined.tab" -nln sensitivity_lvls_pots_combined_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_King_Scallops.tab" -nln sensitivity_lvls_king_scallops_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_LOT.tab" -nln sensitivity_lvls_lot_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_Mussels.tab" -nln sensitivity_lvls_mussels_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_Netting.tab" -nln sensitivity_lvls_nets_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_ProHandGather.tab" -nln sensitivity_lvls_pro_hand_gath_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_Queen_Scallops.tab" -nln sensitivity_lvls_queen_scallops_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_RSA_CharterBoats.tab" -nln sensitivity_lvls_rsa_charterboats_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_RSA_Combined.tab" -nln sensitivity_lvls_rsa_combined_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_RSA_nonCharterBoat.tab" -nln sensitivity_lvls_rsa_noncharter_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_RSA_Shore.tab" -nln sensitivity_lvls_rsa_shore_det -s_srs "EPSG:27700" -a_srs "EPSG:27700"

ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_CasHandGather_Generalised.tab" -nln sensitivity_lvls_cas_hand_gath_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_Potting_Commercial_Generalised.tab" -nln sensitivity_lvls_pots_commercial_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_Potting_Recreational_Generalised.tab" -nln sensitivity_lvls_pots_recreational_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_Potting_Combined_Generalised.tab" -nln sensitivity_lvls_pots_combined_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_King_Scallops_Generalised.tab" -nln sensitivity_lvls_king_scallops_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_LOT_Generalised.tab" -nln sensitivity_lvls_lot_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_Mussels_Generalised.tab" -nln sensitivity_lvls_mussels_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_Netting_Generalised.tab" -nln sensitivity_lvls_nets_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_ProHandGather_Generalised.TAB" -nln sensitivity_lvls_pro_hand_gath_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_Queen_Scallops_Generalised.tab" -nln sensitivity_lvls_queen_scallops_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_RSA_CharterBoats_Generalised.tab" -nln sensitivity_lvls_rsa_charterboats_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_RSA_Combined_Generalised.tab" -nln sensitivity_lvls_rsa_combined_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_RSA_nonCharterBoat_Generalised.tab" -nln sensitivity_lvls_rsa_noncharter_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/Sensitivity/SensitivityLvl_RSA_Shore_Generalised.tab" -nln sensitivity_lvls_rsa_shore_gen -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# Habitat Sensitivity Confidence
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/SensitivityConfidence/FMM_HandGather_Habitats_SensvtyConf.tab" -nln sensvtyconf_lvls_cas_hand_gath -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/SensitivityConfidence/FMM_LOT_Habitats_SensvtyConf.tab" -nln sensvtyconf_lvls_lot -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/SensitivityConfidence/FMM_Mussels_Habitats_SensvtyConf.tab" -nln sensvtyconf_lvls_mussels -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/SensitivityConfidence/FMM_NetsAndLines_Habitats_SensvtyConf.tab" -nln sensvtyconf_lvls_nets -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/SensitivityConfidence/FMM_Potting_Habitats_SensvtyConf.TAB" -nln sensvtyconf_lvls_combined_pots -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/SensitivityConfidence/FMM_HandGather_Habitats_SensvtyConf.tab" -nln sensvtyconf_lvls_pro_hand_gath -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/SensitivityConfidence/FMM_RSA_Habitats_SensvtyConf.tab" -nln sensvtyconf_lvls_rsa_charterboats -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/SensitivityConfidence/FMM_RSA_Habitats_SensvtyConf.tab" -nln sensvtyconf_lvls_rsa_commercial -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/SensitivityConfidence/FMM_RSA_Habitats_SensvtyConf.tab" -nln sensvtyconf_lvls_rsa_noncharter -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/SensitivityConfidence/FMM_RSA_Habitats_SensvtyConf.tab" -nln sensvtyconf_lvls_rsa_shore -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/SensitivityConfidence/FMM_Scallop_Habitats_SensvtyConf.tab" -nln sensvtyconf_lvls_queen_scallops -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -overwrite -skipfailures -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "FMM_Data/Outputs/SensitivityConfidence/FMM_Scallop_Habitats_SensvtyConf.tab" -nln sensvtyconf_lvls_king_scallops -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# Search
ogr2ogr -overwrite -skipfailures -sql "select Definitive_Name + ' - ' + County_Name as name  from os50kgaz_wales" -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "Search/OS_50kGaz/os50kgaz_wales.TAB" -nln gaz -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -append -skipfailures -sql "select Post_code as name from CodePoint_Wales_points" -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "Search/OS_CodePoints/CodePoint_Wales_points.TAB" -nln gaz -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# Protected Sites
ogr2ogr -append -skipfailures  -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "ProtectedSites/SAC_Features/SAC_features.TAB" -nln sac_features -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -append -skipfailures  -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "ProtectedSites/SAC_TAB/sac.tab" -nln sac -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -append -skipfailures  -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "ProtectedSites/SPA_TAB/spa.tab" -nln spa -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -append -skipfailures  -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "ProtectedSites/SSSI_TAB/sssi.tab" -nln sssi -s_srs "EPSG:27700" -a_srs "EPSG:27700"
ogr2ogr -append -skipfailures  -f PostgreSQL PG:'dbname=fishmap active_schema=public host=localhost user=fishmap_webapp password=<password>' "ProtectedSites/Ramsar_TAB/ramsar.tab" -nln ramsar -s_srs "EPSG:27700" -a_srs "EPSG:27700"

# NOTE: You probably need to run
# 'psql -U fishmap_webapp -d fishmap -f prepare_data.sql'
# from the scripts directory now to prepare the data you've just loaded
