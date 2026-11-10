-- check.sql : lab 8, refuser les valeurs impossibles (rejouable)
-- Notre schema du jour 1 avait deja des CHECK sans nom (mesure_batterie_pct_check...) :
-- on les remplace par des contraintes nommees.

ALTER TABLE mesure
  DROP CONSTRAINT IF EXISTS mesure_batterie_pct_check,
  DROP CONSTRAINT IF EXISTS mesure_humidite_pct_check,
  DROP CONSTRAINT IF EXISTS mesure_batterie_0_100,
  DROP CONSTRAINT IF EXISTS mesure_humidite_0_100,
  DROP CONSTRAINT IF EXISTS mesure_poids_positif,
  ADD  CONSTRAINT mesure_batterie_0_100 CHECK (batterie_pct BETWEEN 0 AND 100),
  ADD  CONSTRAINT mesure_humidite_0_100 CHECK (humidite_pct BETWEEN 0 AND 100),
  ADD  CONSTRAINT mesure_poids_positif  CHECK (poids_kg >= 0);

ALTER TABLE utilisateur
  DROP CONSTRAINT IF EXISTS utilisateur_role_check,
  DROP CONSTRAINT IF EXISTS utilisateur_role_valide,
  ADD  CONSTRAINT utilisateur_role_valide
       CHECK (role IN ('apicultrice', 'coordinateur', 'gestionnaire', 'admin'));

-- Alerte : la nouvelle regle (ouverte, en_cours, traitee) etait refusee par nos donnees :
-- deux alertes avaient le statut 'fermee'. Trouvees avec :
--   SELECT statut, count(*) FROM alerte GROUP BY statut;
-- On les passe en 'traitee', puis on pose la contrainte.
ALTER TABLE alerte
  DROP CONSTRAINT IF EXISTS alerte_statut_check,
  DROP CONSTRAINT IF EXISTS alerte_statut_valide;
UPDATE alerte SET statut = 'traitee' WHERE statut = 'fermee';
ALTER TABLE alerte
  ADD CONSTRAINT alerte_statut_valide CHECK (statut IN ('ouverte', 'en_cours', 'traitee'));

ALTER TABLE recolte
  DROP CONSTRAINT IF EXISTS recolte_statut_check,
  DROP CONSTRAINT IF EXISTS recolte_statut_valide,
  ADD  CONSTRAINT recolte_statut_valide CHECK (statut IN ('declaree', 'validee', 'ecart'));
