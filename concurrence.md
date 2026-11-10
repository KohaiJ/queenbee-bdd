Concurrence – Groupe ___

Correspondance : f.ba du sujet = a.diop ; jetons RT-a.diop-1 a RT-a.diop-30 ; SN-CASA-011 = SN-CASA-014 ; coord.sn = k.ndiaye.

ETAPE 9.1 · L'ACTION ET SA TRACE ENSEMBLE

La trace qui ment : le journal de l'application contient « récolte SN-CASA-014 validée par k.ndiaye », mais l'UPDATE a ete refuse par recolte_validation_tracee (pas de validee_par). Le journal affirme une validation qui n'a jamais eu lieu.

Dans une transaction : journal_audit passe de N a N+1 apres la validation complete (avec validee_par et validee_le). Apres SELECT 1 / 0 : division by zero, puis « current transaction is aborted, commands ignored until end of transaction block ». Apres ROLLBACK : retour a N, et la recolte est toujours declaree. L'action et sa trace partent ensemble, ou pas du tout.

ETAPE 9.2 · LA COURSE AU JETON, DANS DEUX TERMINAUX (RT-a.diop-1)

T1, terminal A : BEGIN
T2, terminal B : BEGIN
T3, terminal A : SELECT valeur, utilise_le ... -> RT-a.diop-1 | (vide) : jeton libre
T4, terminal B : SELECT valeur, utilise_le ... -> RT-a.diop-1 | (vide) : jeton libre aussi
T5, terminal A : UPDATE jeton SET utilise_le = now() ... -> UPDATE 1
T6, terminal A : INSERT INTO session_app ... -> INSERT 0 1
T7, terminal A : COMMIT
T8, terminal B : UPDATE jeton SET utilise_le = now() ... -> UPDATE 1
T9, terminal B : INSERT INTO session_app ... -> INSERT 0 1
T10, terminal B : COMMIT
T11 : 2 sessions ouvertes avec un seul jeton.
Les deux ont verifie avant que l'une agisse : c'est une race condition (« verifier, puis agir »).

ETAPE 9.3 · LA COURSE PAR UN PROGRAMME

course_jeton.py sur RT-a.diop-10 puis RT-a.diop-11 : clic 1 accepte, clic 2 accepte, 2 sessions a chaque fois.
course_jeton_corrige.py sur RT-a.diop-12 puis RT-a.diop-13 : un accepte, un refuse (jeton deja utilise ou expire), 1 session a chaque fois.

ETAPE 9.4 · LES QUATRE CORRECTIONS

SELECT ... FOR UPDATE
Ou agit-elle ? Dans le code, sur la lecture : la ligne lue est verrouillee.
Que voit la seconde requete ? Elle attend, puis voit utilise_le rempli et refuse.
Avantage : simple, garde la logique « verifier puis agir ».
Limite : il faut y penser partout ; un seul SELECT oublie et la faille revient. Les verrous peuvent bloquer ou creer des interblocages.

UPDATE ... WHERE utilise_le IS NULL ... RETURNING
Ou agit-elle ? Dans le code, en une seule instruction qui verifie et agit.
Que voit la seconde requete ? Elle attend le verrou, PostgreSQL reevalue la condition, qui n'est plus vraie : 0 ligne.
Avantage : atomique, sans verrou explicite, rapide.
Limite : la regle reste dans le code de l'application ; un autre programme peut ecrire autrement.

UNIQUE (jeton_id)
Ou agit-elle ? Dans la base, pour tous ceux qui ecrivent.
Que voit la seconde requete ? Une erreur duplicate key value violates unique constraint "session_jeton_unique".
Avantage : impossible a contourner, meme par le code vulnerable (rejoue sur RT-a.diop-14 : 1 session).
Limite : ne protege que ce qui s'exprime en unicite ; l'erreur doit etre geree proprement par l'application. Il a fallu nettoyer les doublons avant de la poser.

REPEATABLE READ
Ou agit-elle ? Dans la transaction (niveau d'isolation).
Que voit la seconde requete ? Son UPDATE echoue : could not serialize access due to concurrent update.
Avantage : detecte le conflit sans changer la requete.
Limite : l'application doit annuler et reessayer ; si on oublie le niveau d'isolation, retour a READ COMMITTED et a la faille.

Le trigger du lab 6 est-il aussi un « verifier, puis agir » ? Oui. Deux insertions simultanees pour la meme apicultrice et le meme theme, avec deux formateurs differents : chaque trigger cherche un suivi existant, ne voit pas la ligne non validee de l'autre, et les deux passent.
Ce qui le protegerait : une contrainte, pas un trigger. Recopier theme dans suivi_formation avec UNIQUE (apicultrice_id, theme) et une cle etrangere composee (formateur_id, theme). Sinon : SERIALIZABLE, ou verrouiller la ligne de l'apicultrice (SELECT ... FOR UPDATE) dans le trigger.
