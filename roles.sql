-- roles.sql : lab 8, roles, vues de moindre privilege et validation d'une recolte (rejouable)
-- Correspondance avec le sujet (personnes absentes de notre base) :
--   f.ba  -> a.diop    (Aminata Diop, apicultrice de SN-CASA, ruches SN-CASA-014 et SN-CASA-021)
--   coord.sn -> k.ndiaye (coordinateur de SN-CASA, deja dans utilisateur)
-- Le nom du role PostgreSQL doit etre egal au login de la table utilisateur : les vues filtrent sur qui().

-- 0. Prerequis du lab 4 : un login = une seule personne (rejouable sur une base neuve)
UPDATE utilisateur u SET login = 'awa.diop'
FROM apicultrice a
WHERE a.id = u.apicultrice_id AND a.nom = 'Awa Diop' AND u.login <> 'awa.diop';
UPDATE utilisateur u SET login = 'aminata.diop.kold'
FROM apicultrice a
WHERE a.id = u.apicultrice_id AND a.telephone = '+221 77 100 00 02' AND u.login <> 'aminata.diop.kold';
CREATE UNIQUE INDEX IF NOT EXISTS utilisateur_login_ci ON utilisateur (lower(login));

-- Le gestionnaire et l'administrateur doivent exister dans utilisateur
INSERT INTO utilisateur (login, role) VALUES
  ('gest.beeafrica',  'gestionnaire'),
  ('admin.beeafrica', 'admin')
ON CONFLICT DO NOTHING;

-- 1. Les groupes, puis les personnes
-- Pas de mot de passe dans ce fichier : il est versionne. Le definir hors depot avec \password.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'qb_apicultrice')  THEN CREATE ROLE qb_apicultrice  NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'qb_coordinateur') THEN CREATE ROLE qb_coordinateur NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'qb_gestionnaire') THEN CREATE ROLE qb_gestionnaire NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'qb_admin')        THEN CREATE ROLE qb_admin        NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'a.diop')          THEN CREATE ROLE "a.diop"          LOGIN IN ROLE qb_apicultrice;  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'awa.diop')        THEN CREATE ROLE "awa.diop"        LOGIN IN ROLE qb_apicultrice;  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'k.ndiaye')        THEN CREATE ROLE "k.ndiaye"        LOGIN IN ROLE qb_coordinateur; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'gest.beeafrica')  THEN CREATE ROLE "gest.beeafrica"  LOGIN IN ROLE qb_gestionnaire; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'admin.beeafrica') THEN CREATE ROLE "admin.beeafrica" LOGIN IN ROLE qb_admin;        END IF;
END $$;

-- 2. Tout fermer, puis ouvrir le minimum
-- REVOKE CONNECT et pas REVOKE ALL ON DATABASE : le droit TEMPORARY reste ouvert jusqu'au lab 10.
-- current_database() : le fichier marche aussi dans une base de reconstruction.
DO $$
BEGIN
  EXECUTE format('REVOKE CONNECT ON DATABASE %I FROM PUBLIC', current_database());
  EXECUTE format('GRANT CONNECT ON DATABASE %I TO qb_apicultrice, qb_coordinateur, qb_gestionnaire, qb_admin',
                 current_database());
END $$;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO qb_apicultrice, qb_coordinateur, qb_gestionnaire, qb_admin;
GRANT EXECUTE ON FUNCTION qui() TO qb_apicultrice, qb_coordinateur, qb_gestionnaire, qb_admin;

-- 3. Chacun ne voit que ses lignes, et les colonnes utiles
CREATE OR REPLACE VIEW v_moi AS
SELECT id, login, role, site_id, apicultrice_id
FROM utilisateur WHERE login = qui();

-- Apicultrice : ses ruches, leurs mesures, ses recoltes
CREATE OR REPLACE VIEW v_mes_ruches AS
SELECT r.id, r.code, r.site_id, r.latitude, r.longitude, r.date_installation
FROM ruche r
JOIN utilisateur u ON u.apicultrice_id = r.apicultrice_id
WHERE u.login = qui();

