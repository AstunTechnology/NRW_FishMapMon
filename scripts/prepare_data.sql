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
