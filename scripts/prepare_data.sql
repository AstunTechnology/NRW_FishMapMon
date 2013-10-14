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
    IN ('ST_LineString', 'ST_Point');


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

