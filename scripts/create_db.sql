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


DROP SCHEMA IF EXISTS fishmap CASCADE;

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


CREATE OR REPLACE FUNCTION fishmap.vessels_project_det(IN fishingname text, IN vesselcount integer, IN wkt text)
  RETURNS TABLE(ogc_fid integer, num integer, wkb_geometry geometry) AS
$BODY$
DECLARE
    tablename text;
        countfield text;
        BEGIN
                tablename := 'intensity_lvls_'|| fishingname ||'_det';
                    IF fishingname = 'rsa_shore' THEN
                                countfield = 'num_fisherman';
                                    ELSIF fishingname = 'pro_hand_gath' OR fishingname = 'cas_hand_gath' THEN
                                                countfield = 'numgatherers';
                                                    ELSE
                                                                countfield = '_overlaps';
                                                                    END IF;
                                                                        
                                                                        RETURN QUERY EXECUTE '
                                                                            WITH project AS (
                                                                                        SELECT 
                                                                                                    '|| vesselcount::text ||' AS '|| quote_ident(countfield) ||',
                                                                                                                ST_GeomFromText('|| quote_literal(wkt) ||', 27700) AS wkb_geometry
                                                                                                                    ), 
                                                                                                                        overlapping AS (
                                                                                                                                    SELECT 
                                                                                                                                                ogc_fid,
                                                                                                                                                            '|| quote_ident(countfield) ||' + (SELECT '|| quote_ident(countfield) ||' FROM project) AS '|| quote_ident(countfield) ||', 
                                                                                                                                                                        wkb_geometry
                                                                                                                                                                                FROM '|| quote_ident(tablename) ||' AS existing
                                                                                                                                                                                        WHERE ST_Intersects(wkb_geometry, (SELECT wkb_geometry FROM project))
                                                                                                                                                                                            )
                                                                                                                                                                                                SELECT row_number() OVER (ORDER BY wkb_geometry)::int AS ogc_fid, '|| quote_ident(countfield) ||', wkb_geometry FROM (
                                                                                                                                                                                                            -- non-overlapping parts of existing polygons
        SELECT '|| quote_ident(countfield) ||'::int, wkb_geometry
                FROM '|| quote_ident(tablename) ||'
                        WHERE ogc_fid NOT IN (SELECT ogc_fid FROM overlapping)
                                UNION 
                                        -- non-overlapping parts of project polygon
        SELECT '|| quote_ident(countfield) ||'::int, (ST_Dump(ST_Difference(
                                wkb_geometry,
                                            (SELECT ST_Multi(ST_Union(wkb_geometry)) FROM overlapping)
                                                    ))).geom AS wkb_geometry
                                                    FROM project
                                                            UNION 
                                                                    --overlapping parts of project polygon and existing polygons
        SELECT '|| quote_ident(countfield) ||'::int, wkb_geometry FROM overlapping
            ) AS a;';
        END;
        $BODY$
          LANGUAGE plpgsql VOLATILE
          COST 100
          ROWS 1000;
        ALTER FUNCTION fishmap.vessels_project_det(text, integer, text)
          OWNER TO fishmap_webapp;


CREATE DATABASE fishmap_auth
WITH ENCODING='UTF8'
     OWNER=postgres
     TEMPLATE=template_postgis
     CONNECTION LIMIT=-1;

\c fishmap_auth

GRANT SELECT ON ALL TABLES IN SCHEMA public TO fishmap_webapp;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
   GRANT SELECT ON TABLES TO fishmap_webapp;
