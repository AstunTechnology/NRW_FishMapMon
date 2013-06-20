﻿CREATE ROLE fishmap_webapp LOGIN PASSWORD '<password>' VALID UNTIL 'infinity';

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

ALTER DEFAULT PRIVILEGES IN SCHEMA fishmap
    GRANT SELECT ON TABLES
    TO fishmap_webapp;



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

CREATE OR REPLACE FUNCTION fishmap.vessels_project_det(IN fishingname text, IN vesselcount integer, IN wkt text, IN combined boolean)
  RETURNS TABLE(ogc_fid integer, num integer, wkb_geometry geometry) AS
$BODY$
DECLARE
	tablename text;
	countfield text;
	newdata text;
	sql text;
BEGIN
	tablename := 'intensity_lvls_'|| fishingname ||'_det';
	IF fishingname = 'rsa_shore' THEN
                countfield = 'num_fisherman';
        ELSIF fishingname = 'pro_hand_gath' OR fishingname = 'cas_hand_gath' THEN
        	countfield = 'numgatherers';
        ELSE
        	countfield = '_overlaps';
        END IF;

        newdata := vesselcount::text ||' AS '|| quote_ident(countfield) ||',
		ST_GeomFromText('|| quote_literal(wkt) ||', 27700) AS wkb_geometry';
	
        IF combined THEN                                        
		sql := '
