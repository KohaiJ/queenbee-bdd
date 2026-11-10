-- tests_contraintes_j2.sql : lab 8, etapes 8.1 et 8.2 (sans ON_ERROR_STOP : erreurs voulues)
-- Le sujet cite CI-MAN-012, absente de notre base. On prend CM-BAME-003 :
-- elle a des mesures, mais ni inspection, ni recolte, ni alerte.

-- 8.1 point 1 : avant references.sql. Attendu : refus par mesure_ruche_fk
DELETE FROM ruche WHERE code = 'CM-BAME-003';

-- 8.1 point 2 : le test CASCADE, dans une transaction annulee
-- Attendu : DELETE 1, et 4 368 mesures de moins ; tout revient apres le ROLLBACK
BEGIN;
ALTER TABLE mesure DROP CONSTRAINT mesure_ruche_fk,
  ADD CONSTRAINT mesure_ruche_fk FOREIGN KEY (ruche_id) REFERENCES ruche (id) ON DELETE CASCADE;
SELECT count(*) AS mesures_avant FROM mesure;
DELETE FROM ruche WHERE code = 'CM-BAME-003';
SELECT count(*) AS mesures_apres FROM mesure;
ROLLBACK;
SELECT count(*) AS mesures_apres_rollback FROM mesure;

-- 8.2 : les valeurs impossibles (apres check.sql). Attendu : deux refus
INSERT INTO mesure (ruche_id, horodatage, poids_kg, batterie_pct)
SELECT id, '2027-03-16 06:00+00', 31.0, 150 FROM ruche WHERE code = 'SN-CASA-014';
-- Attendu : ERROR ... violates check constraint "mesure_batterie_0_100"
UPDATE alerte SET statut = 'fermée' WHERE statut = 'traitee';
-- Attendu : ERROR ... violates check constraint "alerte_statut_valide"
