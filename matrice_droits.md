Matrice des droits – Queen Bee

Principe : tout est ferme (REVOKE ... FROM PUBLIC), puis chaque groupe recoit le minimum, par des vues.

SES RUCHES ET LEURS MESURES
Apicultrice : lire, ses ruches seulement (v_mes_ruches, v_mes_mesures).
Coordinateur : non (il lit les ruches de son site, ligne plus bas).
Gestionnaire : non.
Admin : non.

DECLARER UNE RECOLTE
Apicultrice : sur ses ruches seulement (INSERT sur v_mes_recoltes, colonnes ruche_id, date_recolte, quantite_kg, avec WITH CHECK OPTION).
Coordinateur : non.
Gestionnaire : non.
Admin : non.

VALIDER UNE RECOLTE (UC-C02)
Apicultrice : non.
Coordinateur : oui, sur son site et seulement si elle est declaree, par la fonction valider_recolte (pas d'UPDATE sur la table).
Gestionnaire : non.
Admin : non.

RUCHES ET TELEPHONES DE SON SITE
Apicultrice : non.
Coordinateur : lire, son site seulement (v_ruches_site, v_recoltes_site).
Gestionnaire : non.
Admin : non.

SYNTHESE ET EXPORT (UC-G01, UC-G02)
Apicultrice : non.
Coordinateur : non.
Gestionnaire : lire (synthese_site_jour, v_export_bailleur pseudonymise).
Admin : non.

COMPTES UTILISATEURS (UC-AD01)
Apicultrice : son propre compte seulement, en lecture (v_moi).
Coordinateur : son propre compte seulement, en lecture (v_moi).
Gestionnaire : son propre compte seulement, en lecture (v_moi).
Admin : lire, creer, modifier ; pas supprimer (on desactive un compte, on ne l'efface pas).

JOURNAL D'AUDIT
Apicultrice : non.
Coordinateur : non.
Gestionnaire : non.
Admin : lire seulement. Personne ne peut le modifier ni le vider (triggers journal_ajout_seul et journal_sans_truncate).

LIMITE CONNUE

Le proprietaire des tables (postgres, superutilisateur) peut desactiver le trigger du journal :
ALTER TABLE journal_audit DISABLE TRIGGER journal_ajout_seul; passe.
La base ne peut pas se proteger de son propre superutilisateur. C'est pourquoi le journal doit aussi etre copie hors de la base, au fil de l'eau, vers le SIEM prevu par le cahier des charges : une copie que l'administrateur de la base ne peut pas modifier.
