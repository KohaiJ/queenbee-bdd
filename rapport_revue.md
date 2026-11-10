Revue de securite de notre base – Groupe ___

Correspondance : f.ba du sujet = a.diop (apicultrice de SN-CASA). Fatou Ba pour les attaques = Awa Diop (+221 77 100 00 03), seule de son nom dans notre base.

SYNTHESE

Controles passes : 11 / 12 (C9 echoue).
Constats : 0 critique, 0 haute, 2 moyennes, 1 basse.
Failles demontrees et corrigees : 3 (P1, P2, P3).

FAILLES DEMONTREES (ETAPES 10.1 ET 10.2)

P1 · Injection par le tri (recherche_vuln.py)
Preuve, par erreur : tri = cast((SELECT telephone FROM apicultrice WHERE nom = 'Awa Diop') AS int) -> Erreur : invalid input syntax for type integer: "+221 77 100 00 03". Le telephone sort dans le message d'erreur.
Preuve, a l'aveugle : tri = CASE WHEN (SELECT substr(telephone, 6, 2) FROM apicultrice WHERE nom = 'Awa Diop') = '77' THEN code ELSE longitude::text END -> ordre par code (014, 021, 099) ; avec '78' -> ordre par longitude (099, 021, 014). L'ordre repond oui ou non.
Preuve, empilee : tri = code; DROP TABLE journal_audit -> cannot insert multiple commands into a prepared statement. Echec, mais seulement grace aux parametres.
Correction : recherche.py, liste blanche (code, date_installation), sql.Identifier, message d'erreur generique.
Retest : meme saisie par erreur -> Tri refusé : choisissez code ou date_installation.

P2 · v_carte_ruches trop large
Preuve : en a.diop, SELECT nom, telephone FROM apicultrice -> permission denied ; mais v_carte_ruches montre 11 ruches et 8 telephones. Elevation de privilege par une vue qui s'execute avec les droits de son proprietaire.
Correction : corrections.sql, vue reecrite (ses ruches seulement, code et position, sans nom ni telephone, security_barrier).
Retest : en a.diop, 2 lignes (SN-CASA-014, SN-CASA-021), sans telephone.

P3 · Fuite par fonction espion
Preuve : en a.diop, SELECT code FROM v_mes_ruches WHERE pg_temp.espion(code, latitude, longitude) -> le resultat montre 2 ruches, mais les NOTICE donnent la position GPS des 11 ruches. Pour un voleur, c'est la carte complete.
Correction : corrections.sql, security_barrier sur toutes les vues filtrantes, et REVOKE TEMPORARY ON DATABASE FROM PUBLIC.
Retest : meme session, les NOTICE ne montrent plus que SN-CASA-014 et SN-CASA-021 ; nouvelle session, permission denied to create temporary tables in database "queenbee".

CONSTATS DE LA GRILLE

C1 · aucune fonction executable par PUBLIC : requete C1 -> 0 ligne. Passe.
C2 · les SECURITY DEFINER fixent leur search_path : audit_ligne et valider_recolte -> search_path=public, pg_temp. Passe.
C3 · les vues filtrantes sont des barrieres : les 7 vues filtrantes ont security_barrier=true. v_export_bailleur et synthese_site_jour n'en ont pas : elles ne filtrent pas par utilisateur, ne montrent que des agregats pseudonymises et ne sont donnees qu'au gestionnaire. Explique, pas une faute. Passe.
C4 · aucune vue hors perimetre : en awa.diop, 1 ruche (SN-CASA-099) dans v_mes_ruches, v_mes_mesures, v_carte_ruches, 1 compte dans v_moi ; v_ruches_site -> permission denied. Passe.
C5 · journal en ajout seul : UPDATE, DELETE, TRUNCATE -> trois refus. Passe.
C6 · le journal nomme le vrai acteur : action en SET ROLE "admin.beeafrica" -> journal : admin.beeafrica | utilisateur | UPDATE. Passe.
C7 · une apicultrice n'ecrit pas chez une autre : en awa.diop, recolte sur SN-CASA-014 -> new row violates check option for view "v_mes_recoltes". Passe.
C8 · un jeton ne sert qu'une fois : python course_jeton.py sur un jeton neuf -> 1 session (contrainte session_jeton_unique). Passe.
C9 · pas de requete construite par + ou f" : echoue, voir R1.
C10 · les preuves ne partent pas en cascade : mesure, inspection, recolte, alerte -> RESTRICT. Passe.
C11 · pas de mot de passe dans le depot : git grep -i password ne trouve que la variable PGPASSWORD du README, avec une valeur d'exemple. roles.sql cree les comptes sans mot de passe, a definir hors depot avec \password. A discuter, passe.
C12 · la base se reconstruit avec nos fichiers : base vide, jour 1 puis les huit fichiers du jour 2 avec ON_ERROR_STOP -> aucune erreur, et les tests de contournement donnent les memes resultats. Passe.

R1 · C9 · Gravite basse
Constat : query_vuln.py (jour 1) et recherche_vuln.py construisent leur requete avec +.
Preuve : git grep -n -E '" \+|f"' -- '*.py' -> query_vuln.py ligne 6 (requete SQL concatenee) et recherche_vuln.py (tri concatene). course_jeton.py et course_jeton_corrige.py ressortent aussi, mais ils ne concatenent qu'un message d'affichage, pas une requete : faux positif, explique.
Correction : ce sont des demonstrations volontaires, signalees en tete de fichier (VOLONTAIREMENT vulnerable). Les versions utilisees sont query.py et recherche.py. A retirer d'un depot de production.
Retest : les versions corrigees n'ont aucune concatenation.

R2 · Coherence ruche et apicultrice · Gravite moyenne
Constat : rien n'empechait une ruche d'etre sur un autre site que son apicultrice (regle metier, revue BCNF du lab 6).
Preuve : avant correction, UPDATE ruche SET site_id = 'CM-BAME' WHERE code = 'SN-CASA-014' -> accepte (dans une transaction annulee).
Correction : corrections.sql, UNIQUE (id, site_id) sur apicultrice et cle etrangere composee ruche_site_apicultrice_fk.
Retest : la meme commande -> violates foreign key constraint "ruche_site_apicultrice_fk".

R3 · Les scripts se connectent en superutilisateur · Gravite moyenne
Constat : query.py, recherche.py et les scripts de course se connectent avec PGUSER=postgres. Si une injection passait, elle aurait tous les droits, triggers du journal compris.
Preuve : psql -c "SELECT current_user, rolsuper FROM pg_roles WHERE rolname = current_user" -> postgres | t.
Correction proposee : un role applicatif dedie (LOGIN, mot de passe hors depot), avec SELECT sur les seules colonnes utiles de ruche.
Retest : non fait (il faut un mot de passe hors depot). Constat ouvert.
