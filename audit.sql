-- audit.sql : lab 8, le trigger d'audit (qui a fait quoi) et le journal en ajout seul
-- Les trois fonctions sont identiques a l'exemple du sujet. Rejouable.

-- 1. Qui agit ? Le role choisi par SET ROLE, sinon l'utilisateur connecte
CREATE OR REPLACE FUNCTION qui() RETURNS text
LANGUAGE sql STABLE AS $$
  SELECT CASE WHEN current_setting('role') = 'none' THEN session_user::text
              ELSE current_setting('role') END
$$;

-- 2. Une ligne de journal par ligne touchee
CREATE OR REPLACE FUNCTION audit_ligne() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
  INSERT INTO journal_audit (acteur, table_cible, operation, ligne_id, avant, apres)
  VALUES (qui(), TG_TABLE_NAME, TG_OP,
          CASE WHEN TG_OP = 'DELETE' THEN OLD.id::text ELSE NEW.id::text END,
          CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN to_jsonb(OLD) END,
          CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW) END);
  RETURN NULL;
END;
$$;

-- Recolte : preuve de production (UC-C02)
DROP TRIGGER IF EXISTS recolte_audit ON recolte;
CREATE TRIGGER recolte_audit
AFTER INSERT OR UPDATE OR DELETE ON recolte
FOR EACH ROW EXECUTE FUNCTION audit_ligne();

-- Utilisateur : gestion des comptes (UC-AD01)
DROP TRIGGER IF EXISTS utilisateur_audit ON utilisateur;
CREATE TRIGGER utilisateur_audit
AFTER INSERT OR UPDATE OR DELETE ON utilisateur
FOR EACH ROW EXECUTE FUNCTION audit_ligne();

-- 3. Le journal en ajout seul
CREATE OR REPLACE FUNCTION journal_interdit() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'journal_audit est en ajout seul : % interdit', TG_OP;
END;
$$;

DROP TRIGGER IF EXISTS journal_ajout_seul ON journal_audit;
CREATE TRIGGER journal_ajout_seul
BEFORE UPDATE OR DELETE ON journal_audit
FOR EACH ROW EXECUTE FUNCTION journal_interdit();

DROP TRIGGER IF EXISTS journal_sans_truncate ON journal_audit;
CREATE TRIGGER journal_sans_truncate                  -- TRUNCATE a besoin de son propre trigger
BEFORE TRUNCATE ON journal_audit
FOR EACH STATEMENT EXECUTE FUNCTION journal_interdit();