CREATE OR REPLACE VIEW v_mes_mesures AS
SELECT m.ruche_id, m.horodatage, m.poids_kg, m.temp_int_c, m.temp_ext_c,
       m.humidite_pct, m.batterie_pct
FROM mesure m
WHERE m.ruche_id IN (SELECT id FROM v_mes_ruches);

CREATE OR REPLACE VIEW v_mes_recoltes AS
SELECT id, ruche_id, date_recolte, quantite_kg, statut
FROM recolte
WHERE ruche_id IN (SELECT id FROM v_mes_ruches)
WITH CHECK OPTION;                     -- refuse d'ecrire une recolte sur la ruche d'une autre

-- Coordinateur : les ruches et les recoltes de SON site
CREATE OR REPLACE VIEW v_ruches_site AS
SELECT r.id, r.code, r.latitude, r.longitude, a.nom AS apicultrice, a.telephone
FROM ruche r
JOIN apicultrice a ON a.id = r.apicultrice_id
WHERE r.site_id = (SELECT site_id FROM utilisateur WHERE login = qui());

CREATE OR REPLACE VIEW v_recoltes_site AS
SELECT rc.id, r.code AS ruche, rc.date_recolte, rc.quantite_kg, rc.statut, rc.validee_le
FROM recolte rc
JOIN ruche r ON r.id = rc.ruche_id
WHERE r.site_id = (SELECT site_id FROM utilisateur WHERE login = qui());

-- 4. Les droits, conformes a matrice_droits.md
GRANT SELECT ON v_moi TO qb_apicultrice, qb_coordinateur, qb_gestionnaire, qb_admin;
GRANT SELECT ON v_mes_ruches, v_mes_mesures TO qb_apicultrice;
GRANT SELECT, INSERT (ruche_id, date_recolte, quantite_kg) ON v_mes_recoltes TO qb_apicultrice;
GRANT SELECT ON v_ruches_site, v_recoltes_site TO qb_coordinateur;
GRANT SELECT ON synthese_site_jour, v_export_bailleur TO qb_gestionnaire;
GRANT SELECT, INSERT, UPDATE ON utilisateur TO qb_admin;      -- pas de DELETE
GRANT SELECT ON journal_audit TO qb_admin;

-- 5. Etape 8.5 : valider une recolte, sans donner UPDATE sur recolte au coordinateur
CREATE OR REPLACE FUNCTION valider_recolte(p_recolte uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
DECLARE
  v_id    uuid;
  v_role  text;
  v_site  text;
  n       int;
BEGIN
  SELECT id, role, site_id INTO v_id, v_role, v_site
  FROM utilisateur WHERE login = qui();
  IF v_id IS NULL OR v_role <> 'coordinateur' THEN
    RAISE EXCEPTION 'validation refusée : réservée aux coordinateurs';
  END IF;

  UPDATE recolte rc
  SET statut = 'validee', validee_par = v_id, validee_le = now()
  FROM ruche r
  WHERE r.id = rc.ruche_id
    AND rc.id = p_recolte
    AND rc.statut = 'declaree'          -- seulement si elle est encore declaree
    AND r.site_id = v_site;             -- seulement sur son site

  GET DIAGNOSTICS n = ROW_COUNT;
  IF n = 0 THEN
    RAISE EXCEPTION 'récolte introuvable, déjà traitée ou hors de votre site';
  END IF;
END;
$$;
REVOKE ALL ON FUNCTION valider_recolte(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION valider_recolte(uuid) TO qb_coordinateur;

-- Verification. Attendu : cinq lignes, une par personne
SELECT g.rolname AS groupe, r.rolname AS personne
FROM pg_auth_members m
JOIN pg_roles r ON r.oid = m.member
JOIN pg_roles g ON g.oid = m.roleid
WHERE g.rolname LIKE 'qb\_%' ORDER BY 1, 2;
