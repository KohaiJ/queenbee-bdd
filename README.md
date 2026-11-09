TP Jour 1 Base de donnees Queen Bee

Prerequis
Installer PostgreSQL 18, Python 3, Git et VS Code
Creer la base queenbee dans PostgreSQL

Preparation
Ouvrir un terminal dans le dossier du projet
Activer l environnement Python avec source .venv/bin/activate
Definir l utilisateur, le mot de passe et l hote avec export PGUSER=postgres PGPASSWORD=motdepasse PGHOST=localhost

Lab 1 Modele entite association
Lire annotations.md pour les entites, les liens, les hypotheses et les menaces
Ouvrir mcd.drawio dans draw.io pour voir le MCD
mcd.png est l image du MCD

Lab 2 Modele relationnel
Creer les tables avec psql -d queenbee -v ON_ERROR_STOP=1 -f schema.sql
Remplir les tables avec psql -d queenbee -v ON_ERROR_STOP=1 -f donnees.sql
Lancer les tests avec psql -d queenbee -f tests_schema.sql

Lab 3 Requetes et injection SQL
Lancer les requetes avec psql -d queenbee -v ON_ERROR_STOP=1 -f requetes.sql
Lancer la version vulnerable avec python query_vuln.py
Lancer la version protegee avec python query.py

Lab 4 Dependances fonctionnelles
Creer la table a plat avec psql -d queenbee -v ON_ERROR_STOP=1 -f plat.sql
Lire dependances.md pour les dependances, les fermetures et la cle candidate
Lancer les controles et les logins uniques avec psql -d queenbee -f contraintes.sql

Lab 5 Formes normales
Recreer la table a plat avec psql -d queenbee -v ON_ERROR_STOP=1 -f plat.sql
Provoquer les anomalies avec psql -d queenbee -f anomalies.sql
Lancer la migration une premiere fois avec psql -d queenbee -v ON_ERROR_STOP=1 -f migration_3nf.sql
Corriger les donnees avec psql -d queenbee -f nettoyage.sql
Relancer la migration avec psql -d queenbee -v ON_ERROR_STOP=1 -f migration_3nf.sql
Verifier que rien n est perdu avec psql -d queenbee -f preuve.sql
Lire normalisation.md pour les anomalies, les formes normales et la conclusion

Repartir de zero
Relancer schema.sql puis donnees.sql
