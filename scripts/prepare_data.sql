--------------------------------------------------------------------------------
-- Deaggregate habitat features so there is a simple polygon per row
DROP TABLE IF EXISTS habitats;
CREATE TABLE habitats AS
SELECT
    row_number ( )
OVER (
ORDER BY
    habitat_code,
    (
        ST_Dump (
            wkb_geometry ) )
.geom ) ::int AS ogc_fid,
habitat_code::int,
habitat_name::text,
(
    ST_Dump (
        wkb_geometry ) )
.geom AS wkb_geometry
FROM
    habitats_import;
CREATE INDEX habitats_habitat_code_idx ON habitats USING btree (
    habitat_code );
CREATE INDEX habitats_wkb_geometry_idx ON habitats USING gist (
    wkb_geometry );
ALTER TABLE habitats CLUSTER ON habitats_wkb_geometry_idx;
UPDATE habitats
SET
    wkb_geometry = ST_Multi (
        ST_BuildArea (
            ST_Union (
                ST_Multi (
                    ST_Boundary (
                        wkb_geometry ) ),
                ST_PointN (
                    ST_Boundary (
                        wkb_geometry ),
                    1 ) ) ) )
WHERE
    ST_IsValid (
        wkb_geometry )
    = FALSE;


-- Create a buffered polygon layer for wrecks so that info is reliably returned
DROP TABLE IF EXISTS wrecks_polygon;
CREATE TABLE wrecks_polygon AS
SELECT
    st_buffer (
        st_transform (
            wkb_geometry,
            27700 ),
        100 ) AS wkb_geometry,
    ogc_fid,
    classf,
    catwrk
FROM
    wrecks
WHERE
    st_geometrytype (
        wkb_geometry )
    = 'ST_Point';


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
