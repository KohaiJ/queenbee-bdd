Normalisation jour 2 – Groupe ___

Correspondance avec le sujet : notre base du jour 1 n'a pas les memes personnes que la base de reference.
Fatou Ba (+221 77 100 00 02) = chez nous Aminata Diop de SN-KOLD, au meme telephone.
Quatre telephones du sujet n'existent pas chez nous (+221 77 200 00 01, +225 07 100 00 01, +225 07 100 00 02, +237 6 77 100 01) : remplaces par +221 77 100 00 03, +225 07 00 00 05, +225 07 00 00 06 et +237 670 00 00 07.

LAB 6

ETAPE 6.1 · ANALYSER LA TABLE RECUE

Dependances de formation_plat :
(telephone, theme) -> formateur : pour un theme, une apicultrice n'a qu'un formateur, celui qui signe son attestation.
formateur -> theme : un formateur n'enseigne qu'un theme.
Les trois tests GROUP BY ... HAVING donnent 0 ligne : les donnees ne contredisent aucune de ces regles.

Cles candidates :
(telephone, theme), la cle primaire.
(telephone, formateur) : le formateur donne le theme, donc (telephone, formateur) determine aussi toute la ligne.

3NF ? Oui. Les trois colonnes font partie d'une cle candidate, donc aucune colonne non-cle ne depend d'autre chose que d'une cle.
BCNF ? Non. formateur -> theme part de formateur, qui n'est pas une super-cle de la table.

Anomalie provoquee (BEGIN ... ROLLBACK) : en passant Moussa Sarr en capteurs sur la seule ligne du +221 77 100 00 02, la table accepte sans message. Resultat : Moussa Sarr | {capteurs,varroa}. La regle formateur -> theme est violee.

ETAPE 6.2 · DECOUPER SANS PERTE

Mauvais decoupage, p1 (telephone, theme) et p2 (theme, formateur) : la jointure donne 16 lignes au lieu de 8, dont 8 inventees. Le +221 77 100 00 02 serait suivi par trois formateurs varroa (Moussa Sarr, Ibrahima Fall, Kouassi Yao).
Pourquoi : la colonne commune, theme, n'est la cle d'aucun des deux morceaux. Un theme a plusieurs formateurs et plusieurs apicultrices : la jointure croise tout le monde.

Bon decoupage : formateur (id, nom UNIQUE, theme) et suivi_formation (apicultrice_id, formateur_id). La colonne commune est le formateur, cle de son morceau.
Resultats : INSERT 0 5 (cinq formateurs), INSERT 0 8 (huit suivis), et la double comparaison EXCEPT donne 0 ligne : rien de perdu, rien d'invente.

Quelle contrainte garantit formateur -> theme ? Le UNIQUE sur formateur.nom : un formateur n'a qu'une ligne, donc un seul theme. La cle primaire id le garantit aussi pour la cle etrangere.
Pourquoi suivi_formation pointe vers apicultrice(id) au lieu de recopier le telephone ? Le telephone peut changer : une copie pourrait diverger de l'original. C'est aussi une donnee personnelle qu'on ne multiplie pas. L'id est stable, et la cle etrangere garantit que l'apicultrice existe.

ETAPE 6.3 · LA REGLE PERDUE ET LE TRIGGER

Apres le decoupage, plus aucune table ne contient a la fois l'apicultrice et le theme. Sans trigger, on inscrit le +221 77 100 00 02 chez Ibrahima Fall (varroa) alors qu'elle a deja Moussa Sarr : INSERT 0 1, puis Aminata Diop | varroa | {"Ibrahima Fall","Moussa Sarr"}. Ligne supprimee ensuite.

Avec le trigger suivi_formation_df :
Ibrahima Fall (varroa) : ERROR: DF violée : cette apicultrice a déjà un formateur pour ce thème
Khady Ndiaye (recolte, theme nouveau pour elle) : INSERT 0 1

Pour aller plus loin (sans trigger) : recopier theme dans suivi_formation, avec UNIQUE (apicultrice_id, theme) et une cle etrangere composee (formateur_id, theme) vers formateur (id, theme). Ce n'est pas en BCNF : formateur_id -> theme part d'une colonne qui n'est pas une cle de suivi_formation. On revient a une 3NF, mais la copie ne peut plus diverger, car la cle etrangere la verifie. C'est une redondance controlee.

ETAPE 6.4 · REVUE BCNF DE TOUT LE SCHEMA

