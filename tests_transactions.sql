-- tests_transactions.sql : lab 9, etape 9.1 (lancer en postgres, sans ON_ERROR_STOP)
-- Le sujet cite SN-CASA-011 et coord.sn ; chez nous : SN-CASA-014 et k.ndiaye.

-- Une recolte declaree sur SN-CASA-014 (nos donnees n'en ont pas ; une seule meme si on relance)
INSERT INTO recolte (ruche_id, date_recolte, quantite_kg)
SELECT id, '2027-03-17', 7.5 FROM ruche r WHERE code = 'SN-CASA-014'
  AND NOT EXISTS (SELECT 1 FROM recolte WHERE ruche_id = r.id AND date_recolte = '2027-03-17');

-- 1. La trace qui ment : l'application ecrit son journal AVANT d'agir
CREATE TEMP TABLE journal_appli (quand timestamptz DEFAULT now(), message text);
INSERT INTO journal_appli (message) VALUES ('récolte SN-CASA-014 validée par k.ndiaye');
UPDATE recolte SET statut = 'validee'
WHERE statut = 'declaree' AND ruche_id = (SELECT id FROM ruche WHERE code = 'SN-CASA-014');
-- Attendu : ERROR ... violates check constraint "recolte_validation_tracee"
SELECT message FROM journal_appli;
-- Attendu : le journal de l'application affirme une validation qui n'a pas eu lieu

-- 2. L'action et sa trace ensemble, dans une transaction
SELECT count(*) AS journal_avant FROM journal_audit;
BEGIN;
UPDATE recolte SET statut = 'validee',
       validee_par = (SELECT id FROM utilisateur WHERE login = 'k.ndiaye'),
       validee_le  = now()
WHERE statut = 'declaree' AND date_recolte = '2027-03-17'
  AND ruche_id = (SELECT id FROM ruche WHERE code = 'SN-CASA-014');
SELECT count(*) AS journal_dans_la_transaction FROM journal_audit;
-- Attendu : +1
SELECT 1 / 0 AS panne_simulee;
-- Attendu : ERROR: division by zero
SELECT count(*) FROM journal_audit;
-- Attendu : ERROR: current transaction is aborted, commands ignored until end of transaction block
ROLLBACK;
SELECT count(*) AS journal_apres_rollback FROM journal_audit;
-- Attendu : revenu a la valeur de depart
SELECT statut FROM recolte
WHERE date_recolte = '2027-03-17' AND ruche_id = (SELECT id FROM ruche WHERE code = 'SN-CASA-014');
-- Attendu : declaree (rien n'a ete valide)
