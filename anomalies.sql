-- anomalies.sql : provoquer les trois anomalies d'une table non normalisée
-- À lancer juste après plat.sql (extrait propre), sans ON_ERROR_STOP : l'erreur finale est voulue.

-- 1. Enquête de référence : mesures et poids moyen par pays. Attendu : 3 pays
SELECT pays, count(*) AS nb_mesures, round(avg(poids_kg), 2) AS poids_moyen
FROM extrait_plat GROUP BY pays ORDER BY pays;
-- Résultat : Cameroun 144, Côte d'Ivoire 144, Sénégal 240

-- 2a. ANOMALIE DE MISE À JOUR : le pays modifié sur une seule ligne
UPDATE extrait_plat SET pays = 'Senegal'
WHERE ruche_code = 'SN-KOLD-011'
  AND horodatage = (SELECT min(horodatage) FROM extrait_plat WHERE ruche_code = 'SN-KOLD-011');
-- Résultat : UPDATE 1

-- 2b. Le téléphone d'une apicultrice modifié sur une seule ligne (Awa Diop, ruche SN-CASA-099)
UPDATE extrait_plat SET telephone = '+221 77 999 99 99'
WHERE ruche_code = 'SN-CASA-099'
  AND horodatage = (SELECT min(horodatage) FROM extrait_plat WHERE ruche_code = 'SN-CASA-099');
-- Résultat : UPDATE 1 (Awa Diop a maintenant deux téléphones)

-- 3. Enquête relancée. Attendu : 4 pays
SELECT pays, count(*) AS nb_mesures, round(avg(poids_kg), 2) AS poids_moyen
FROM extrait_plat GROUP BY pays ORDER BY pays;
-- Résultat : « Senegal » apparaît comme un 4e pays, avec 1 mesure ; Sénégal passe à 239

-- 4. ANOMALIE DE SUPPRESSION (Fatou Sow n'a qu'une ruche), annulée ensuite
BEGIN;
DELETE FROM extrait_plat WHERE apicultrice = 'Fatou Sow';
SELECT telephone FROM extrait_plat WHERE apicultrice = 'Fatou Sow';
-- Résultat : DELETE 48, puis 0 ligne : son téléphone a disparu avec ses mesures
ROLLBACK;

-- 5. ANOMALIE D'INSERTION : un site sans ruche ni mesure ne peut pas être ajouté
ALTER TABLE extrait_plat ADD PRIMARY KEY (ruche_code, horodatage);
INSERT INTO extrait_plat (site_id, site_nom, pays) VALUES ('SN-THIE', 'Thiès', 'Sénégal');
-- Résultat : ERROR: null value in column "ruche_code" of relation "extrait_plat" violates not-null constraint
