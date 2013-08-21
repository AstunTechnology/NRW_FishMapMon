-- Delete any LineStrings from the habitat and sensitivity confidence tables which where probably
-- introduced when the data was simplified. Once the data is straight we may be
-- able to remove this
DELETE FROM habitats WHERE st_geometrytype(wkb_geometry) = 'ST_LineString';
DELETE FROM sensvtyconf_lvls_cas_hand_gath WHERE st_geometrytype(wkb_geometry) = 'ST_LineString';
DELETE FROM sensvtyconf_lvls_lot WHERE st_geometrytype(wkb_geometry) = 'ST_LineString';
DELETE FROM sensvtyconf_lvls_mussels WHERE st_geometrytype(wkb_geometry) = 'ST_LineString';
DELETE FROM sensvtyconf_lvls_nets WHERE st_geometrytype(wkb_geometry) = 'ST_LineString';
DELETE FROM sensvtyconf_lvls_pots_combined WHERE st_geometrytype(wkb_geometry) = 'ST_LineString';
DELETE FROM sensvtyconf_lvls_pro_hand_gath WHERE st_geometrytype(wkb_geometry) = 'ST_LineString';
DELETE FROM sensvtyconf_lvls_rsa_charterboats WHERE st_geometrytype(wkb_geometry) = 'ST_LineString';
DELETE FROM sensvtyconf_lvls_rsa_commercial WHERE st_geometrytype(wkb_geometry) = 'ST_LineString';
DELETE FROM sensvtyconf_lvls_rsa_noncharter WHERE st_geometrytype(wkb_geometry) = 'ST_LineString';
DELETE FROM sensvtyconf_lvls_rsa_shore WHERE st_geometrytype(wkb_geometry) = 'ST_LineString';
DELETE FROM sensvtyconf_lvls_queen_scallops WHERE st_geometrytype(wkb_geometry) = 'ST_LineString';
DELETE FROM sensvtyconf_lvls_king_scallops WHERE st_geometrytype(wkb_geometry) = 'ST_LineString';

-- Break apart self-intersecting polygons and ensure all have sufficient points
UPDATE habitats
SET
    wkb_geometry = ST_Multi (
        ST_BuildArea (
            ST_Union (
                ST_Multi ( ST_Boundary ( wkb_geometry ) ),
                ST_PointN (
                    ST_Boundary ( wkb_geometry ),
                    1 ) ) ) )
WHERE
    ST_IsValid ( wkb_geometry ) = FALSE;

-- Index on habitat code for when doing lookup on this value
CREATE INDEX habitats_habitat_code_idx 
ON habitats 
USING btree (habitat_code);

-- Index on dominant habitat code for when doing lookup on this value
CREATE INDEX habitats_dominant_habitat_idx 
ON habitats 
USING btree (dominant_habitat);

-- Cluster geometry index to be more efficient on map 
-- (spatially close features will be stored together)
ALTER TABLE habitats CLUSTER ON habitats_geom_idx;

-- Manipulate sac_features to buffer lines so they can be displayed in the same
-- layer and queried
UPDATE sac_features
SET
    wkb_geometry = st_buffer (
        wkb_geometry,
        10 )
WHERE
    st_geometrytype (
        wkb_geometry )
    = 'ST_LineString';


-- Fudge all the supplied intensity data values where they've been generated using 
-- the wrong (albeit similar) formula
UPDATE intensity_lvls_pots_combined_det
SET intensity_value = intensity_value * 10000 / 365;

UPDATE intensity_lvls_pots_combined_gen
SET intensity_value = intensity_value * 10000 / 365;

UPDATE intensity_lvls_pots_commercial_det
SET intensity_value = intensity_value * 10000 / 365;

UPDATE intensity_lvls_pots_commercial_gen
SET intensity_value = intensity_value * 10000 / 365;

UPDATE intensity_lvls_pots_recreational_det
SET intensity_value = intensity_value * 10000 / 365;

UPDATE intensity_lvls_pots_recreational_gen
SET intensity_value = intensity_value * 10000 / 365;

UPDATE intensity_lvls_rsa_combined_det
SET intensity_value = intensity_value * 10000 / 52;

UPDATE intensity_lvls_rsa_combined_gen
SET intensity_value = intensity_value * 10000 / 52;

UPDATE intensity_lvls_rsa_charterboats_det
SET intensity_value = intensity_value * 10000 / 52;

UPDATE intensity_lvls_rsa_charterboats_gen
SET intensity_value = intensity_value * 10000 / 52;

UPDATE intensity_lvls_rsa_noncharter_det
SET intensity_value = intensity_value * 10000 / 52;

UPDATE intensity_lvls_rsa_noncharter_gen
SET intensity_value = intensity_value * 10000 / 52;

UPDATE intensity_lvls_rsa_shore_det
SET intensity_value = intensity_value * 10000 / 52;

UPDATE intensity_lvls_rsa_shore_gen
SET intensity_value = intensity_value * 10000 / 52;

UPDATE intensity_lvls_cas_hand_gath_det
SET intensity_value = intensity_value * 10000 / 1825;

UPDATE intensity_lvls_cas_hand_gath_gen
SET intensity_value = intensity_value * 10000 / 1825;

UPDATE intensity_lvls_pro_hand_gath_det
SET intensity_value = intensity_value * 10000 / 5475;

UPDATE intensity_lvls_pro_hand_gath_gen
SET intensity_value = intensity_value * 10000 / 5475;

-- Create views for commercial and recreational potting confidence

CREATE OR REPLACE VIEW sensvtyconf_lvls_pots_commercial AS 
 SELECT sensvtyconf_lvls_pots_combined.ogc_fid, sensvtyconf_lvls_pots_combined.wkb_geometry, sensvtyconf_lvls_pots_combined.fishingtype, sensvtyconf_lvls_pots_combined.habitat_code, sensvtyconf_lvls_pots_combined.habitat_name, sensvtyconf_lvls_pots_combined.sensitivityconfidence
   FROM sensvtyconf_lvls_pots_combined;

ALTER TABLE sensvtyconf_lvls_pots_commercial
  OWNER TO fishmap_webapp;

CREATE OR REPLACE VIEW sensvtyconf_lvls_pots_recreational AS 
 SELECT sensvtyconf_lvls_pots_combined.ogc_fid, sensvtyconf_lvls_pots_combined.wkb_geometry, sensvtyconf_lvls_pots_combined.fishingtype, sensvtyconf_lvls_pots_combined.habitat_code, sensvtyconf_lvls_pots_combined.habitat_name, sensvtyconf_lvls_pots_combined.sensitivityconfidence
   FROM sensvtyconf_lvls_pots_combined;

ALTER TABLE sensvtyconf_lvls_pots_recreational
  OWNER TO fishmap_webapp;


