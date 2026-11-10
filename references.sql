-- references.sql : lab 8, que se passe-t-il quand on supprime ? (rejouable)

-- Adhesion : un lien sans valeur propre. Si l'apicultrice ou la cooperative disparait,
-- l'adhesion n'a plus de sens : on la supprime avec (CASCADE).
ALTER TABLE adhesion
  DROP CONSTRAINT IF EXISTS adhesion_apicultrice_fk,
  ADD  CONSTRAINT adhesion_apicultrice_fk FOREIGN KEY (apicultrice_id)
       REFERENCES apicultrice (id) ON DELETE CASCADE;
ALTER TABLE adhesion
  DROP CONSTRAINT IF EXISTS adhesion_cooperative_fk,
  ADD  CONSTRAINT adhesion_cooperative_fk FOREIGN KEY (cooperative_id)
       REFERENCES cooperative (id) ON DELETE CASCADE;

-- Mesures : ce sont des preuves (un vol se voit dans la courbe de poids).
-- Supprimer une ruche ne doit jamais les effacer en silence : RESTRICT.
ALTER TABLE mesure
  DROP CONSTRAINT IF EXISTS mesure_ruche_fk,
  ADD  CONSTRAINT mesure_ruche_fk FOREIGN KEY (ruche_id)
       REFERENCES ruche (id) ON DELETE RESTRICT;

-- Inspections : la trace du suivi sanitaire de la colonie, preuve en cas de litige : RESTRICT.
ALTER TABLE inspection
  DROP CONSTRAINT IF EXISTS inspection_ruche_fk,
  ADD  CONSTRAINT inspection_ruche_fk FOREIGN KEY (ruche_id)
       REFERENCES ruche (id) ON DELETE RESTRICT;

-- Recoltes : preuve de production et base des paiements (UC-C02) : RESTRICT.
ALTER TABLE recolte
  DROP CONSTRAINT IF EXISTS recolte_ruche_fk,
  ADD  CONSTRAINT recolte_ruche_fk FOREIGN KEY (ruche_id)
       REFERENCES ruche (id) ON DELETE RESTRICT;

-- Alertes : la trace d'un vol ou d'un essaimage signale : RESTRICT.
ALTER TABLE alerte
  DROP CONSTRAINT IF EXISTS alerte_ruche_fk,
  ADD  CONSTRAINT alerte_ruche_fk FOREIGN KEY (ruche_id)
       REFERENCES ruche (id) ON DELETE RESTRICT;

-- Verification. Attendu : 2 CASCADE, 4 RESTRICT, les autres NO ACTION
SELECT conrelid::regclass AS table_, conname,
       CASE confdeltype WHEN 'a' THEN 'NO ACTION' WHEN 'r' THEN 'RESTRICT'
                        WHEN 'c' THEN 'CASCADE'   WHEN 'n' THEN 'SET NULL' END AS on_delete
FROM pg_constraint
WHERE contype = 'f' AND connamespace = 'public'::regnamespace
ORDER BY on_delete, 1;
