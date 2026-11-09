-- contraintes.sql : confronter les dépendances aux données, puis rendre les logins uniques
-- Exécuter les commandes UNE PAR UNE dans le Query Tool, dans l'ordre.

-- ===== Étape 4.3 : les DF résistent-elles aux données ? =====

-- DF 1 : site_id -> site_nom, pays
SELECT site_id FROM extrait_plat GROUP BY site_id
HAVING count(DISTINCT (site_nom, pays)) > 1;
-- Résultat : 0 ligne

-- DF 2 : ruche_code -> site_id, telephone
SELECT ruche_code FROM extrait_plat GROUP BY ruche_code
HAVING count(DISTINCT (site_id, telephone)) > 1;
-- Résultat : 0 ligne

-- DF 3 : telephone -> apicultrice, cooperative
SELECT telephone FROM extrait_plat GROUP BY telephone
HAVING count(DISTINCT (apicultrice, cooperative)) > 1;
-- Résultat : 0 ligne

-- DF 4 : ruche_code, horodatage -> poids_kg, temp_int_c
SELECT ruche_code, horodatage FROM extrait_plat GROUP BY ruche_code, horodatage
HAVING count(DISTINCT (poids_kg, temp_int_c)) > 1;
-- Résultat : 0 ligne

-- Fausse DF : apicultrice -> telephone
SELECT apicultrice, count(DISTINCT telephone) AS nb_telephones
FROM extrait_plat GROUP BY apicultrice
HAVING count(DISTINCT telephone) > 1;
-- Résultat : Aminata Diop | 2

-- ===== Étape 4.4 : rendre les logins uniques =====

-- Commande 1 : logins en double. Attendu : a.diop trois fois
SELECT u.login, a.nom, a.site_id
FROM utilisateur u LEFT JOIN apicultrice a ON a.id = u.apicultrice_id
WHERE u.login IN (SELECT login FROM utilisateur GROUP BY login HAVING count(*) > 1)
ORDER BY u.login, a.nom;
-- Résultat : a.diop (Aminata Diop SN-CASA), a.diop (Aminata Diop SN-KOLD), a.diop (Awa Diop SN-CASA)

-- Commande 2 : poser la contrainte. Attendu : refus
ALTER TABLE utilisateur ADD CONSTRAINT utilisateur_login_unique UNIQUE (login);
-- Obtenu : ERROR: could not create unique index "utilisateur_login_unique"
--          DETAIL: Key (login)=(a.diop) is duplicated.

-- Commande 3 : un login différent pour chaque personne
UPDATE utilisateur u SET login = 'awa.diop'
FROM apicultrice a WHERE a.id = u.apicultrice_id AND a.nom = 'Awa Diop';
UPDATE utilisateur u SET login = 'aminata.diop.kold'
FROM apicultrice a WHERE a.id = u.apicultrice_id AND a.telephone = '+221 77 100 00 02';
-- Obtenu : UPDATE 1, UPDATE 1 (il reste un seul a.diop : Aminata Diop de SN-CASA)

-- Commande 4 : la même contrainte. Attendu : acceptée
ALTER TABLE utilisateur ADD CONSTRAINT utilisateur_login_unique UNIQUE (login);
-- Obtenu : ALTER TABLE

-- Commande 5 : le piège des majuscules. Attendu : accepté, puis on le supprime
INSERT INTO utilisateur (login, role) VALUES ('A.Diop', 'admin');
-- Obtenu : INSERT 0 1 (A.Diop est différent de a.diop pour la contrainte)
DELETE FROM utilisateur WHERE login = 'A.Diop';
-- Obtenu : DELETE 1

-- Commande 6 : unicité insensible à la casse. Attendu : refus de A.Diop
CREATE UNIQUE INDEX utilisateur_login_ci ON utilisateur (lower(login));
-- Obtenu : CREATE INDEX
INSERT INTO utilisateur (login, role) VALUES ('A.Diop', 'admin');
-- Obtenu : ERROR: duplicate key value violates unique constraint "utilisateur_login_ci"
--          DETAIL: Key (lower(login))=(a.diop) already exists.

-- Quelles lettres STRIDE un login partagé permet-il ?
-- S (usurpation) : se connecter comme l'autre personne qui porte le même login ;
-- R (répudiation) : impossible de savoir qui a réellement agi (une validation ne s'impute à personne) ;
-- I (divulgation) : voir les ruches, positions GPS et récoltes de l'homonyme ;
-- E (élévation de privilèges) : si l'un des comptes a plus de droits (un A.Diop admin), l'autre en hérite.
