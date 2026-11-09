-- migration_3nf.sql : découper extrait_plat, une table par déterminant
-- 1er lancement (données corrompues) : refus attendu sur site_pkey. C'est le but.
-- 2e lancement (après nettoyage.sql) : 4 sites, 8 apicultrices, 11 ruches, 528 mesures.
BEGIN;
DROP SCHEMA IF EXISTS norm CASCADE;
CREATE SCHEMA norm;

CREATE TABLE norm.site (                 -- déterminant : site_id
  site_id   text PRIMARY KEY,
  site_nom  text NOT NULL,
  pays      text NOT NULL
);

CREATE TABLE norm.apicultrice (          -- déterminant : telephone
  telephone    text PRIMARY KEY,
  apicultrice  text NOT NULL,
  cooperative  text NOT NULL
);

CREATE TABLE norm.ruche (                -- déterminant : ruche_code
  ruche_code  text PRIMARY KEY,
  site_id     text NOT NULL REFERENCES norm.site(site_id),
  telephone   text NOT NULL REFERENCES norm.apicultrice(telephone)
);

CREATE TABLE norm.mesure (               -- clé : (ruche_code, horodatage)
  ruche_code  text NOT NULL REFERENCES norm.ruche(ruche_code),
  horodatage  timestamptz NOT NULL,
  poids_kg    numeric(5,2),
  temp_int_c  numeric(4,1),
  PRIMARY KEY (ruche_code, horodatage)
);

INSERT INTO norm.site        SELECT DISTINCT site_id, site_nom, pays FROM extrait_plat;
INSERT INTO norm.apicultrice SELECT DISTINCT telephone, apicultrice, cooperative FROM extrait_plat;
INSERT INTO norm.ruche       SELECT DISTINCT ruche_code, site_id, telephone FROM extrait_plat;
INSERT INTO norm.mesure      SELECT ruche_code, horodatage, poids_kg, temp_int_c FROM extrait_plat;
COMMIT;
