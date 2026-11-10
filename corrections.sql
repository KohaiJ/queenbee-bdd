-- corrections.sql : lab 10, corrections de la revue de securite (rejouable, en postgres)

-- P2 : la vue de carte du collegue montrait les 11 ruches et tous les telephones.
-- Reecrite : ses ruches seulement, sans nom ni telephone.
DROP VIEW IF EXISTS v_carte_ruches;
CREATE VIEW v_carte_ruches WITH (security_barrier = true) AS
SELECT r.code, r.latitude, r.longitude
FROM ruche r
JOIN utilisateur u ON u.apicultrice_id = r.apicultrice_id
WHERE u.login = qui();
GRANT SELECT ON v_carte_ruches TO qb_apicultrice;

-- P3 : la fonction espion. Toutes les vues filtrantes deviennent des barrieres :
-- le filtre de la vue passe avant toute condition de l'utilisateur.
ALTER VIEW v_moi           SET (security_barrier = true);
ALTER VIEW v_mes_ruches    SET (security_barrier = true);
ALTER VIEW v_mes_mesures   SET (security_barrier = true);
ALTER VIEW v_mes_recoltes  SET (security_barrier = true);
ALTER VIEW v_ruches_site   SET (security_barrier = true);
ALTER VIEW v_recoltes_site SET (security_barrier = true);

-- P3 : plus de fonction temporaire dans pg_temp pour les utilisateurs
DO $$
BEGIN
  EXECUTE format('REVOKE TEMPORARY ON DATABASE %I FROM PUBLIC', current_database());
END $$;

-- R2 (grille, etape 6.4) : rien n'empechait une ruche d'etre sur un autre site que son apicultrice.
-- Regle metier du cahier des charges : la ruche est sur le site de son apicultrice.
-- Une cle etrangere composee l'impose desormais a tous ceux qui ecrivent.
ALTER TABLE ruche DROP CONSTRAINT IF EXISTS ruche_site_apicultrice_fk;
ALTER TABLE apicultrice DROP CONSTRAINT IF EXISTS apicultrice_id_site_unique;
ALTER TABLE apicultrice ADD CONSTRAINT apicultrice_id_site_unique UNIQUE (id, site_id);
ALTER TABLE ruche ADD CONSTRAINT ruche_site_apicultrice_fk
  FOREIGN KEY (apicultrice_id, site_id) REFERENCES apicultrice (id, site_id);