WITH project AS (
	SELECT '|| newdata ||'
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
	ELSE
		sql := 'SELECT 1, '|| newdata ||';';
	END IF;

	RETURN QUERY EXECUTE sql;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION fishmap.vessels_project_det(text, integer, text, boolean)
  OWNER TO fishmap_webapp;


CREATE OR REPLACE FUNCTION fishmap.vessels_project_gen(IN fishingname text, IN vesselcount integer, IN wkt text, IN combine boolean)
  RETURNS TABLE(ogc_fid integer, num integer, wkb_geometry geometry) AS
$BODY$
DECLARE
	tablename text;
	countfield text;
	sql text;
BEGIN
	tablename := 'intensity_lvls_'|| fishingname ||'_gen';
	IF fishingname = 'rsa_shore' THEN
		countfield = 'num_fisherman';
	ELSIF fishingname = 'pro_hand_gath' OR fishingname = 'cas_hand_gath' THEN
		countfield = 'numgatherers';
	ELSE
		countfield = '_overlaps';
	END IF;
		
	IF combine THEN
		sql := '
WITH project AS (
	SELECT '|| vesselcount::text ||' AS '|| quote_ident(countfield) ||',
		ST_GeomFromText('|| quote_literal(wkt) ||', 27700) AS wkb_geometry
), 
overlapping AS (
	SELECT 
		ogc_fid,
		'|| quote_ident(countfield) ||' + (SELECT '|| quote_ident(countfield) ||' FROM project) AS '|| quote_ident(countfield) ||', 
		wkb_geometry
	FROM '|| quote_ident(tablename) ||' AS existing
	WHERE ST_Intersects(wkb_geometry, (SELECT wkb_geometry FROM project))
),
leftovers AS (
	SELECT '|| quote_ident(countfield) ||'::int, (ST_Dump(ST_Difference(
		wkb_geometry,
		(SELECT ST_Multi(ST_Union(wkb_geometry)) FROM '|| quote_ident(tablename) ||')
	))).geom AS wkb_geometry
	FROM project
)
SELECT row_number() OVER (ORDER BY wkb_geometry)::int AS ogc_fid, '|| quote_ident(countfield) ||', wkb_geometry FROM (
	-- non-overlapping parts of existing grid squares
	SELECT '|| quote_ident(countfield) ||'::int, wkb_geometry
	FROM '|| quote_ident(tablename) ||'
	WHERE ogc_fid NOT IN (SELECT ogc_fid FROM overlapping)
	UNION 
	-- non-overlapping grid squares of project polygon
	SELECT l.'|| quote_ident(countfield) ||', g.wkb_geometry 
	FROM leftovers l, grid g
	WHERE ST_Intersects(l.wkb_geometry, g.wkb_geometry) AND NOT ST_Touches(l.wkb_geometry, g.wkb_geometry)
	UNION 
	--overlapping parts of project polygon and existing polygons
	SELECT '|| quote_ident(countfield) ||'::int, wkb_geometry FROM overlapping
) AS a;';
	ELSE
		sql := 'SELECT ogc_fid, '|| vesselcount::text ||'::int, wkb_geometry
		FROM grid
		WHERE ST_Intersects(wkb_geometry, ST_GeomFromText('|| quote_literal(wkt) ||', 27700));';
	END IF;

	RETURN QUERY EXECUTE sql;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION fishmap.vessels_project_gen(text, integer, text, boolean)
  OWNER TO fishmap_webapp;


CREATE OR REPLACE FUNCTION fishmap.calculate_intensity_hand_gath(days numeric, avghours numeric, people numeric, area numeric)
  RETURNS numeric AS
$BODY$
	SELECT ( $1 * $2 * $3 * 40 ) / ( $4 / 10000 );
	--SELECT $3/($4/10000)/($1/365);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION fishmap.calculate_intensity_hand_gath(numeric, numeric, numeric, numeric)
  OWNER TO fishmap_webapp;

CREATE OR REPLACE FUNCTION fishmap.calculate_intensity_cas_hand_gath(days numeric, avghours numeric, people numeric, area numeric)
  RETURNS numeric AS
$BODY$
	SELECT * FROM fishmap.calculate_intensity_hand_gath($1, $2 * 2.5, $3, $4);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION fishmap.calculate_intensity_cas_hand_gath(numeric, numeric, numeric, numeric)
  OWNER TO fishmap_webapp;

CREATE OR REPLACE FUNCTION fishmap.calculate_intensity_dredges(days numeric, speed numeric, hours numeric, width numeric, num numeric, area numeric)
  RETURNS numeric AS
$BODY$
	SELECT ( $2 * $3 * $4 * $5 * $1 * 1000) / $6 ;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION fishmap.calculate_intensity_dredges(numeric, numeric, numeric, numeric, numeric, numeric)
  OWNER TO fishmap_webapp;

CREATE OR REPLACE FUNCTION fishmap.calculate_intensity_fixed_pots(days numeric, anchors numeric, pots numeric, area numeric)
  RETURNS numeric AS
$BODY$
	SELECT ( ($2 + $3) * $1 / ( $4 / 10000 ) ) / 10000;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION fishmap.calculate_intensity_fixed_pots(numeric, numeric, numeric, numeric)
  OWNER TO fishmap_webapp;

CREATE OR REPLACE FUNCTION fishmap.calculate_intensity_king_scallops(days numeric, speed numeric, hours numeric, width numeric, num numeric, area numeric)
  RETURNS numeric AS
$BODY$
	SELECT * FROM fishmap.calculate_intensity_dredges( $1, $2, $3, $4, $5, $6);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION fishmap.calculate_intensity_king_scallops(numeric, numeric, numeric, numeric, numeric, numeric)
  OWNER TO fishmap_webapp;

CREATE OR REPLACE FUNCTION fishmap.calculate_intensity_lot(days numeric, speed numeric, hours numeric, width numeric, area numeric)
  RETURNS numeric AS
$BODY$
	SELECT ( $2 * $3 * $4 * $1 * 1000) / $5 ;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION fishmap.calculate_intensity_lot(numeric, numeric, numeric, numeric, numeric)
  OWNER TO fishmap_webapp;

CREATE OR REPLACE FUNCTION fishmap.calculate_intensity_mussels(days numeric, speed numeric, hours numeric, width numeric, num numeric, area numeric)
  RETURNS numeric AS
$BODY$
	SELECT * FROM fishmap.calculate_intensity_dredges( $1, $2, $3, $4, $5, $6);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION fishmap.calculate_intensity_mussels(numeric, numeric, numeric, numeric, numeric, numeric)
  OWNER TO fishmap_webapp;

CREATE OR REPLACE FUNCTION fishmap.calculate_intensity_nets(days numeric, length numeric, nets numeric, area numeric)
  RETURNS numeric AS
$BODY$
	SELECT (( $2 * $3 * $1 ) / 100 ) / ( $4 / 1000000 );
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION fishmap.calculate_intensity_nets(numeric, numeric, numeric, numeric)
  OWNER TO fishmap_webapp;

CREATE OR REPLACE FUNCTION fishmap.calculate_intensity_pro_hand_gath(days numeric, avghours numeric, people numeric, area numeric)
  RETURNS numeric AS
$BODY$
	SELECT * FROM fishmap.calculate_intensity_hand_gath($1, $2, $3, $4);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION fishmap.calculate_intensity_pro_hand_gath(numeric, numeric, numeric, numeric)
  OWNER TO fishmap_webapp;

CREATE OR REPLACE FUNCTION fishmap.calculate_intensity_queen_scallops(days numeric, speed numeric, hours numeric, width numeric, num numeric, area numeric)
  RETURNS numeric AS
$BODY$
	SELECT * FROM fishmap.calculate_intensity_dredges( $1, $2, $3, $4, $5, $6);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION fishmap.calculate_intensity_queen_scallops(numeric, numeric, numeric, numeric, numeric, numeric)
  OWNER TO fishmap_webapp;

CREATE OR REPLACE FUNCTION fishmap.calculate_intensity_rsa_charterboats(days numeric, avghours numeric, people numeric, area numeric)
  RETURNS numeric AS
$BODY$
	SELECT ( $1 * $3 * 1.5 ) / $4;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION fishmap.calculate_intensity_rsa_charterboats(numeric, numeric, numeric, numeric)
  OWNER TO fishmap_webapp;

CREATE OR REPLACE FUNCTION fishmap.calculate_intensity_rsa_commercial(days numeric, avghours numeric, rods numeric, area numeric)
  RETURNS numeric AS
$BODY$
	SELECT ( $1 * $3 * 1.5 ) / $4;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION fishmap.calculate_intensity_rsa_commercial(numeric, numeric, numeric, numeric)
  OWNER TO fishmap_webapp;

CREATE OR REPLACE FUNCTION fishmap.calculate_intensity_rsa_noncharter(days numeric, avghours numeric, num numeric, area numeric)
  RETURNS numeric AS
$BODY$
	SELECT ( $1 * $3 * ( $2 / 4 ) ) / $4;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION fishmap.calculate_intensity_rsa_noncharter(numeric, numeric, numeric, numeric)
  OWNER TO fishmap_webapp;

CREATE OR REPLACE FUNCTION fishmap.calculate_intensity_rsa_shore(days numeric, avghours numeric, people numeric, area numeric)
  RETURNS numeric AS
$BODY$
	SELECT ( $1 * $3 * ($2 / 4) ) / $4;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION fishmap.calculate_intensity_rsa_shore(numeric, numeric, numeric, numeric)
  OWNER TO fishmap_webapp;


CREATE OR REPLACE FUNCTION fishmap.project_intensity(IN fishingname text, IN intensityfield text, IN intensitylookup integer, IN intensity numeric, IN wkt text, IN generalize boolean)
  RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry geometry) AS
