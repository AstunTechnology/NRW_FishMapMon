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

-- Manipulate sac_features to split the lines out into seperate table and buffer
-- lines so they can be queried
DROP TABLE IF EXISTS sac_features_line;
CREATE TABLE sac_features_line AS
SELECT
    *
FROM
    sac_features
WHERE
    st_geometrytype (
        wkb_geometry )
    = 'ST_LineString';
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

