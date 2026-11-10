-- tests_revue.sql : lab 10, etapes 10.2 et 10.3 (lancer en postgres, sans ON_ERROR_STOP)
-- a.diop = f.ba du sujet. Le fichier remet d'abord l'etat "avant correction" pour rejouer la demonstration.

-- ===== Etat d'avant : la vue du collegue presse, sans barrieres, TEMPORARY ouvert =====
DROP VIEW IF EXISTS v_carte_ruches;
CREATE VIEW v_carte_ruches AS                       -- "pour la carte des ruches"
SELECT r.code, r.latitude, r.longitude, a.nom, a.telephone
FROM ruche r JOIN apicultrice a ON a.id = r.apicultrice_id;
GRANT SELECT ON v_carte_ruches TO qb_apicultrice;
ALTER VIEW v_mes_ruches RESET (security_barrier);
DO $$ BEGIN
  EXECUTE format('GRANT TEMPORARY ON DATABASE %I TO PUBLIC', current_database());
END $$;

-- ===== P2 : la vue qui en dit trop =====
SET ROLE "a.diop";
SELECT nom, telephone FROM apicultrice;
-- Attendu : ERROR: permission denied for table apicultrice
SELECT count(*) AS ruches_visibles, count(DISTINCT telephone) AS telephones_visibles FROM v_carte_ruches;
-- Attendu : 11 ruches et 8 telephones : elevation de privilege par la vue

-- ===== P3 : la fonction espion =====
SELECT code FROM v_mes_ruches ORDER BY code;
-- Attendu : SN-CASA-014, SN-CASA-021
CREATE FUNCTION pg_temp.espion(c text, lat numeric, lon numeric) RETURNS boolean
LANGUAGE plpgsql COST 0.0000001 AS $$
BEGIN
  RAISE NOTICE 'vu : % (%, %)', c, lat, lon;
  RETURN true;
END $$;
SELECT code FROM v_mes_ruches WHERE pg_temp.espion(code, latitude, longitude);
-- Attendu : le resultat ne montre que ses 2 ruches, mais les NOTICE donnent la position GPS des 11
RESET ROLE;

-- ===== Les corrections, appliquees en postgres =====
\ir corrections.sql

-- ===== Retest dans la meme session =====
SET ROLE "a.diop";
SELECT * FROM v_carte_ruches ORDER BY code;
-- Attendu : ses 2 ruches, sans nom ni telephone
SELECT code FROM v_mes_ruches WHERE pg_temp.espion(code, latitude, longitude);
-- Attendu : les NOTICE ne montrent plus que SN-CASA-014 et SN-CASA-021
RESET ROLE;

-- ===== Retest dans une nouvelle session =====
\c
SET ROLE "a.diop";
CREATE FUNCTION pg_temp.espion(c text, lat numeric, lon numeric) RETURNS boolean
LANGUAGE plpgsql COST 0.0000001 AS $$ BEGIN RETURN true; END $$;
-- Attendu : ERROR: permission denied to create temporary tables in database "queenbee"
RESET ROLE;

-- ===== Etape 10.3 : la grille =====
-- C1 : aucune fonction executable par PUBLIC. Attendu : 0 ligne
SELECT proname FROM pg_proc
WHERE pronamespace = 'public'::regnamespace
  AND has_function_privilege('public', oid, 'EXECUTE');

-- C2 : toute fonction SECURITY DEFINER fixe son search_path. Attendu : search_path=... partout
SELECT proname, proconfig FROM pg_proc
WHERE pronamespace = 'public'::regnamespace AND prosecdef;

-- C3 : les vues filtrantes sont des barrieres. Attendu : security_barrier=true
SELECT relname, reloptions FROM pg_class
WHERE relkind IN ('v', 'm') AND relnamespace = 'public'::regnamespace
ORDER BY relname;

-- C4 : aucune vue ne montre de donnees hors perimetre (en awa.diop, une ruche : SN-CASA-099)
SET ROLE "awa.diop";
SELECT 'v_mes_ruches' AS vue, count(*) FROM v_mes_ruches
UNION ALL SELECT 'v_mes_mesures', count(DISTINCT ruche_id) FROM v_mes_mesures
UNION ALL SELECT 'v_mes_recoltes', count(DISTINCT ruche_id) FROM v_mes_recoltes
UNION ALL SELECT 'v_carte_ruches', count(*) FROM v_carte_ruches
UNION ALL SELECT 'v_moi', count(*) FROM v_moi;
-- Attendu : 1 partout (sa ruche, son compte), sauf v_mes_recoltes : 0 (elle n'a aucune recolte)
SELECT * FROM v_ruches_site;
-- Attendu : ERROR: permission denied for view v_ruches_site
RESET ROLE;

-- C5 : le journal est en ajout seul. Attendu : trois refus
UPDATE journal_audit SET acteur = 'x';
DELETE FROM journal_audit;
TRUNCATE journal_audit;

-- C6 : le journal nomme le vrai acteur. Attendu : admin.beeafrica
SET ROLE "admin.beeafrica";
UPDATE utilisateur SET role = role WHERE login = 'gest.beeafrica';
RESET ROLE;
SELECT acteur, table_cible, operation FROM journal_audit ORDER BY id DESC LIMIT 1;

-- C7 : une apicultrice n'ecrit pas chez une autre. Attendu : refus (check option)
SELECT id AS ruche_autre FROM ruche WHERE code = 'SN-CASA-014' \gset
SET ROLE "awa.diop";
INSERT INTO v_mes_recoltes (ruche_id, date_recolte, quantite_kg) VALUES (:'ruche_autre', '2027-03-18', 5);
RESET ROLE;

-- C10 : les preuves ne partent pas en cascade. Attendu : RESTRICT pour mesure, inspection, recolte, alerte
SELECT conrelid::regclass AS table_, conname,
       CASE confdeltype WHEN 'a' THEN 'NO ACTION' WHEN 'r' THEN 'RESTRICT'
                        WHEN 'c' THEN 'CASCADE'   WHEN 'n' THEN 'SET NULL' END AS on_delete
FROM pg_constraint
WHERE contype = 'f' AND conname IN ('mesure_ruche_fk', 'inspection_ruche_fk', 'recolte_ruche_fk', 'alerte_ruche_fk');

-- C8, C9, C11, C12 se verifient dans le terminal (voir rapport_revue.md).
