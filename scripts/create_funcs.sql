\c fishmap

--
-- Name: calculate_intensity__hand_gath(numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.calculate_intensity__hand_gath(days numeric, avghours numeric, people numeric, area numeric) RETURNS numeric
    LANGUAGE sql
    AS $_$
	SELECT ( ( $3 * $1 ) / 365 ) / ( $4 / 10000 );
$_$;


ALTER FUNCTION fishmap.calculate_intensity__hand_gath(days numeric, avghours numeric, people numeric, area numeric) OWNER TO fishmap_webapp;

--
-- Name: calculate_intensity_cas_hand_gath(numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.calculate_intensity_cas_hand_gath(days numeric, avghours numeric, people numeric, area numeric) RETURNS numeric
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.calculate_intensity__hand_gath($1, $2 * 2.5, $3, $4);
$_$;


ALTER FUNCTION fishmap.calculate_intensity_cas_hand_gath(days numeric, avghours numeric, people numeric, area numeric) OWNER TO fishmap_webapp;

--
-- Name: calculate_intensity_dredges(numeric, numeric, numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.calculate_intensity_dredges(days numeric, speed numeric, hours numeric, width numeric, dredges numeric, vessels numeric, area numeric) RETURNS numeric
    LANGUAGE sql
    AS $_$
	SELECT ( $2 * 1.852 * $3 * $4 * $5 * $1 * 1000 * $6 ) / $7 ;
$_$;


ALTER FUNCTION fishmap.calculate_intensity_dredges(days numeric, speed numeric, hours numeric, width numeric, dredges numeric, vessels numeric, area numeric) OWNER TO fishmap_webapp;

--
-- Name: calculate_intensity_king_scallops(numeric, numeric, numeric, numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.calculate_intensity_king_scallops(days numeric, speed numeric, hours numeric, width numeric, dredges numeric, vessels numeric, area numeric) RETURNS numeric
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.calculate_intensity_dredges( $1, $2, $3, $4, $5, $6, $7);
$_$;


ALTER FUNCTION fishmap.calculate_intensity_king_scallops(days numeric, speed numeric, hours numeric, width numeric, dredges numeric, vessels numeric, area numeric) OWNER TO fishmap_webapp;

--
-- Name: calculate_intensity_lot(numeric, numeric, numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.calculate_intensity_lot(days numeric, speed numeric, hours numeric, width numeric, vessels numeric, area numeric) RETURNS numeric
    LANGUAGE sql
    AS $_$
	SELECT ( $2 * 1.852 * $3 * $4 * $1 * 1000 * $5) / $6 ;
$_$;


ALTER FUNCTION fishmap.calculate_intensity_lot(days numeric, speed numeric, hours numeric, width numeric, vessels numeric, area numeric) OWNER TO fishmap_webapp;

--
-- Name: calculate_intensity_mussels(numeric, numeric, numeric, numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.calculate_intensity_mussels(days numeric, speed numeric, hours numeric, width numeric, dredges numeric, vessels numeric, area numeric) RETURNS numeric
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.calculate_intensity_dredges( $1, $2, $3, $4, $5, $6, $7);
$_$;


ALTER FUNCTION fishmap.calculate_intensity_mussels(days numeric, speed numeric, hours numeric, width numeric, dredges numeric, vessels numeric, area numeric) OWNER TO fishmap_webapp;

--
-- Name: calculate_intensity_nets(numeric, numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.calculate_intensity_nets(days numeric, length numeric, nets numeric, vessels numeric, area numeric) RETURNS numeric
    LANGUAGE sql
    AS $_$
	SELECT (( $2 * $3 * $1 * $4 ) / 100 ) / ( $5 / 1000000 );
$_$;


ALTER FUNCTION fishmap.calculate_intensity_nets(days numeric, length numeric, nets numeric, vessels numeric, area numeric) OWNER TO fishmap_webapp;

--
-- Name: calculate_intensity_pots(numeric, numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.calculate_intensity_pots(days numeric, anchors numeric, pots numeric, vessels numeric, area numeric) RETURNS numeric
    LANGUAGE sql
    AS $_$
	SELECT ( ( ($2 + $3) * $1 * $4 ) / ( $5 / 10000 ) ) / 365;
$_$;

ALTER FUNCTION fishmap.calculate_intensity_pots(days numeric, anchors numeric, pots numeric, vessels numeric, area numeric) owner to fishmap_webapp;

--
-- Name: calculate_intensity_pro_hand_gath(numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.calculate_intensity_pro_hand_gath(days numeric, avghours numeric, people numeric, area numeric) RETURNS numeric
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.calculate_intensity__hand_gath($1, $2, $3, $4);
$_$;


ALTER FUNCTION fishmap.calculate_intensity_pro_hand_gath(days numeric, avghours numeric, people numeric, area numeric) OWNER TO fishmap_webapp;

--
-- Name: calculate_intensity_queen_scallops(numeric, numeric, numeric, numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.calculate_intensity_queen_scallops(days numeric, speed numeric, hours numeric, width numeric, dredges numeric, vessels numeric, area numeric) RETURNS numeric
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.calculate_intensity_dredges( $1, $2, $3, $4, $5, $6, $7);
$_$;


ALTER FUNCTION fishmap.calculate_intensity_queen_scallops(days numeric, speed numeric, hours numeric, width numeric, dredges numeric, vessels numeric, area numeric) OWNER TO fishmap_webapp;

--
-- Name: calculate_intensity_rsa_charterboats(numeric, numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.calculate_intensity_rsa_charterboats(days numeric, rods numeric, avghours numeric, vessels numeric, area numeric) RETURNS numeric
    LANGUAGE sql
    AS $_$
	SELECT ( ( $2 * $1 * $4 ) / ( $5 / 10000 ) ) / 52;
$_$;


ALTER FUNCTION fishmap.calculate_intensity_rsa_charterboats(days numeric, rods numeric, avghours numeric, vessels numeric, area numeric) OWNER TO fishmap_webapp;

--
-- Name: calculate_intensity_rsa_combined(numeric, numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.calculate_intensity_rsa_combined(days numeric, rods numeric, avghours numeric, vessels numeric, area numeric) RETURNS numeric
    LANGUAGE sql
    AS $_$
	SELECT ( ( $2 * $1 * $4) / ( $5 / 10000 ) ) / 52;
$_$;


ALTER FUNCTION fishmap.calculate_intensity_rsa_combined(days numeric, rods numeric, avghours numeric, vessels numeric, area numeric) OWNER TO fishmap_webapp;

--
-- Name: calculate_intensity_rsa_noncharter(numeric, numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.calculate_intensity_rsa_noncharter(days numeric, rods numeric, avghours numeric, vessels numeric, area numeric) RETURNS numeric
    LANGUAGE sql
    AS $_$
	SELECT ( ( $2 * $1 * $4 ) / ( $5 / 10000 ) ) / 52;
$_$;


ALTER FUNCTION fishmap.calculate_intensity_rsa_noncharter(days numeric, rods numeric, avghours numeric, vessels numeric, area numeric) OWNER TO fishmap_webapp;

--
-- Name: calculate_intensity_rsa_shore(numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.calculate_intensity_rsa_shore(days numeric, rods numeric, avghours numeric, area numeric) RETURNS numeric
    LANGUAGE sql
    AS $_$
	SELECT ( ( $2 * $1 ) / ( $4 / 10000 ) ) / 52;
$_$;


ALTER FUNCTION fishmap.calculate_intensity_rsa_shore(days numeric, rods numeric, avghours numeric, area numeric) OWNER TO fishmap_webapp;

--
-- Name: project_intensity(text, integer, numeric, text, boolean, boolean); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity(fishingname text, intensitylookup integer, intensity numeric, wkt text, generalize boolean, combine boolean) RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry public.geometry)
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
	IF generalize THEN
		RETURN QUERY SELECT * FROM fishmap.project_intensity_gen(fishingname, intensitylookup, intensity, wkt, combine);
	ELSE
		RETURN QUERY SELECT * FROM fishmap.project_intensity_det(fishingname, intensitylookup, intensity, wkt, combine);
	END IF;
END;
$$;


ALTER FUNCTION fishmap.project_intensity(fishingname text, intensitylookup integer, intensity numeric, wkt text, generalize boolean, combine boolean) OWNER TO fishmap_webapp;

--
-- Name: project_intensity_cas_hand_gath(text, boolean, boolean, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_cas_hand_gath(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry public.geometry)
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.project_intensity(
		'cas_hand_gath'::text, 
		11, 
		fishmap.calculate_intensity_cas_hand_gath( $4[1], $4[2], $4[3], ST_Area(ST_GeomFromText($1))::numeric),
		$1,
		$2,
		$3	
	);
$_$;


ALTER FUNCTION fishmap.project_intensity_cas_hand_gath(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_intensity_det(text, integer, numeric, text, boolean); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_det(fishingname text, intensitylookup integer, intensity numeric, wkt text, combine boolean) RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry public.geometry)
    LANGUAGE plpgsql
    AS $$
DECLARE
	tablename text;
	bounds numeric[];
	lvlcase text;
	newdata text;
	olddata text;
	sql text;
	intensityfield text;
BEGIN
        intensityfield := 'intensity_value';
	tablename := 'intensity_lvls_'|| fishingname;
	SELECT rangeboundaries INTO bounds FROM fishmap.intensity_lvls WHERE fishingtype = intensitylookup;
	lvlcase = 'CASE 
	WHEN '|| quote_ident(intensityfield) ||' < '|| bounds[1] ||' THEN 1 
	WHEN '|| quote_ident(intensityfield) ||' > '|| bounds[2] ||' THEN 3 
	ELSE 2 
END';

    olddata := quote_ident(tablename) || '_det';

    CREATE TEMP TABLE project ON COMMIT DROP AS SELECT 
		1 AS ogc_fid,
		intensity AS intensity_value,
		ST_GeomFromText(wkt, 27700) AS wkb_geometry;

	IF combine THEN
		sql := '
WITH overlapping AS (
	SELECT
		ogc_fid,
     		'|| quote_ident(intensityfield) ||', 
		wkb_geometry
	FROM '|| olddata ||' AS existing
	WHERE ST_Intersects(wkb_geometry, ST_GeomFromText('|| quote_literal(wkt) ||', 27700) )
),
intersections AS (
	SELECT
		'|| quote_ident(intensityfield) ||' + '|| intensity::text ||' AS '|| quote_ident(intensityfield) ||', 
		ST_Intersection(wkb_geometry, (SELECT wkb_geometry FROM project)) AS wkb_geometry
	FROM overlapping
),
differences AS (
	SELECT '|| quote_ident(intensityfield) ||', 
		(ST_Dump(ST_Difference(
			wkb_geometry,
			(SELECT wkb_geometry FROM project)
		))).geom AS wkb_geometry
	FROM overlapping
)
SELECT row_number() OVER (ORDER BY wkb_geometry)::int AS ogc_fid, intensity_level, round('|| quote_ident(intensityfield) ||', 2), wkb_geometry FROM (
	-- non-overlapping existing polygons
	SELECT intensity_level::int, '|| quote_ident(intensityfield) ||', wkb_geometry
	FROM '|| olddata ||'
	WHERE ogc_fid NOT IN (SELECT ogc_fid FROM overlapping)
	UNION
	-- non-overlapping parts of overlapping existing polygons  
	SELECT '|| lvlcase ||' AS intensity_level, '|| quote_ident(intensityfield) ||', wkb_geometry FROM differences
	UNION
	-- non-overlapping parts of project polygon
	SELECT 
        '|| lvlcase ||' AS intensity_level
        , '|| quote_ident(intensityfield) ||'
        , (ST_Dump(
                COALESCE(
                    ST_Difference(
		                wkb_geometry
                        , (SELECT ST_Multi(ST_Union(wkb_geometry)) FROM overlapping)
	                )
                    , wkb_geometry
                )
        )).geom AS wkb_geometry
		FROM project
	UNION 
	--overlapping parts of project polygon and existing polygons
	SELECT '|| lvlcase ||' AS intensity_level, '|| quote_ident(intensityfield) ||', wkb_geometry FROM intersections
) AS intensities;';
	ELSE
		sql := 'SELECT ogc_fid, '|| lvlcase ||' AS intensity_level, round('|| quote_ident(intensityfield) ||', 2), wkb_geometry FROM project AS intensities;';
	END IF;
	RAISE INFO 'statement: %', sql;                                                        
        RETURN QUERY EXECUTE sql;
END;
$$;


ALTER FUNCTION fishmap.project_intensity_det(fishingname text, intensitylookup integer, intensity numeric, wkt text, combine boolean) OWNER TO fishmap_webapp;


-- Name: project_intensity_gen(text, integer, numeric, text, boolean); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_gen(fishingname text, intensitylookup integer, intensity numeric, wkt text, combine boolean) RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry public.geometry)
    LANGUAGE plpgsql
    AS $$
DECLARE
	tablename text;
	bounds numeric[];
	lvlcase text;
	newdata text;
	olddata text;
	sql text;
	intensityfield text;
BEGIN
        intensityfield := 'intensity_value';
	tablename := 'intensity_lvls_'|| fishingname;
	SELECT rangeboundaries INTO bounds FROM fishmap.intensity_lvls WHERE fishingtype = intensitylookup;
	lvlcase = 'CASE 
	WHEN '|| quote_ident(intensityfield) ||' < '|| bounds[1] ||' THEN 1 
	WHEN '|| quote_ident(intensityfield) ||' > '|| bounds[2] ||' THEN 3 
	ELSE 2 
END';

	olddata := quote_ident(tablename) || '_gen';

	CREATE TEMP TABLE project ON COMMIT DROP AS SELECT g.ogc_fid, intensity AS intensity_value, g.wkb_geometry
	FROM grid g
	WHERE 
		ST_Intersects(g.wkb_geometry, ST_GeomFromText(wkt, 27700)) 
		AND NOT ST_Touches(g.wkb_geometry, ST_GeomFromText(wkt, 27700));

	IF combine THEN
		sql := '
WITH overlapping AS (
	SELECT
		ogc_fid,
     		'|| quote_ident(intensityfield) ||' + '|| intensity::text ||' AS '|| quote_ident(intensityfield) ||', 
		wkb_geometry
	FROM '|| olddata ||' AS existing
	WHERE ST_Intersects(wkb_geometry, (SELECT ST_Multi(ST_Union(wkb_geometry)) FROM project) )
)
SELECT row_number() OVER (ORDER BY wkb_geometry)::int AS ogc_fid, intensity_level, round('|| quote_ident(intensityfield) ||', 2), wkb_geometry FROM (
	-- non-overlapping parts of existing polygons
	SELECT intensity_level::int, '|| quote_ident(intensityfield) ||', wkb_geometry
	FROM '|| olddata ||'
	WHERE ogc_fid NOT IN (SELECT ogc_fid FROM overlapping)
	UNION 
	-- non-overlapping parts of project polygon (small negative buffer to eliminate overlaps caused by rounding)
	SELECT '|| lvlcase ||' AS intensity_level, '|| quote_ident(intensityfield) ||', wkb_geometry
	FROM project
	WHERE Coalesce(ST_Disjoint(
		wkb_geometry,
		ST_Buffer(
			(SELECT ST_Multi(ST_Union(wkb_geometry)) FROM overlapping), 
			-0.1
		)
	), true)
	UNION 
	--overlapping parts of project polygon and existing polygons
	SELECT '|| lvlcase ||' AS intensity_level, '|| quote_ident(intensityfield) ||', wkb_geometry FROM overlapping
) AS intensities;';
	ELSE
		sql := 'SELECT ogc_fid, '|| lvlcase ||' AS intensity_level, round('|| quote_ident(intensityfield) ||', 2), wkb_geometry FROM project AS intensities;';
	END IF;
	RAISE INFO '%', sql;                                                 
        RETURN QUERY EXECUTE sql;
END;
$$;


ALTER FUNCTION fishmap.project_intensity_gen(fishingname text, intensitylookup integer, intensity numeric, wkt text, combine boolean) OWNER TO fishmap_webapp;

--
-- Name: project_intensity_king_scallops(text, boolean, boolean, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_king_scallops(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry public.geometry)
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.project_intensity(
		'king_scallops'::text, 
		1, 
		fishmap.calculate_intensity_king_scallops( $4[1], $4[2], $4[3], $4[4], $4[5], $4[6], ST_Area(ST_GeomFromText($1))::numeric),
		$1,
		$2,
		$3		
	);
$_$;


ALTER FUNCTION fishmap.project_intensity_king_scallops(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_intensity_lot(text, boolean, boolean, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_lot(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry public.geometry)
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.project_intensity(
		'lot'::text, 
		5, 
		fishmap.calculate_intensity_lot( $4[1], $4[2], $4[3], $4[4], $4[5], ST_Area(ST_GeomFromText($1))::numeric),
		$1,
		$2,
		$3			
	);
$_$;


ALTER FUNCTION fishmap.project_intensity_lot(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_intensity_lvls_combined_det(text, text, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_lvls_combined_det(activity text, wkt text, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, intensity_level integer, intensity_value numeric, wkb_geometry public.geometry)
    LANGUAGE plpgsql
    AS $$
DECLARE
	funcname text;
	sql text;
BEGIN
	funcname := 'project_intensity_'|| activity;
	sql := format(
		'SELECT * FROM fishmap.%I(%s, false, true, %s);', 
		funcname, 
		quote_literal(wkt), 
		(
		      SELECT string_agg(arg::text, ', ') 
		      FROM unnest(args) arg
		)
	);
	RAISE INFO '%', sql;
	RETURN QUERY EXECUTE sql;
END;
$$;


ALTER FUNCTION fishmap.project_intensity_lvls_combined_det(activity text, wkt text, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_intensity_lvls_combined_gen(text, text, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_lvls_combined_gen(activity text, wkt text, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, intensity_level integer, intensity_value numeric, wkb_geometry public.geometry)
    LANGUAGE plpgsql
    AS $$
DECLARE
	funcname text;
	sql text;
BEGIN
	funcname := 'project_intensity_'|| activity;
	sql := format(
		'SELECT * FROM fishmap.%I(%s, true, true, %s);', 
		funcname, 
		quote_literal(wkt), 
		(
		      SELECT string_agg(arg::text, ', ') 
		      FROM unnest(args) arg
		)
	);
	RAISE INFO '%', sql;
	RETURN QUERY EXECUTE sql;
END;
$$;


ALTER FUNCTION fishmap.project_intensity_lvls_combined_gen(activity text, wkt text, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_intensity_lvls_new_det(text, text, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_lvls_new_det(activity text, wkt text, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, intensity_level integer, intensity_value numeric, wkb_geometry public.geometry)
    LANGUAGE plpgsql
    AS $$
DECLARE
	funcname text;
	sql text;
BEGIN
	funcname := 'project_intensity_'|| activity;
	sql := format(
		'SELECT * FROM fishmap.%I(%s, false, false, %s);', 
		funcname, 
		quote_literal(wkt), 
		(
		      SELECT string_agg(arg::text, ', ') 
		      FROM unnest(args) arg
		)
	);
	RAISE INFO '%', sql;
	RETURN QUERY EXECUTE sql;
END;
$$;


ALTER FUNCTION fishmap.project_intensity_lvls_new_det(activity text, wkt text, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_intensity_lvls_new_gen(text, text, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_lvls_new_gen(activity text, wkt text, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, intensity_level integer, intensity_value numeric, wkb_geometry public.geometry)
    LANGUAGE plpgsql
    AS $$
DECLARE
	funcname text;
	sql text;
BEGIN
	funcname := 'project_intensity_'|| activity;
	sql := format(
		'SELECT * FROM fishmap.%I(%s, true, false, %s);', 
		funcname, 
		quote_literal(wkt), 
		(
		      SELECT string_agg(arg::text, ', ') 
		      FROM unnest(args) arg
		)
	);
	RAISE INFO '%', sql;
	RETURN QUERY EXECUTE sql;
END;
$$;


ALTER FUNCTION fishmap.project_intensity_lvls_new_gen(activity text, wkt text, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_intensity_mussels(text, boolean, boolean, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_mussels(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry public.geometry)
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.project_intensity(
		'mussels'::text, 
		3, 
		fishmap.calculate_intensity_mussels( $4[1], $4[2], $4[3], $4[4], $4[5], $4[6], ST_Area(ST_GeomFromText($1))::numeric),
		$1,
		$2,
		$3	
	);
$_$;


ALTER FUNCTION fishmap.project_intensity_mussels(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_intensity_nets(text, boolean, boolean, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_nets(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry public.geometry)
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.project_intensity(
		'nets'::text, 
		8, 
		fishmap.calculate_intensity_nets( $4[1], $4[2], $4[3], $4[4], ST_Area(ST_GeomFromText($1))::numeric),
		$1,
		$2,
		$3	
	);
$_$;


ALTER FUNCTION fishmap.project_intensity_nets(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_intensity_pots_commercial(text, boolean, boolean, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_pots_commercial(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry public.geometry)
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.project_intensity(
		'pots_commercial'::text, 
		9, 
		fishmap.calculate_intensity_pots( $4[1], $4[2], $4[3], $4[4], ST_Area(ST_GeomFromText($1))::numeric),
		$1,
		$2,
		$3		
	);
$_$;


ALTER FUNCTION fishmap.project_intensity_pots_commercial(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) OWNER TO fishmap_webapp;


--
-- Name: project_intensity_pots_recreational(text, boolean, boolean, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_pots_recreational(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry public.geometry)
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.project_intensity(
		'pots_recreational'::text, 
		9, 
		fishmap.calculate_intensity_pots( $4[1], $4[2], $4[3], $4[4], ST_Area(ST_GeomFromText($1))::numeric),
		$1,
		$2,
		$3		
	);
$_$;


ALTER FUNCTION fishmap.project_intensity_pots_recreational(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) OWNER TO fishmap_webapp;


--
-- Name: project_intensity_pots_combined(text, boolean, boolean, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_pots_combined(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry public.geometry)
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.project_intensity(
		'pots_combined'::text, 
		9, 
		fishmap.calculate_intensity_pots( $4[1], $4[2], $4[3], $4[4], ST_Area(ST_GeomFromText($1))::numeric),
		$1,
		$2,
		$3		
	);
$_$;


ALTER FUNCTION fishmap.project_intensity_pots_combined(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_intensity_pro_hand_gath(text, boolean, boolean, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_pro_hand_gath(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry public.geometry)
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.project_intensity(
		'pro_hand_gath'::text, 
		12, 
		fishmap.calculate_intensity_pro_hand_gath( $4[1], $4[2], $4[3], ST_Area(ST_GeomFromText($1))::numeric),
		$1,
		$2,
		$3	
	);
$_$;


ALTER FUNCTION fishmap.project_intensity_pro_hand_gath(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_intensity_queen_scallops(text, boolean, boolean, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_queen_scallops(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry public.geometry)
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.project_intensity(
		'queen_scallops'::text, 
		2, 
		fishmap.calculate_intensity_queen_scallops( $4[1], $4[2], $4[3], $4[4], $4[5], $4[6], ST_Area(ST_GeomFromText($1))::numeric),
		$1,
		$2,
		$3		
	);
$_$;


ALTER FUNCTION fishmap.project_intensity_queen_scallops(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_intensity_rsa_charterboats(text, boolean, boolean, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_rsa_charterboats(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry public.geometry)
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.project_intensity(
		'rsa_charterboats'::text, 
		10, 
		fishmap.calculate_intensity_rsa_charterboats( $4[1], $4[2], $4[3], $4[4], ST_Area(ST_GeomFromText($1))::numeric),
		$1,
		$2,
		$3	
	);
$_$;


ALTER FUNCTION fishmap.project_intensity_rsa_charterboats(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_intensity_rsa_combined(text, boolean, boolean, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_rsa_combined(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry public.geometry)
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.project_intensity(
		'rsa_combined'::text, 
		10, 
		fishmap.calculate_intensity_rsa_combined( $4[1], $4[2], $4[3], $4[4], ST_Area(ST_GeomFromText($1))::numeric),
		$1,
		$2,
		$3		
	);
$_$;


ALTER FUNCTION fishmap.project_intensity_rsa_combined(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_intensity_rsa_noncharter(text, boolean, boolean, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_rsa_noncharter(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry public.geometry)
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.project_intensity(
		'rsa_noncharter'::text,
		10, 
		fishmap.calculate_intensity_rsa_noncharter( $4[1], $4[2], $4[3], $4[4], ST_Area(ST_GeomFromText($1))::numeric),
		$1,
		$2,
		$3		
	);
$_$;


ALTER FUNCTION fishmap.project_intensity_rsa_noncharter(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_intensity_rsa_shore(text, boolean, boolean, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_intensity_rsa_shore(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, lvl integer, sum_intensity numeric, wkb_geometry public.geometry)
    LANGUAGE sql
    AS $_$
	SELECT * FROM fishmap.project_intensity(
		'rsa_shore'::text, 
		10, 
		fishmap.calculate_intensity_rsa_shore( $4[1], $4[2], $4[3], ST_Area(ST_GeomFromText($1))::numeric),
		$1,
		$2,
		$3		
	);
$_$;


ALTER FUNCTION fishmap.project_intensity_rsa_shore(wkt text, generalize boolean, combine boolean, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_sensitivity_lvls_combined_gen(text, text, text, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_sensitivity_lvls_combined_gen(activity_name text, wkt text, bbox text, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, habitat_code integer, habitat_name text, dominant_habitat integer, habitat_confidence character varying(20), sensitivity_level integer, intensity_level integer, wkb_geometry public.geometry)
    LANGUAGE plpgsql
    AS $_$
DECLARE
	sql text;
BEGIN

CREATE TEMP TABLE _tmp_sensitivity_levels ON COMMIT DROP AS (
    SELECT habitat_id, intensity_lvl, sensitivity_lvl
    FROM fishmap.sensitivity_matrix
    WHERE activity_id = (SELECT id FROM fishmap.activities WHERE fishmap_name = activity_name)
);
    
CREATE TEMP TABLE _tmp_sensitivity_intensities ON COMMIT DROP AS (
    SELECT 
        il.intensity_level
        , il.wkb_geometry
    FROM 
        fishmap.project_intensity_lvls_combined_gen(
            activity_name, 
            wkt, 
            VARIADIC args
        ) il
    WHERE 
        ST_Intersects(il.wkb_geometry,  ST_GeomFromText(wkt, 27700))
);

CREATE TEMP TABLE _tmp_union ON COMMIT DROP AS (
    SELECT ST_Union(
        ST_SnapToGrid(
            si.wkb_geometry
            , 0.1
        )
    ) AS wkb_geometry
    FROM _tmp_sensitivity_intensities si
);

CREATE TEMP TABLE _tmp_habitats ON COMMIT DROP AS (
    SELECT 
        h.habitat_code
        , h.habitat_name
        , h.dominant_habitat
        , h.habitat_confidence
        , ST_Intersection(
            h.wkb_geometry
            , (
                SELECT u.wkb_geometry FROM _tmp_union u
            ) 
        ) AS wkb_geometry
    FROM 
        habitats h
    WHERE
        ST_Intersects(h.wkb_geometry, (SELECT u.wkb_geometry FROM _tmp_union u))
);

sql := format('
SELECT row_number() OVER (ORDER BY wkb_geometry)::int AS ogc_fid, habitat_code, habitat_name, dominant_habitat, habitat_confidence, sensitivity_level, intensity_level, wkb_geometry FROM (
	SELECT 
        h.habitat_code
        , h.habitat_name::text
        , h.dominant_habitat
        , h.habitat_confidence
        , l.sensitivity_lvl AS sensitivity_level
        , i.intensity_level
        , h.wkb_geometry
	FROM 
        _tmp_sensitivity_intensities i
		, _tmp_habitats h
		, _tmp_sensitivity_levels l
	WHERE 
		l.habitat_id = h.dominant_habitat AND l.intensity_lvl = i.intensity_level
    UNION
    SELECT 
        habitat_code
        , habitat_name
        , dominant_habitat
        , habitat_confidence
        , sensitivity_level::integer
        , intensity_level
        , wkb_geometry
    FROM 
        %I s       
    WHERE 
        ST_Disjoint(s.wkb_geometry, ST_Buffer((SELECT u.wkb_geometry FROM _tmp_union u), -0.1)) 
) AS sensitivities;
',
'sensitivity_lvls_'||activity_name||'_gen',
wkt
);
	RAISE INFO '%', sql;
	RETURN QUERY EXECUTE sql;
END;
$_$;


ALTER FUNCTION fishmap.project_sensitivity_lvls_combined_gen(activity_name text, wkt text, bbox text, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_sensitivity_lvls_combined_det(text, text, text, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_sensitivity_lvls_combined_det(activity_name text, wkt text, bbox text, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, habitat_code integer, habitat_name text, dominant_habitat integer, habitat_confidence character varying(20),  sensitivity_level integer, intensity_level integer, wkb_geometry public.geometry)
    LANGUAGE plpgsql
    AS $_$
DECLARE
	sql text;
BEGIN

CREATE TEMP TABLE _tmp_sensitivity_levels ON COMMIT DROP AS (
    SELECT habitat_id, intensity_lvl, sensitivity_lvl
    FROM fishmap.sensitivity_matrix
    WHERE activity_id = (SELECT id FROM fishmap.activities WHERE fishmap_name = activity_name)
);  
CREATE TEMP TABLE _tmp_sensitivity_intensities ON COMMIT DROP AS (
    SELECT il.intensity_level, il.wkb_geometry
    FROM fishmap.project_intensity_lvls_combined_det(
        activity_name, 
        wkt, 
        VARIADIC args) il
    WHERE ST_Intersects(il.wkb_geometry,  ST_GeomFromText(bbox, 27700))
);
	sql := format('
SELECT row_number() OVER (ORDER BY wkb_geometry)::int AS ogc_fid, habitat_code, habitat_name::text, dominant_habitat::integer, habitat_confidence, sensitivity_level, intensity_level, wkb_geometry FROM (
	
	-- new polygons
	SELECT h.habitat_code, h.habitat_name, h.dominant_habitat, h.habitat_confidence, l.sensitivity_lvl AS sensitivity_level, i.intensity_level, ST_Intersection(i.wkb_geometry, h.wkb_geometry) AS wkb_geometry
	FROM _tmp_sensitivity_intensities i,
		habitats h,
		_tmp_sensitivity_levels l
	WHERE  l.habitat_id = h.dominant_habitat 
		AND l.intensity_lvl = i.intensity_level
		AND ST_Intersects(i.wkb_geometry, h.wkb_geometry)	
) AS sensitivities;
');
	RAISE INFO '%', sql;
	RETURN QUERY EXECUTE sql;
END;
$_$;


ALTER FUNCTION fishmap.project_sensitivity_lvls_combined_det(activity_name text, wkt text, bbox text, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_sensitivity_lvls_scenario_gen(text, text, text, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_sensitivity_lvls_scenario_gen(activity_name text, wkt text, bbox text, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, habitat_code integer, habitat_name text, dominant_habitat integer, habitat_confidence character varying(20), sensitivity_level integer, intensity_level integer, wkb_geometry public.geometry)
    LANGUAGE plpgsql
    AS $_$
DECLARE
	sql text;
BEGIN	

CREATE TEMP TABLE _tmp_sensitivity_levels ON COMMIT DROP AS (
    SELECT habitat_id, intensity_lvl, sensitivity_lvl
    FROM fishmap.sensitivity_matrix
    WHERE activity_id = (SELECT id FROM fishmap.activities WHERE fishmap_name = activity_name)
);
    
CREATE TEMP TABLE _tmp_sensitivity_intensities ON COMMIT DROP AS (
    SELECT il.intensity_level, il.wkb_geometry
    FROM fishmap.project_intensity_lvls_new_gen(
        activity_name, 
        wkt, 
        VARIADIC args) il
    WHERE ST_Intersects(il.wkb_geometry,  ST_GeomFromText(bbox, 27700))
);

CREATE TEMP TABLE _tmp_union ON COMMIT DROP AS (
    SELECT ST_Union(
        ST_SnapToGrid(
            si.wkb_geometry
            , 0.1
        )
    ) AS wkb_geometry
    FROM _tmp_sensitivity_intensities si
);

CREATE TEMP TABLE _tmp_habitats ON COMMIT DROP AS (
    SELECT 
        h.habitat_code
        , h.habitat_name
        , h.dominant_habitat
        , h.habitat_confidence
        , ST_Intersection(
            h.wkb_geometry
            , (
                SELECT u.wkb_geometry FROM _tmp_union u
            ) 
        ) AS wkb_geometry
    FROM 
        habitats h
    WHERE
        ST_Intersects(h.wkb_geometry, (SELECT u.wkb_geometry FROM _tmp_union u))
);
    
    sql := format('
SELECT row_number() OVER (ORDER BY wkb_geometry)::int AS ogc_fid, habitat_code, habitat_name,dominant_habitat, habitat_confidence, sensitivity_level, intensity_level, wkb_geometry FROM (
	SELECT 
        h.habitat_code
        , h.habitat_name::text
        , h.dominant_habitat
        , h.habitat_confidence
        , l.sensitivity_lvl AS sensitivity_level
        , i.intensity_level
        , h.wkb_geometry
	FROM 
        _tmp_sensitivity_intensities i
		, _tmp_habitats h
		, _tmp_sensitivity_levels l
	WHERE 
		l.habitat_id = h.dominant_habitat AND l.intensity_lvl = i.intensity_level
) AS sensitivities;
');
	RAISE INFO '%', sql;
	RETURN QUERY EXECUTE sql;
END;
$_$;


ALTER FUNCTION fishmap.project_sensitivity_lvls_scenario_gen(activity_name text, wkt text, bbox text, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: project_sensitivity_lvls_scenario_det(text, text, text, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.project_sensitivity_lvls_scenario_det(activity_name text, wkt text, bbox text, VARIADIC args numeric[]) RETURNS TABLE(ogc_fid integer, habitat_code integer, habitat_name text, sensitivity_level integer, intensity_level integer, wkb_geometry public.geometry)
    LANGUAGE plpgsql
    AS $_$
DECLARE
	sql text;
BEGIN	
CREATE TEMP TABLE _tmp_sensitivity_levels ON COMMIT DROP AS (
    SELECT habitat_id, intensity_lvl, sensitivity_lvl
    FROM fishmap.sensitivity_matrix
    WHERE activity_id = (SELECT id FROM fishmap.activities WHERE fishmap_name = activity_name)
);
CREATE TEMP TABLE _tmp_sensitivity_intensities ON COMMIT DROP AS (
    SELECT il.intensity_level, il.wkb_geometry
    FROM fishmap.project_intensity_lvls_new_det(
        activity_name, 
        wkt, 
        VARIADIC args) il
    WHERE ST_Intersects(il.wkb_geometry,  ST_GeomFromText(bbox, 27700))
);

    sql := format('
SELECT row_number() OVER (ORDER BY wkb_geometry)::int AS ogc_fid, habitat_code, habitat_name, sensitivity_level, intensity_level, wkb_geometry FROM (
	SELECT h.habitat_code, h.habitat_name::text, l.sensitivity_lvl AS sensitivity_level, i.intensity_level, ST_Intersection(i.wkb_geometry, h.wkb_geometry) AS wkb_geometry
	FROM 
        _tmp_sensitivity_intensities i
		, habitats h
		, _tmp_sensitivity_levels l
	WHERE 
        ST_Intersects(i.wkb_geometry, h.wkb_geometry)
		AND  l.habitat_id = h.dominant_habitat AND l.intensity_lvl = i.intensity_level
) AS sensitivities;
');
	RAISE INFO '%', sql;
	RETURN QUERY EXECUTE sql;
END;
$_$;


ALTER FUNCTION fishmap.project_sensitivity_lvls_scenario_det(activity_name text, wkt text, bbox text, VARIADIC args numeric[]) OWNER TO fishmap_webapp;

--
-- Name: set_intensity_lvls(integer, numeric[]); Type: FUNCTION; Schema: fishmap; Owner: postgres
--

CREATE FUNCTION fishmap.set_intensity_lvls(fishingtype integer, rangeboundaries numeric[]) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION fishmap.set_intensity_lvls(fishingtype integer, rangeboundaries numeric[]) OWNER TO postgres;

--
-- Name: vessels_project_det(text, integer, text, boolean); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.vessels_project_det(fishingname text, vesselcount integer, wkt text, combined boolean) RETURNS TABLE(ogc_fid integer, num integer, wkb_geometry public.geometry)
    LANGUAGE plpgsql
    AS $$
DECLARE
	tablename text;
	countfield text;
	newdata text;
	sql text;
BEGIN
	tablename := 'intensity_lvls_'|| fishingname ||'_det';
	countfield := '_overlaps';

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
     		'|| quote_ident(countfield) ||', 
		wkb_geometry
	FROM '|| quote_ident(tablename) ||' AS existing
	WHERE ST_Intersects(wkb_geometry, (SELECT wkb_geometry FROM project))
)
SELECT row_number() OVER (ORDER BY wkb_geometry)::int AS ogc_fid, '|| quote_ident(countfield) ||', wkb_geometry FROM (
	-- non-overlapping existing polygons
	SELECT '|| quote_ident(countfield) ||'::int, wkb_geometry
	FROM '|| quote_ident(tablename) ||'
	WHERE ogc_fid NOT IN (SELECT ogc_fid FROM overlapping)
	UNION 
	-- non-overlapping parts of overlapping existing polygon
	SELECT '|| quote_ident(countfield) ||'::int, (ST_Dump(ST_Difference(
		wkb_geometry,
		(SELECT wkb_geometry FROM project)
	))).geom AS wkb_geometry
		FROM overlapping
	UNION 
	-- non-overlapping parts of project polygon
	SELECT 
        '|| quote_ident(countfield) ||'::int, 
        (ST_Dump(
            COALESCE(
                ST_Difference(
                    wkb_geometry
                    , (SELECT ST_Multi(ST_Union(wkb_geometry)) FROM overlapping)
                )
                , wkb_geometry
            )
        )).geom AS wkb_geometry
    	FROM project
	UNION 
	--overlapping parts of project polygon and existing polygons
	SELECT ('|| quote_ident(countfield) ||' + (SELECT '|| quote_ident(countfield) ||' FROM project))::int AS '|| quote_ident(countfield) ||', ST_Intersection(wkb_geometry, (SELECT wkb_geometry FROM project)) FROM overlapping
) AS a;';
	ELSE
		sql := 'SELECT 1, '|| newdata ||';';
	END IF;
	RAISE INFO 'statement: %', sql;
	RETURN QUERY EXECUTE sql;
END;
$$;


ALTER FUNCTION fishmap.vessels_project_det(fishingname text, vesselcount integer, wkt text, combined boolean) OWNER TO fishmap_webapp;

--
-- Name: vessels_project_gen(text, integer, text, boolean); Type: FUNCTION; Schema: fishmap; Owner: fishmap_webapp
--

CREATE FUNCTION fishmap.vessels_project_gen(fishingname text, vesselcount integer, wkt text, combine boolean) RETURNS TABLE(ogc_fid integer, num integer, wkb_geometry public.geometry)
    LANGUAGE plpgsql
    AS $$
DECLARE
	tablename text;
	countfield text;
	sql text;
BEGIN
	tablename := 'intensity_lvls_'|| fishingname ||'_gen';
	countfield := '_overlaps';
		
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
$$;


ALTER FUNCTION fishmap.vessels_project_gen(fishingname text, vesselcount integer, wkt text, combine boolean) OWNER TO fishmap_webapp;

