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

-- Update the _overlaps attribute with value from num_gatherers_year for
-- consistency
UPDATE intensity_lvls_cas_hand_gath_det
SET _overlaps = num_gatherers_year;

UPDATE intensity_lvls_cas_hand_gath_gen
SET _overlaps = num_gatherers_year;

UPDATE intensity_lvls_pro_hand_gath_det
SET _overlaps = num_gatherers_year;

UPDATE intensity_lvls_pro_hand_gath_gen
SET _overlaps = num_gatherers_year;

-- Rename num_anglers_year to _overlaps for consistency
ALTER TABLE intensity_lvls_rsa_shore_det
RENAME COLUMN num_anglers_year TO _overlaps;

ALTER TABLE intensity_lvls_rsa_shore_gen
RENAME COLUMN num_anglers_year TO _overlaps;

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


