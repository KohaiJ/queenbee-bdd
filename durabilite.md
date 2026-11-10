Durabilite – Groupe ___

LES REGLAGES

SHOW fsync; -> on
SHOW synchronous_commit; -> on
SHOW wal_level; -> replica
Un COMMIT ne repond qu'une fois le journal d'ecriture (WAL) enregistre sur le disque.

LA SAUVEGARDE VERIFIEE

pg_dump de queenbee au format custom (queenbee_j2.dump), empreinte SHA-256 dans queenbee_j2.dump.sha256, restauration dans queenbee_restore.
Dans la copie : le meme nombre de lignes de journal, et DELETE FROM journal_audit est refuse (journal_audit est en ajout seul : DELETE interdit). Les triggers sont restaures avec la base.
Verification de l'empreinte : queenbee_j2.dump: OK.
Le fichier .dump n'est pas commite : il est gros et contient des donnees personnelles. Seule son empreinte l'est.

CE QU'ON PERDRAIT AVEC synchronous_commit = off

Le COMMIT repondrait avant que le WAL soit ecrit sur le disque. En cas de panne, les dernieres transactions confirmees (quelques centaines de millisecondes) seraient perdues, alors que l'application les croit enregistrees : une validation de recolte, une ligne de journal. La base reste coherente, mais pas durable.

POURQUOI GARDER L'EMPREINTE AILLEURS QUE LA SAUVEGARDE

Si l'empreinte est a cote de la sauvegarde, quelqu'un qui modifie la sauvegarde recalcule aussi l'empreinte, et la verification dit OK. L'empreinte gardee ailleurs (autre serveur, autre equipe, ou signee) prouve que la sauvegarde n'a pas ete touchee.

CE QUE pg_dump NE SAUVEGARDE PAS

Les roles et leurs appartenances (qb_apicultrice, a.diop...) : ils appartiennent au serveur, pas a la base. Il faut aussi pg_dumpall --roles-only, sinon les GRANT de la base restauree pointent vers des roles inexistants.

DURABILITE ET SAUVEGARDE

Durabilite (le D d'ACID) : une transaction validee survit a une panne du serveur (coupure de courant, plantage). Elle s'appuie sur le WAL.
Sauvegarde : une copie qui survit a la perte du disque, a une erreur humaine (DROP TABLE) ou a un rancongiciel. ACID ne protege pas d'un rancongiciel : il chiffre des donnees parfaitement durables. Seule une sauvegarde hors ligne, verifiee et restauree regulierement, protege.
