-- tests_denormalisation.sql : lab 7 (lancer apres volume.sql et denormalisation.sql)
\timing on

-- Etape 7.1 : le tableau de bord du gestionnaire (UC-G01), sur les tables
SELECT r.site_id, (m.horodatage AT TIME ZONE 'UTC')::date AS jour,
       count(*) AS nb_mesures, round(avg(m.poids_kg), 2) AS poids_moyen,
       min(m.poids_kg) AS poids_min, min(m.batterie_pct) AS batterie_min
FROM mesure m JOIN ruche r ON r.id = m.ruche_id
WHERE r.site_id = 'SN-CASA'
GROUP BY 1, 2 ORDER BY jour DESC LIMIT 3;
-- Attendu : 144 mesures par jour (SN-CASA a 3 ruches dans notre base : 3 x 48)
EXPLAIN ANALYZE
SELECT r.site_id, (m.horodatage AT TIME ZONE 'UTC')::date AS jour,
       count(*) AS nb_mesures, round(avg(m.poids_kg), 2) AS poids_moyen,
       min(m.poids_kg) AS poids_min, min(m.batterie_pct) AS batterie_min
FROM mesure m JOIN ruche r ON r.id = m.ruche_id
WHERE r.site_id = 'SN-CASA'
GROUP BY 1, 2 ORDER BY jour DESC LIMIT 3;
-- Noter l'Execution Time (de l'ordre de 10 ms)

-- Etape 7.2 : la meme chose dans la synthese
SELECT * FROM synthese_site_jour WHERE site_id = 'SN-CASA' ORDER BY jour DESC LIMIT 3;
EXPLAIN ANALYZE
SELECT * FROM synthese_site_jour WHERE site_id = 'SN-CASA' ORDER BY jour DESC LIMIT 3;
-- Attendu : les memes chiffres, en moins de 0,2 ms

-- Etape 7.2 : le prix, un vol invisible (le sujet cite SN-CASA-011, absente de notre base)
DELETE FROM mesure WHERE horodatage = '2027-03-15 06:00+00'
  AND ruche_id = (SELECT id FROM ruche WHERE code = 'SN-CASA-014');   -- pour pouvoir relancer
INSERT INTO mesure (ruche_id, horodatage, poids_kg, temp_int_c, batterie_pct)
SELECT id, '2027-03-15 06:00+00', 8.40, 34.0, 90 FROM ruche WHERE code = 'SN-CASA-014';
SELECT * FROM synthese_site_jour WHERE site_id = 'SN-CASA' ORDER BY jour DESC LIMIT 2;
-- Attendu : le 15 mars n'apparait pas encore
REFRESH MATERIALIZED VIEW CONCURRENTLY synthese_site_jour;
SELECT * FROM synthese_site_jour WHERE site_id = 'SN-CASA' ORDER BY jour DESC LIMIT 2;
-- Attendu : 2027-03-15 | 1 mesure | poids_min = 8.40

-- Etape 7.3 : casser un hache simple ("Fatou Ba" du sujet = +221 77 100 00 02)
SELECT nom, encode(sha256(convert_to(telephone, 'UTF8')), 'hex') AS pseudo
FROM apicultrice WHERE telephone = '+221 77 100 00 02' \gset
SELECT '+221 77 1' || substr(to_char(n, 'FM000000'), 1, 2) || ' '
                   || substr(to_char(n, 'FM000000'), 3, 2) || ' '
                   || substr(to_char(n, 'FM000000'), 5, 2) AS telephone_retrouve
FROM generate_series(0, 999999) AS n
WHERE encode(sha256(convert_to('+221 77 1' || substr(to_char(n, 'FM000000'), 1, 2) || ' '
                                           || substr(to_char(n, 'FM000000'), 3, 2) || ' '
                                           || substr(to_char(n, 'FM000000'), 5, 2), 'UTF8')), 'hex')
      = :'pseudo';
-- Attendu : +221 77 100 00 02 en un peu plus d'une seconde (noter le temps)

-- Etape 7.3 : l'export du bailleur
SELECT * FROM v_export_bailleur ORDER BY pays, site_id;
-- Attendu : 8 lignes pour 11 ruches, sans nom ni telephone, positions arrondies (12.6 | -16.3)
SELECT position((SELECT cle FROM cle_pseudonymisation) IN definition) > 0 AS contient_la_cle
FROM pg_views WHERE viewname = 'v_export_bailleur';
-- Attendu : f
\timing off
