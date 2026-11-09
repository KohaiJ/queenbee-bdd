-- preuve.sql : prouver que le découpage est sans perte, puis rejouer les attaques
-- À lancer après la migration réussie, sans ON_ERROR_STOP (un refus est voulu).

-- 1. Recomposer extrait_plat à partir des 4 tables norm (mêmes colonnes, même ordre)
CREATE OR REPLACE VIEW norm.reconstruit AS
SELECT r.ruche_code, s.site_id, s.site_nom, s.pays,
       a.apicultrice, a.telephone, a.cooperative,
       m.horodatage, m.poids_kg, m.temp_int_c
FROM norm.mesure m
JOIN norm.ruche r       USING (ruche_code)
JOIN norm.site s        USING (site_id)
JOIN norm.apicultrice a USING (telephone);

-- 2. Comparer dans les deux sens. Attendu : 0 ligne
(SELECT * FROM extrait_plat EXCEPT SELECT * FROM norm.reconstruit)
UNION ALL
(SELECT * FROM norm.reconstruit EXCEPT SELECT * FROM extrait_plat);
-- Résultat : 0 ligne : rien n'est perdu, rien n'est inventé

-- 3. Attaque : un second pays pour un site existant. Attendu : refus
INSERT INTO norm.site VALUES ('SN-CASA', 'Casamance', 'Mali');
-- Résultat : ERROR: duplicate key value violates unique constraint "site_pkey"

-- 4. Un site sans ruche. Attendu : accepté (l'anomalie d'insertion a disparu)
INSERT INTO norm.site VALUES ('SN-THIE', 'Thiès', 'Sénégal');
-- Résultat : INSERT 0 1

-- 5. Enquête par pays sur les tables norm. Attendu : de nouveau 3 pays
SELECT s.pays, count(*) AS nb_mesures, round(avg(m.poids_kg), 2) AS poids_moyen
FROM norm.mesure m
JOIN norm.ruche r USING (ruche_code)
JOIN norm.site s  USING (site_id)
GROUP BY s.pays ORDER BY s.pays;
-- Résultat : Cameroun 144, Côte d'Ivoire 144, Sénégal 240