$BODY$
DECLARE
	tablename text;
	bounds numeric[];
	lvlcase text;
	newdata text;
	olddata text;
	sql text;
BEGIN
	tablename := 'intensity_lvls_'|| fishingname;
	SELECT rangeboundaries INTO bounds FROM fishmap.intensity_lvls;
	lvlcase = 'CASE 
	WHEN '|| quote_ident(intensityfield) ||' < '|| bounds[1] ||' THEN 1 
	WHEN '|| quote_ident(intensityfield) ||' > '|| bounds[2] ||' THEN 3 
	ELSE 2 
END';

	IF generalize THEN
		newdata := 'SELECT '|| intensity::text ||' AS '|| quote_ident(intensityfield) ||', wkb_geometry
FROM grid
WHERE 
	ST_Intersects(wkb_geometry, ST_GeomFromText('|| quote_literal(wkt) ||', 27700)) 
	AND NOT ST_Touches(wkb_geometry, ST_GeomFromText('|| quote_literal(wkt) ||', 27700))';
		olddata := quote_ident(tablename) || '_gen';
	ELSE
		newdata := 'SELECT 
			'|| intensity::text ||' AS '|| quote_ident(intensityfield) ||',
			ST_GeomFromText('|| quote_literal(wkt) ||', 27700) AS wkb_geometry';
		olddata := quote_ident(tablename) || '_det';
	END IF;

	sql := '
WITH project AS (
		'|| newdata ||'
), 
overlapping AS (
	SELECT
		ogc_fid,
     		'|| quote_ident(intensityfield) ||' + '|| intensity::text ||' AS '|| quote_ident(intensityfield) ||', 
		wkb_geometry
	FROM '|| olddata ||' AS existing
	WHERE ST_Intersects(wkb_geometry, ST_GeomFromText('|| quote_literal(wkt) ||', 27700) )
)
SELECT row_number() OVER (ORDER BY wkb_geometry)::int AS ogc_fid, intensity_level, '|| quote_ident(intensityfield) ||', wkb_geometry FROM (
	-- non-overlapping parts of existing polygons
	SELECT intensity_level::int, '|| quote_ident(intensityfield) ||', wkb_geometry
	FROM '|| olddata ||'
	WHERE ogc_fid NOT IN (SELECT ogc_fid FROM overlapping)
	UNION 
	-- non-overlapping parts of project polygon
	SELECT '|| lvlcase ||' AS intensity_level, '|| quote_ident(intensityfield) ||', (ST_Dump(ST_Difference(
		wkb_geometry,
		(SELECT ST_Multi(ST_Union(wkb_geometry)) FROM overlapping)
	))).geom AS wkb_geometry
		FROM project
	UNION 
	--overlapping parts of project polygon and existing polygons
	SELECT '|| lvlcase ||' AS intensity_level, '|| quote_ident(intensityfield) ||', wkb_geometry FROM overlapping
) AS intensities
WHERE '|| quote_ident(intensityfield) ||' > 0;';
	                                                        
        RETURN QUERY EXECUTE sql;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION fishmap.project_intensity(text, text, integer, numeric, text, boolean)
  OWNER TO fishmap_webapp;


