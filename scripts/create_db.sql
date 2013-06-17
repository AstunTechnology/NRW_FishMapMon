CREATE ROLE fishmap_webapp LOGIN PASSWORD '<password>' VALID UNTIL 'infinity';

CREATE DATABASE fishmap
WITH ENCODING='UTF8'
     OWNER=postgres
     TEMPLATE=template_postgis
     CONNECTION LIMIT=-1;

\c fishmap

GRANT SELECT ON ALL TABLES IN SCHEMA public TO fishmap_webapp;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
   GRANT SELECT ON TABLES TO fishmap_webapp;


CREATE SCHEMA fishmap
  AUTHORIZATION postgres;

GRANT ALL ON SCHEMA fishmap TO postgres;
GRANT ALL ON SCHEMA fishmap TO fishmap_webapp;


CREATE OR REPLACE FUNCTION fishmap.set_intensity_lvls(fishingtype int, rangeboundaries decimal[])
  RETURNS int AS
$BODY$
DECLARE
BEGIN

	CREATE TABLE IF NOT EXISTS fishmap.intensity_lvls (fishingtype int PRIMARY KEY, rangeboundaries decimal[]);
	WITH vals (fishingtype, rangeboundaries ) AS (
		VALUES (fishingtype, rangeboundaries)
	),
	upsert AS (
		UPDATE intensity_lvls l
			SET rangeboundaries = v.rangeboundaries
		FROM vals v
		WHERE l.fishingtype = v.fishingtype
		RETURNING l.*			
	)
	INSERT INTO intensity_lvls 
		SELECT v.fishingtype, v.rangeboundaries FROM vals v
	WHERE NOT EXISTS (
		SELECT 1 FROM upsert u WHERE u.fishingtype = v.fishingtype
	);
	RETURN 0;
EXCEPTION WHEN OTHERS THEN
	RETURN -1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  ;
  
CREATE TABLE IF NOT EXISTS fishmap.intensity_lvls (fishingtype int PRIMARY KEY, rangeboundaries decimal[]);
INSERT INTO fishmap.intensity_lvls VALUES 
	(1, '{0.8, 3.0}'),
	(2, '{1.35, 10.2}'),
	(3, '{0.04, 3.0}'),
	(5, '{0.93, 6.95}'),
	(8, '{33.9, 254.6}'),
	(9, '{0.073, 0.1825}'),
	(11, '{0.55, 1.83}'),
	(12, '{21.9, 73.0}'),
	(15, '{2.0, 10.0}')
;

CREATE OR REPLACE FUNCTION fishmap.vessels_project_det(fishingname text, vesselcount int, wkt text)
  RETURNS TABLE (_overlaps int, wkb_geometry geometry) AS
$BODY$
DECLARE
    tablename text;
    BEGIN
            tablename := 'intensity_lvls_'|| fishingname ||'_det';
                RETURN QUERY EXECUTE '
                    WITH project AS (
                                SELECT 
                                            '|| vesselcount::text ||' AS _overlaps,
                                                        ST_GeomFromText('|| quote_literal(wkt) ||', 27700) AS wkb_geometry
                                                            ), 
                                                                project_overlaps AS (
                                                                            SELECT 
                                                                                        _overlaps + (SELECT _overlaps FROM project) AS _overlaps, 
                                                                                                    (
                                                                                                                        ST_Dump(
                                                                                                                                                ST_Intersection(
                                                                                                                                                                            old.wkb_geometry,
                                                                                                                                                                                                    (SELECT wkb_geometry FROM project)
                                                                                                                                                                                                                        )
                                                                                                                                                                                                                                        )
                                                                                                                                                                                                                                                    ).geom AS wkb_geometry
                                                                                                                                                                                                                                                            FROM '|| quote_ident(tablename) ||' AS old
                                                                                                                                                                                                                                                                )
                                                                                                                                                                                                                                                                    -- non-overlapping parts of existing polygons
    SELECT _overlaps::int, ST_Difference(
                wkb_geometry,
                        (SELECT wkb_geometry FROM project)
                            ) AS wkb_geometry
                                FROM '|| quote_ident(tablename) ||'
                                    UNION 
                                        -- non-overlapping parts of project polygon
    SELECT _overlaps::int, ST_Difference(
                wkb_geometry,
                        (SELECT ST_Multi(ST_Union(wkb_geometry)) FROM project_overlaps)
                            ) AS wkb_geometry
                                FROM project
                                    UNION 
                                        --overlapping parts of project polygon and existing polygons
    SELECT _overlaps::int, wkb_geometry FROM project_overlaps;
        ';
    END;
    $BODY$
    LANGUAGE plpgsql ;


CREATE DATABASE fishmap_auth
WITH ENCODING='UTF8'
     OWNER=postgres
     TEMPLATE=template_postgis
     CONNECTION LIMIT=-1;

\c fishmap_auth

GRANT SELECT ON ALL TABLES IN SCHEMA public TO fishmap_webapp;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
   GRANT SELECT ON TABLES TO fishmap_webapp;
