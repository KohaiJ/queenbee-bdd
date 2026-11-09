-- nettoyage.sql : retrouver et corriger les incohérences avant de relancer la migration

-- Sites avec plusieurs pays. Attendu : SN-KOLD {Senegal, Sénégal}
SELECT site_id, array_agg(DISTINCT pays) AS pays_trouves
FROM extrait_plat GROUP BY site_id HAVING count(DISTINCT pays) > 1;

UPDATE extrait_plat SET pays = 'Sénégal' WHERE pays = 'Senegal';
-- Résultat : UPDATE 1

-- Ruches avec plusieurs téléphones. Attendu : SN-CASA-099 {+221 77 100 00 03, +221 77 999 99 99}
SELECT ruche_code, array_agg(DISTINCT telephone) AS telephones_trouves
FROM extrait_plat GROUP BY ruche_code HAVING count(DISTINCT telephone) > 1;

UPDATE extrait_plat SET telephone = '+221 77 100 00 03' WHERE telephone = '+221 77 999 99 99';
-- Résultat : UPDATE 1