CREATE OR REPLACE FUNCTION fishmap.project_intensity_king_scallops(IN days numeric, IN speed numeric, IN hours numeric, IN width numeric, IN num numeric, IN wkt text, IN generalize boolean)
  RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry geometry) AS
$BODY$
	SELECT * FROM fishmap.project_intensity(
		'king_scallops'::text, 
		'sum_footprint'::text, 
		1, 
		fishmap.calculate_intensity_king_scallops( $1, $2, $3, $4, $5, ST_Area(ST_GeomFromText($6))::numeric),
		$6,
		$7		
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION fishmap.project_intensity_king_scallops(numeric, numeric, numeric, numeric, numeric, text, boolean)
  OWNER TO fishmap_webapp;


CREATE OR REPLACE FUNCTION fishmap.project_intensity_cas_hand_gath(IN days numeric, IN avghours numeric, IN people numeric, IN wkt text, IN generalize boolean)
  RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry geometry) AS
$BODY$
	SELECT * FROM fishmap.project_intensity(
		'cas_hand_gath'::text, 
		'sum_footprint'::text, 
		11, 
		fishmap.calculate_intensity_cas_hand_gath( $1, $2, $3, ST_Area(ST_GeomFromText($4))::numeric),
		$4,
		$5		
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION fishmap.project_intensity_cas_hand_gath(numeric, numeric, numeric, text, boolean)
  OWNER TO fishmap_webapp;


CREATE OR REPLACE FUNCTION fishmap.project_intensity_fixed_pots(IN days numeric, IN anchors numeric, IN pots numeric, IN wkt text, IN generalize boolean)
  RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry geometry) AS
$BODY$
	SELECT * FROM fishmap.project_intensity(
		'fixed_pots'::text, 
		'sum_footprint'::text, 
		9, 
		fishmap.calculate_intensity_fixed_pots( $1, $2, $3, ST_Area(ST_GeomFromText($4))::numeric),
		$4,
		$5		
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION fishmap.project_intensity_fixed_pots(numeric, numeric, numeric, text, boolean)
  OWNER TO fishmap_webapp;


CREATE OR REPLACE FUNCTION fishmap.project_intensity_lot(IN days numeric, IN speed numeric, IN hours numeric, IN width numeric, IN wkt text, IN generalize boolean)
  RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry geometry) AS
$BODY$
	SELECT * FROM fishmap.project_intensity(
		'lot'::text, 
		'sum_footprint'::text, 
		5, 
		fishmap.calculate_intensity_lot( $1, $2, $3, $4, ST_Area(ST_GeomFromText($5))::numeric),
		$5,
		$6		
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION fishmap.project_intensity_lot(numeric, numeric, numeric, numeric, text, boolean)
  OWNER TO fishmap_webapp;


CREATE OR REPLACE FUNCTION fishmap.project_intensity_mussels(IN days numeric, IN speed numeric, IN hours numeric, IN width numeric, IN num numeric, IN wkt text, IN generalize boolean)
  RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry geometry) AS
$BODY$
	SELECT * FROM fishmap.project_intensity(
		'mussels'::text, 
		'sum_footprint'::text, 
		3, 
		fishmap.calculate_intensity_mussels( $1, $2, $3, $4, $5, ST_Area(ST_GeomFromText($6))::numeric),
		$6,
		$7		
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION fishmap.project_intensity_mussels(numeric, numeric, numeric, numeric, numeric, text, boolean)
  OWNER TO fishmap_webapp;


CREATE OR REPLACE FUNCTION fishmap.project_intensity_nets(IN days numeric, IN length numeric, IN nets numeric, IN wkt text, IN generalize boolean)
  RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry geometry) AS
$BODY$
	SELECT * FROM fishmap.project_intensity(
		'nets'::text, 
		'sum_footprint'::text, 
		8, 
		fishmap.calculate_intensity_nets( $1, $2, $3, ST_Area(ST_GeomFromText($4))::numeric),
		$4,
		$5		
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION fishmap.project_intensity_nets(numeric, numeric, numeric, text, boolean)
  OWNER TO fishmap_webapp;


CREATE OR REPLACE FUNCTION fishmap.project_intensity_pro_hand_gath(IN days numeric, IN avghours numeric, IN people numeric, IN wkt text, IN generalize boolean)
  RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry geometry) AS
