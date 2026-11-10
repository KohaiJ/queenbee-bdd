-- tests_audit.sql : lab 8, etape 8.3 points 2 a 4 (sans ON_ERROR_STOP : refus voulus)
-- Le sujet cite la recolte de SN-CASA-011 (volume_kg) ; chez nous : SN-CASA-014 (quantite_kg).

-- Point 2 : modifier une recolte, puis lire le journal
-- Attendu : postgres | recolte | UPDATE | 12.50 | 14.0
UPDATE recolte SET quantite_kg = 14.0
WHERE date_recolte = '2026-10-15'
  AND ruche_id = (SELECT id FROM ruche WHERE code = 'SN-CASA-014');
SELECT acteur, table_cible, operation,
       avant ->> 'quantite_kg' AS avant, apres ->> 'quantite_kg' AS apres
FROM journal_audit WHERE table_cible = 'recolte' ORDER BY id DESC LIMIT 1;

-- Point 3 : effacer ses traces. Attendu : trois refus, et le nombre de lignes ne bouge pas
SELECT count(*) AS lignes_avant FROM journal_audit;
UPDATE journal_audit SET acteur = 'personne';
-- Attendu : ERROR: journal_audit est en ajout seul : UPDATE interdit
DELETE FROM journal_audit;
-- Attendu : ERROR: journal_audit est en ajout seul : DELETE interdit
TRUNCATE journal_audit;
-- Attendu : ERROR: journal_audit est en ajout seul : TRUNCATE interdit
SELECT count(*) AS lignes_apres FROM journal_audit;

-- Point 4 : la limite. En postgres, le proprietaire peut desactiver le trigger
ALTER TABLE journal_audit DISABLE TRIGGER journal_ajout_seul;
-- Obtenu : ALTER TABLE (accepte !)
ALTER TABLE journal_audit ENABLE TRIGGER journal_ajout_seul;
-- Reactive aussitot. D'ou la copie du journal hors de la base (SIEM du cahier des charges).
