-- tests_formation.sql : lab 6, toutes les verifications (lancer apres formation.sql, sans ON_ERROR_STOP)
-- "Fatou Ba" du sujet = dans notre base l'apicultrice du +221 77 100 00 02 (Aminata Diop, SN-KOLD).

-- Etape 6.1 : les trois tests de dependances. Attendu : 0 ligne chacun
-- (telephone, theme) -> formateur : la cle
SELECT telephone, theme FROM formation_plat
GROUP BY 1, 2 HAVING count(DISTINCT formateur) > 1;
-- formateur -> theme
SELECT formateur FROM formation_plat
GROUP BY formateur HAVING count(DISTINCT theme) > 1;
-- (telephone, formateur) : une autre cle candidate ?
SELECT telephone, formateur FROM formation_plat
GROUP BY 1, 2 HAVING count(*) > 1;

-- Etape 6.1 : l'anomalie, dans une transaction annulee
-- Attendu : Moussa Sarr | {capteurs,varroa}
BEGIN;
UPDATE formation_plat SET theme = 'capteurs'
WHERE telephone = '+221 77 100 00 02' AND formateur = 'Moussa Sarr';
SELECT formateur, array_agg(DISTINCT theme) AS themes
FROM formation_plat GROUP BY formateur
HAVING count(DISTINCT theme) > 1;
ROLLBACK;

-- Etape 6.2 : le mauvais decoupage (colonne commune theme, cle d'aucun morceau)
CREATE TEMP TABLE p1 AS SELECT DISTINCT telephone, theme FROM formation_plat;
CREATE TEMP TABLE p2 AS SELECT DISTINCT theme, formateur FROM formation_plat;
SELECT count(*) AS lignes_jointure FROM p1 JOIN p2 USING (theme);
-- Attendu : 16 au lieu de 8
SELECT * FROM p1 JOIN p2 USING (theme)
EXCEPT
SELECT theme, telephone, formateur FROM formation_plat
ORDER BY 2;
-- Attendu : 8 lignes inventees, dont le +221 77 100 00 02 suivi par trois formateurs varroa
DROP TABLE p1, p2;

-- Etape 6.2 : le bon decoupage, preuve sans perte. Attendu : 0 ligne
(SELECT telephone, theme, formateur FROM formation_plat
 EXCEPT
 SELECT a.telephone, f.theme, f.nom
 FROM suivi_formation s
 JOIN apicultrice a ON a.id = s.apicultrice_id
 JOIN formateur f   ON f.id = s.formateur_id)
UNION ALL
(SELECT a.telephone, f.theme, f.nom
 FROM suivi_formation s
 JOIN apicultrice a ON a.id = s.apicultrice_id
 JOIN formateur f   ON f.id = s.formateur_id
 EXCEPT
 SELECT telephone, theme, formateur FROM formation_plat);

-- Etape 6.3 : la regle perdue (trigger coupe le temps de la demonstration)
ALTER TABLE suivi_formation DISABLE TRIGGER suivi_formation_df;
INSERT INTO suivi_formation
SELECT a.id, f.id FROM apicultrice a, formateur f
WHERE a.telephone = '+221 77 100 00 02' AND f.nom = 'Ibrahima Fall';
-- Attendu : INSERT 0 1 (accepte alors qu'elle a deja Moussa Sarr en varroa)
SELECT a.nom, a.telephone, f.theme, array_agg(f.nom ORDER BY f.nom) AS formateurs
FROM suivi_formation s
JOIN apicultrice a ON a.id = s.apicultrice_id
JOIN formateur f   ON f.id = s.formateur_id
GROUP BY a.id, a.nom, a.telephone, f.theme
HAVING count(*) > 1;
-- Attendu : Aminata Diop | +221 77 100 00 02 | varroa | {"Ibrahima Fall","Moussa Sarr"}
DELETE FROM suivi_formation
WHERE apicultrice_id = (SELECT id FROM apicultrice WHERE telephone = '+221 77 100 00 02')
  AND formateur_id   = (SELECT id FROM formateur WHERE nom = 'Ibrahima Fall');
-- Attendu : DELETE 1
ALTER TABLE suivi_formation ENABLE TRIGGER suivi_formation_df;

-- Etape 6.3 : le trigger
INSERT INTO suivi_formation
SELECT a.id, f.id FROM apicultrice a, formateur f
WHERE a.telephone = '+221 77 100 00 02' AND f.nom = 'Ibrahima Fall';
-- Attendu : ERROR: DF violée : cette apicultrice a déjà un formateur pour ce thème
INSERT INTO suivi_formation
SELECT a.id, f.id FROM apicultrice a, formateur f
WHERE a.telephone = '+221 77 100 00 02' AND f.nom = 'Khady Ndiaye';
-- Attendu : INSERT 0 1 (theme recolte, nouveau pour elle)
DELETE FROM suivi_formation
WHERE apicultrice_id = (SELECT id FROM apicultrice WHERE telephone = '+221 77 100 00 02')
  AND formateur_id   = (SELECT id FROM formateur WHERE nom = 'Khady Ndiaye');
-- Remise en etat pour pouvoir relancer ce fichier

-- Etape 6.4 : deux colonnes qui disent peut-etre la meme chose
SELECT a.nom, a.site_id AS site_apicultrice,
       array_agg(DISTINCT r.site_id) AS sites_de_ses_ruches
FROM apicultrice a JOIN ruche r ON r.apicultrice_id = a.id
GROUP BY a.id, a.nom, a.site_id ORDER BY a.nom;
-- Attendu : chaque apicultrice n'a de ruches que sur son site
