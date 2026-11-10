Queen Bee – Dossier de conception, jour 2 – Groupe ___

LES 5 PARTIES
1. Schema normalise : 1_schema_normalise/
2. Roles et privileges : 2_roles_privileges/ (4 roles, 6 vues, 1 fonction de validation)
3. Trigger d'audit : 3_trigger_audit/ (tables auditees : recolte, utilisateur)
4. Test de concurrence : 4_test_concurrence/ (2 sessions avant, 1 apres)
5. Revue de securite : 5_revue_securite/ (3 constats, 1 corrige, 1 accepte, 1 ouvert ; 3 failles demontrees et corrigees)

RECONSTRUIRE (apres la base du jour 1 : schema.sql puis donnees.sql, avec -v ON_ERROR_STOP=1)
1. formation.sql
2. volume.sql (une seule fois)
3. denormalisation.sql
4. references.sql puis check.sql
5. audit.sql
6. roles.sql
7. jeton.sql
8. corrections.sql

NOS CHOIX PRINCIPAUX
BCNF et trigger pour les formations : le decoupage evite qu'un formateur change de theme sur une seule ligne, et le trigger retablit la regle « un formateur par theme ».
La synthese est rafraichie la nuit ; le vol est detecte dans les mesures brutes, pas dans la synthese.
L'export du bailleur est pseudonymise par HMAC avec une cle secrete, positions arrondies a 0,1 degre.
Les preuves (mesures, inspections, recoltes, alertes) sont en RESTRICT, les adhesions en CASCADE.
Chaque groupe ne voit que ses lignes par des vues barrieres ; la validation passe par une fonction, pas par un UPDATE.

LIMITES CONNUES
Un superutilisateur peut desactiver les triggers du journal : le journal doit aussi etre copie hors de la base (SIEM).
Le trigger des formations est un « verifier, puis agir » : deux insertions simultanees peuvent le contourner.
Les scripts se connectent encore en postgres (constat R3).
Les personnes du sujet absentes de notre base sont remplacees : f.ba = a.diop, coord.sn = k.ndiaye.
