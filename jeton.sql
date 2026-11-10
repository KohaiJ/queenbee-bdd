-- jeton.sql : lab 9, jetons de rafraichissement (UC-T01) qui ne doivent servir qu'une fois (rejouable)
DROP TABLE IF EXISTS session_app, jeton CASCADE;

CREATE TABLE jeton (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  utilisateur_id  uuid NOT NULL REFERENCES utilisateur (id),
  valeur          text NOT NULL UNIQUE,
  expire_le       timestamptz NOT NULL,
  utilise_le      timestamptz                       -- vide tant que le jeton n'a pas servi
);

CREATE TABLE session_app (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  utilisateur_id  uuid NOT NULL REFERENCES utilisateur (id),
  jeton_id        uuid NOT NULL REFERENCES jeton (id),
  ouverte_le      timestamptz NOT NULL DEFAULT clock_timestamp()
);

-- Trente jetons pour a.diop (f.ba du sujet), de RT-a.diop-1 a RT-a.diop-30, valables un jour
INSERT INTO jeton (utilisateur_id, valeur, expire_le)
SELECT id, 'RT-' || login || '-' || n, now() + INTERVAL '1 day'
FROM utilisateur CROSS JOIN generate_series(1, 30) AS n
WHERE login = 'a.diop';
-- Attendu : INSERT 0 30

-- Correction 3 (etape 9.4) : la base refuse deux sessions pour un meme jeton, quel que soit le code
ALTER TABLE session_app ADD CONSTRAINT session_jeton_unique UNIQUE (jeton_id);
