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

ALTER DEFAULT PRIVILEGES IN SCHEMA fishmap
    GRANT SELECT ON TABLES
    TO fishmap_webapp;

 
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