site : id -> nom, pays. Partie gauche = super-cle : oui. BCNF : oui.
cooperative : id -> nom, site_id. Oui. BCNF : oui.
apicultrice : id -> tout ; telephone (UNIQUE) -> tout. Les deux parties gauches sont des cles. BCNF : oui.
ruche : id -> tout ; code (UNIQUE) -> tout. Mais si la regle metier dit que la ruche est sur le site de son apicultrice, alors apicultrice_id -> site_id, et apicultrice_id n'est pas une cle de ruche. BCNF : non (voir plus bas).
adhesion : (apicultrice_id, cooperative_id) -> date_adhesion. Oui. BCNF : oui.
utilisateur : id -> tout ; apicultrice_id (UNIQUE) et lower(login) (UNIQUE) -> tout. BCNF : oui.
mesure : id -> tout ; (ruche_id, horodatage) (UNIQUE) -> tout. BCNF : oui.
inspection : id -> tout. BCNF : oui (apicultrice_id est celle qui inspecte, pas une copie de la proprietaire).
recolte : id -> tout. BCNF : oui.
alerte : id -> tout. BCNF : oui.
formateur : id -> nom, theme ; nom (UNIQUE) -> id, theme. BCNF : oui.
suivi_formation : (apicultrice_id, formateur_id), aucune autre colonne. BCNF : oui.
formation_plat : 3NF mais pas BCNF (etape 6.1). Elle ne sert que de fichier recu ; la reference, ce sont formateur et suivi_formation.

ruche.site_id et apicultrice.site_id : la requete montre que chaque apicultrice n'a de ruches que sur son site.
Regle metier ou coincidence ? Regle metier : notre hypothese du lab 1 (et le cahier des charges) dit qu'une ruche est sur le site de son apicultrice. ruche.site_id est donc une copie qui peut diverger.
Qui garantissait la coherence ? Rien : seules les donnees etaient coherentes (test 7 du lab 2). Correction appliquee au lab 10 (corrections.sql, constat R2) : UNIQUE (id, site_id) sur apicultrice et cle etrangere composee (apicultrice_id, site_id) de ruche vers apicultrice. Une ruche placee sur un autre site est desormais refusee.

LAB 7

ETAPE 7.1 · MESURER AVANT DE COPIER

volume.sql : INSERT 0 47520 (11 ruches x 90 jours x 48 mesures).
Tableau de bord SN-CASA : 144 mesures par jour (3 ruches x 48 dans notre base ; le sujet en compte 4).
Execution Time sur les tables : ___ ms

ETAPE 7.2 · LA SYNTHESE ET SON PRIX

Memes chiffres dans synthese_site_jour.
Execution Time dans la vue materialisee : ___ ms

Vol simule le 15 mars a 6 h sur SN-CASA-014 (8,40 kg) : la synthese ne montre rien avant le REFRESH, puis 2027-03-15 | 1 mesure | poids_min = 8.40.
Si la vue n'est rafraichie que la nuit, le vol reste invisible jusqu'a 24 heures, le temps pour le voleur de partir loin.
Un vol se detecte donc dans les mesures brutes, au fil de l'eau (une alerte calculee a l'insertion de chaque mesure), jamais dans la synthese. La synthese sert au tableau de bord, pas a la securite.

ETAPE 7.3 · L'EXPORT POUR LE BAILLEUR

Casser le hache simple du +221 77 100 00 02 : retrouve en ___ s. Il ne reste qu'un million de possibilites une fois le debut connu : un sha256 sans cle n'est pas un pseudonyme.

v_export_bailleur : 8 lignes pour 11 ruches, sans nom ni telephone, positions arrondies (12.6 | -16.3). La verification de la cle dans la definition de la vue renvoie f.

Colonnes retirees, et pourquoi :
nom et telephone : ils identifient directement la personne.
id de l'apicultrice : remplace par un HMAC avec cle secrete, sinon l'id permettrait de rejoindre nos autres tables.
code de la ruche : il permettrait de relier l'export a nos donnees internes.
latitude et longitude precises : arrondies a 0,1 degre (environ 11 km). La position exacte, c'est l'adresse d'un vol.
date d'installation, mesures, recoltes declarees non validees : inutiles au bailleur. Minimiser, c'est n'exporter que le necessaire.

ETAPE 7.4 · LE JOURNAL D'AUDIT

Pourquoi ligne_id n'est pas une cle etrangere ? Le journal doit survivre a la ligne qu'il decrit. Avec une cle etrangere, soit on ne pourrait plus supprimer la recolte, soit (en CASCADE) sa suppression effacerait la preuve. Et un meme journal couvre plusieurs tables.
avant et apres recopient des lignes entieres : est-ce acceptable ? Oui, c'est le but : une preuve figee de ce qui a change. Mais ces copies contiennent des donnees (y compris personnelles pour utilisateur) : lecture reservee a l'admin, ajout seul, et une duree de conservation a fixer.
Pourquoi clock_timestamp() et pas now() ? now() donne l'heure du debut de la transaction : toutes les lignes d'une longue transaction auraient la meme heure. clock_timestamp() donne l'heure reelle de chaque ecriture, ce qui permet de reconstituer l'ordre des actions.
