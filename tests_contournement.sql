-- tests_contournement.sql : lab 8, etape 8.6 (lancer en postgres, sans ON_ERROR_STOP)
-- f.ba du sujet = a.diop ; coord.sn = k.ndiaye ; CM-BAF = CI-KORH (recolte declaree d'un autre site).

-- En postgres : on range les identifiants dont on aura besoin
SELECT id AS ruche_autre FROM ruche WHERE code = 'SN-KOLD-011' \gset
SELECT id AS recolte_autre_site FROM recolte
WHERE statut = 'declaree' AND ruche_id = (SELECT id FROM ruche WHERE code = 'CI-KORH-002') \gset

SET ROLE "a.diop";

-- Test 1 : a.diop lit apicultrice directement. Attendu : refuse
SELECT nom, telephone FROM apicultrice;
-- Resultat : ERROR: permission denied for table apicultrice -> attendu

-- Test 2 : a.diop lit v_mes_ruches. Attendu : ses ruches seulement
SELECT code FROM v_mes_ruches ORDER BY code;
-- Resultat : SN-CASA-014, SN-CASA-021 (2 lignes sur 11) -> attendu

-- Test 3 : a.diop declare une recolte sur sa ruche. Attendu : accepte
INSERT INTO v_mes_recoltes (ruche_id, date_recolte, quantite_kg)
SELECT id, '2027-03-16', 9.5 FROM v_mes_ruches WHERE code = 'SN-CASA-021';
-- Resultat : INSERT 0 1 -> attendu

-- Test 4 : a.diop declare une recolte sur la ruche d'une autre. Attendu : refuse (check option)
INSERT INTO v_mes_recoltes (ruche_id, date_recolte, quantite_kg)
VALUES (:'ruche_autre', '2027-03-16', 9.5);
-- Resultat : ERROR: new row violates check option for view "v_mes_recoltes" -> attendu

-- Test 5 : a.diop declare une recolte deja validee. Attendu : refuse
INSERT INTO v_mes_recoltes (ruche_id, date_recolte, quantite_kg, statut)
SELECT id, '2027-03-16', 9.5, 'validee' FROM v_mes_ruches WHERE code = 'SN-CASA-021';
-- Resultat : ERROR: permission denied for view v_mes_recoltes (pas de droit sur la colonne statut) -> attendu

-- Test 6 : a.diop modifie une recolte dans la table. Attendu : refuse
UPDATE recolte SET quantite_kg = 99;
-- Resultat : ERROR: permission denied for table recolte -> attendu

-- Test 7 : a.diop appelle valider_recolte. Attendu : refuse
SELECT valider_recolte(:'recolte_autre_site');
-- Resultat : ERROR: permission denied for function valider_recolte -> attendu

-- Test 8 : a.diop ecrit une fausse ligne dans le journal. Attendu : refuse
INSERT INTO journal_audit (acteur, table_cible, operation) VALUES ('k.ndiaye', 'recolte', 'UPDATE');
-- Resultat : ERROR: permission denied for table journal_audit -> attendu

-- Test 9 : a.diop coupe le trigger d'audit. Attendu : refuse
ALTER TABLE recolte DISABLE TRIGGER recolte_audit;
-- Resultat : ERROR: must be owner of table recolte -> attendu

RESET ROLE;

-- En postgres : l'identifiant de la recolte du test 3
SELECT id AS recolte_test FROM recolte
WHERE date_recolte = '2027-03-16' AND statut = 'declaree'
  AND ruche_id = (SELECT id FROM ruche WHERE code = 'SN-CASA-021')
ORDER BY id LIMIT 1 \gset

SET ROLE "k.ndiaye";

-- Test 10 : k.ndiaye valide la recolte du test 3, puis la revalide. Attendu : accepte, puis refuse
SELECT valider_recolte(:'recolte_test');
-- Resultat : accepte (une ligne vide) -> attendu
SELECT valider_recolte(:'recolte_test');
-- Resultat : ERROR: récolte introuvable, déjà traitée ou hors de votre site -> attendu

-- Test 11 : k.ndiaye valide une recolte d'un autre site (CI-KORH). Attendu : refuse
SELECT valider_recolte(:'recolte_autre_site');
-- Resultat : ERROR: récolte introuvable, déjà traitée ou hors de votre site -> attendu

RESET ROLE;
SET ROLE "admin.beeafrica";

-- Test 12 : admin.beeafrica lit le journal, puis supprime un utilisateur. Attendu : lu ; refuse
SELECT acteur, table_cible, operation, horodatage
FROM journal_audit WHERE table_cible = 'recolte' ORDER BY id DESC LIMIT 2;
-- Resultat : k.ndiaye | recolte | UPDATE, puis a.diop | recolte | INSERT -> attendu (les vrais acteurs)
DELETE FROM utilisateur WHERE login = 'gest.beeafrica';
-- Resultat : ERROR: permission denied for table utilisateur -> attendu

RESET ROLE;

-- Remise en etat : la recolte de test reste (le journal est en ajout seul, la preuve aussi).
