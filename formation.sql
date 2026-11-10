-- formation.sql : lab 6, formations des apicultrices (decoupage BCNF + trigger)
-- Rejouable : le fichier supprime puis recree ses tables.
DROP TABLE IF EXISTS suivi_formation, formateur, formation_plat CASCADE;

-- 1. La table recue, telle quelle
-- Les telephones sont ceux de NOTRE base : le sujet en cite quatre qui n'y existent pas
-- (+221 77 200 00 01, +225 07 100 00 01, +225 07 100 00 02, +237 6 77 100 01).
CREATE TABLE formation_plat (
  telephone  text NOT NULL,
  theme      text NOT NULL,
  formateur  text NOT NULL,
  PRIMARY KEY (telephone, theme)
);

INSERT INTO formation_plat (telephone, theme, formateur) VALUES
  ('+221 77 100 00 01', 'varroa',   'Moussa Sarr'),
  ('+221 77 100 00 01', 'recolte',  'Khady Ndiaye'),
  ('+221 77 100 00 02', 'varroa',   'Moussa Sarr'),
  ('+221 77 100 00 03', 'varroa',   'Ibrahima Fall'),
  ('+221 77 100 00 03', 'capteurs', 'Oumar Diallo'),
  ('+225 07 00 00 05',  'varroa',   'Kouassi Yao'),
  ('+225 07 00 00 06',  'capteurs', 'Oumar Diallo'),
  ('+237 670 00 00 07', 'recolte',  'Khady Ndiaye');

-- 2. Le decoupage BCNF : une table par determinant
CREATE TABLE formateur (
  id     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nom    text NOT NULL UNIQUE,                                   -- formateur -> theme
  theme  text NOT NULL CHECK (theme IN ('varroa', 'recolte', 'capteurs'))
);

CREATE TABLE suivi_formation (
  apicultrice_id  uuid NOT NULL REFERENCES apicultrice (id),
  formateur_id    uuid NOT NULL REFERENCES formateur (id),
  PRIMARY KEY (apicultrice_id, formateur_id)
);

INSERT INTO formateur (nom, theme)
SELECT DISTINCT formateur, theme FROM formation_plat;
-- Attendu : INSERT 0 5

INSERT INTO suivi_formation (apicultrice_id, formateur_id)
SELECT a.id, f.id
FROM formation_plat p
JOIN apicultrice a ON a.telephone = p.telephone
JOIN formateur f   ON f.nom = p.formateur;
-- Attendu : INSERT 0 8 (moins de 8 : un telephone ne correspond a aucune apicultrice)

-- 3. Le trigger qui retablit la regle perdue : un seul formateur par theme pour une apicultrice
CREATE OR REPLACE FUNCTION suivi_un_formateur_par_theme() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM suivi_formation s
    JOIN formateur f ON f.id = s.formateur_id
    WHERE s.apicultrice_id = NEW.apicultrice_id          -- meme apicultrice
      AND s.formateur_id  <> NEW.formateur_id            -- un autre formateur
      AND f.theme = (SELECT theme FROM formateur WHERE id = NEW.formateur_id)  -- pour le meme theme
  ) THEN
    RAISE EXCEPTION 'DF violée : cette apicultrice a déjà un formateur pour ce thème';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER suivi_formation_df
BEFORE INSERT OR UPDATE ON suivi_formation
FOR EACH ROW EXECUTE FUNCTION suivi_un_formateur_par_theme();
