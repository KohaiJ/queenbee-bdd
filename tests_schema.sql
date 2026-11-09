INSERT INTO ruche (code, latitude, longitude, date_installation, site_id, apicultrice_id)
VALUES ('SN-CASA-998', 12.5, -16.3, current_date, 'SN-CASA', gen_random_uuid());

DELETE FROM apicultrice WHERE telephone = '+221 77 100 00 03';



INSERT INTO ruche (code, latitude, longitude, date_installation, site_id, apicultrice_id)
VALUES ('SN-CASA-997', 12.5, -16.3, current_date, 'SN-CASA', NULL);



DROP TABLE IF EXISTS ruche_sans_fk;
CREATE TABLE ruche_sans_fk (code text, apicultrice_id uuid);
INSERT INTO ruche_sans_fk VALUES ('XX-ORPH-001', gen_random_uuid());
SELECT r.code, a.nom FROM ruche_sans_fk r JOIN apicultrice a ON a.id = r.apicultrice_id;
DROP TABLE ruche_sans_fk;



DROP TABLE IF EXISTS test_serial;
CREATE TABLE test_serial (id serial PRIMARY KEY, code text);
INSERT INTO test_serial (code) VALUES ('a'), ('b'), ('c');
SELECT * FROM test_serial;
DROP TABLE test_serial;



INSERT INTO mesure (ruche_id, horodatage, poids_kg)
SELECT ruche_id, horodatage, 30 FROM mesure LIMIT 1;

SELECT r.code, r.site_id AS site_ruche, a.site_id AS site_apicultrice
FROM ruche r JOIN apicultrice a ON a.id = r.apicultrice_id
WHERE r.site_id <> a.site_id;

UPDATE recolte SET statut = 'validee' WHERE statut = 'declaree';
