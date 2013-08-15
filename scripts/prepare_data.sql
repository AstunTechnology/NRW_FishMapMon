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