$BODY$
	SELECT * FROM fishmap.project_intensity(
		'pro_hand_gath'::text, 
		'sum_footprint'::text, 
		12, 
		fishmap.calculate_intensity_pro_hand_gath( $1, $2, $3, ST_Area(ST_GeomFromText($4))::numeric),
		$4,
		$5		
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION fishmap.project_intensity_pro_hand_gath(numeric, numeric, numeric, text, boolean)
  OWNER TO fishmap_webapp;

CREATE OR REPLACE FUNCTION fishmap.project_intensity_queen_scallops(IN days numeric, IN speed numeric, IN hours numeric, IN width numeric, IN num numeric, IN wkt text, IN generalize boolean)
  RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry geometry) AS
$BODY$
	SELECT * FROM fishmap.project_intensity(
		'queen_scallops'::text, 
		'sum_footprint'::text, 
		2, 
		fishmap.calculate_intensity_queen_scallops( $1, $2, $3, $4, $5, ST_Area(ST_GeomFromText($6))::numeric),
		$6,
		$7		
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION fishmap.project_intensity_queen_scallops(numeric, numeric, numeric, numeric, numeric, text, boolean)
  OWNER TO fishmap_webapp;


CREATE OR REPLACE FUNCTION fishmap.project_intensity_rsa_charterboats(IN days numeric, IN avghours numeric, IN people numeric, IN wkt text, IN generalize boolean)
  RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry geometry) AS
$BODY$
	SELECT * FROM fishmap.project_intensity(
		'rsa_charterboats'::text, 
		'sum_footprint'::text, 
		10, 
		fishmap.calculate_intensity_rsa_charterboats( $1, $2, $3, ST_Area(ST_GeomFromText($4))::numeric),
		$4,
		$5		
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION fishmap.project_intensity_rsa_charterboats(numeric, numeric, numeric, text, boolean)
  OWNER TO fishmap_webapp;


CREATE OR REPLACE FUNCTION fishmap.project_intensity_rsa_commercial(IN days numeric, IN avghours numeric, IN rods numeric, IN wkt text, IN generalize boolean)
  RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry geometry) AS
$BODY$
	SELECT * FROM fishmap.project_intensity(
		'rsa_commercial'::text, 
		'sum_footprint'::text, 
		10, 
		fishmap.calculate_intensity_rsa_commercial( $1, $2, $3, ST_Area(ST_GeomFromText($4))::numeric),
		$4,
		$5		
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION fishmap.project_intensity_rsa_commercial(numeric, numeric, numeric, text, boolean)
  OWNER TO fishmap_webapp;


CREATE OR REPLACE FUNCTION fishmap.project_intensity_rsa_noncharter(IN days numeric, IN avghours numeric, IN num numeric, IN wkt text, IN generalize boolean)
  RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry geometry) AS
$BODY$
	SELECT * FROM fishmap.project_intensity(
		'rsa_noncharter'::text, 
		'sum_footprint'::text, 
		10, 
		fishmap.calculate_intensity_rsa_noncharter( $1, $2, $3, ST_Area(ST_GeomFromText($4))::numeric),
		$4,
		$5		
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION fishmap.project_intensity_rsa_noncharter(numeric, numeric, numeric, text, boolean)
  OWNER TO fishmap_webapp;


CREATE OR REPLACE FUNCTION fishmap.project_intensity_rsa_shore(IN days numeric, IN avghours numeric, IN people numeric, IN wkt text, IN generalize boolean)
  RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry geometry) AS
$BODY$
	SELECT * FROM fishmap.project_intensity(
		'rsa_shore'::text, 
		'sum_footprint'::text, 
		10, 
		fishmap.calculate_intensity_rsa_shore( $1, $2, $3, ST_Area(ST_GeomFromText($4))::numeric),
		$4,
		$5		
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION fishmap.project_intensity_rsa_shore(numeric, numeric, numeric, text, boolean)
  OWNER TO fishmap_webapp;


GRANT SELECT ON ALL TABLES IN SCHEMA fishmap TO fishmap_webapp;

CREATE DATABASE fishmap_auth
WITH ENCODING='UTF8'
     OWNER=postgres
     TEMPLATE=template_postgis
     CONNECTION LIMIT=-1;

\c fishmap_auth

GRANT SELECT ON ALL TABLES IN SCHEMA public TO fishmap_webapp;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
   GRANT SELECT ON TABLES TO fishmap_webapp;
