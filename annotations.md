QUESTION 1 : DE QUOI LE SYSTÈME DOIT-IL SE SOUVENIR ?

Le système doit se souvenir de 9 choses : le site, la coopérative, l’apicultrice, la ruche, la mesure, l’inspection, la récolte, l’alerte et l’utilisateur (compte de connexion).

Le pays, le poids ou la température ne sont pas des choses à part entière : ce sont des informations sur un site ou sur une mesure.

QUESTION 2 : CE QU’ON GARDE SUR CHACUNE, ET CE QUI LA DISTINGUE

Site : on garde son code, son nom et son pays. Ce qui le distingue : son code lisible (SN-CASA).

Coopérative : on garde son nom. Ce qui la distingue : un identifiant attribué.

Apicultrice : on garde son nom et son téléphone. Ce qui la distingue : un identifiant attribué, car le nom ne suffit pas (il y a deux « Aminata Diop »).

Ruche : on garde son code, sa latitude, sa longitude et sa date d’installation. Ce qui la distingue : un identifiant attribué (le code est aussi unique).

Mesure : on garde l’horodatage, le poids, la température intérieure, la température extérieure, l’humidité, l’activité sonore et le niveau de batterie. Ce qui la distingue : la ruche et l’horodatage.

Inspection : on garde la date, l’état de la colonie, la présence de la reine et les observations. Ce qui la distingue : un identifiant attribué.

Récolte : on garde la date, la quantité, le statut (déclarée ou validée) et la date de validation. Ce qui la distingue : un identifiant attribué.

Alerte : on garde le type (essaimage, vol, capteur silencieux), le niveau de confiance, la date et le statut. Ce qui la distingue : un identifiant attribué.

Utilisateur : on garde le login et le rôle (apicultrice, coordinateur, gestionnaire, administrateur). Ce qui le distingue : un identifiant attribué.

QUESTION 3 : COMMENT SONT-ELLES LIÉES ?

Ruche et apicultrice : une ruche appartient à une seule apicultrice ; une apicultrice possède zéro, une ou plusieurs ruches.

Site et ruche : une ruche est installée sur un seul site ; un site accueille zéro, une ou plusieurs ruches.

Apicultrice et coopérative : une apicultrice adhère à au moins une coopérative ; une coopérative a zéro, une ou plusieurs adhérentes.

Ruche et mesure : une mesure vient d’une seule ruche ; une ruche émet zéro, une ou plusieurs mesures.

Ruche et récolte : une récolte vient d’une seule ruche ; une ruche produit zéro, une ou plusieurs récoltes.

Coordinateur et récolte validée : une récolte est validée par au plus un utilisateur ; un utilisateur valide zéro, une ou plusieurs récoltes.

Apicultrice et compte de connexion : une apicultrice a au plus un compte ; un compte appartient au plus à une apicultrice.

Liens supplémentaires du modèle :

Apicultrice et site : une apicultrice est rattachée à un seul site ; un site a zéro, une ou plusieurs apicultrices.

Coopérative et site : une coopérative appartient à un seul site ; un site a zéro, une ou plusieurs coopératives.

Inspection et ruche : une inspection concerne une seule ruche ; une ruche a zéro, une ou plusieurs inspections.

Inspection et apicultrice : une inspection est réalisée par une seule apicultrice ; une apicultrice réalise zéro, une ou plusieurs inspections.

Alerte et ruche : une alerte concerne une seule ruche ; une ruche déclenche zéro, une ou plusieurs alertes.

Utilisateur et site : un utilisateur (coordinateur) est rattaché à au plus un site ; un site a zéro, un ou plusieurs utilisateurs.

QUESTION 4 : QU’EST-CE QUE LE SUJET NE DIT PAS ? (HYPOTHÈSES)

Une ruche peut-elle changer de site ? Hypothèse : oui, mais on ne garde que le site actuel, qui est toujours celui de son apicultrice.

Une ruche peut-elle changer d’apicultrice ? Hypothèse : oui, on ne garde que la propriétaire actuelle.

Qui peut valider une récolte, et peut-on revenir sur une validation ? Hypothèse : seul un coordinateur valide ; une récolte validée garde son validateur et sa date de validation, sans retour en arrière possible.

Une apicultrice peut-elle adhérer à une coopérative d’un autre site ? Hypothèse : oui en théorie ; dans le jeu d’essai, chacune adhère à la coopérative de son site.

Les gestionnaires et les administrateurs sont-ils rattachés à un site ? Hypothèse : non, seul le coordinateur l’est.

Que devient l’historique d’une apicultrice qui quitte l’association ? Hypothèse : on le conserve, sans suppression physique.

QUESTION 5 : QU’EST-CE QUI INTÉRESSERAIT UN VOLEUR OU UN FRAUDEUR ?

La position GPS des ruches : savoir où aller voler une ruche.

Le nom et le téléphone des apicultrices : hameçonnage, extorsion ou faux appels « de l’association ».

Les récoltes : gonfler une quantité déclarée ou la faire valider sans contrôle.

Les mesures : rejouer un ancien poids normal pour masquer un vol en cours.

Le login : se connecter à la place d’un coordinateur pour valider des récoltes.

PARTIE C : SENSIBILITÉ ET MENACES (STRIDE)

SITE. Sensibilité : interne. Qui lit : tous les rôles. Qui modifie : l’administrateur. Menace T (altération) : changer le pays d’un site fausse les statistiques par pays.

COOPÉRATIVE. Sensibilité : interne. Qui lit : le gestionnaire, l’administrateur et le coordinateur. Qui modifie : le gestionnaire. Menace T (altération) : rattacher une apicultrice à une coopérative qui n’est pas la sienne.

APICULTRICE. Sensibilité : confidentielle (données personnelles). Qui lit : l’apicultrice elle-même, le coordinateur de son site et le gestionnaire. Qui modifie : le gestionnaire et l’administrateur. Menace I (divulgation) : récupérer le nom et le téléphone pour de l’hameçonnage ou de l’extorsion.

RUCHE. Sensibilité : confidentielle. Qui lit : sa propriétaire et le coordinateur du site. Qui modifie : le coordinateur et l’administrateur. Menace I (divulgation) : connaître la position GPS pour voler la ruche.

MESURE. Sensibilité : interne. Qui lit : la propriétaire et le coordinateur. Qui modifie : les capteurs uniquement, par insertion. Menace T (altération), et S si l’attaquant se fait passer pour le capteur : une mesure rejouée, dont l’ancien poids normal masque un vol.

INSPECTION. Sensibilité : interne. Qui lit : la propriétaire et le coordinateur. Qui modifie : l’apicultrice qui inspecte. Menace R (répudiation) : nier avoir fait, ou ne pas avoir fait, une inspection.

RÉCOLTE. Sensibilité : confidentielle (valeur économique). Qui lit : la propriétaire, le coordinateur et le gestionnaire. Qui modifie : l’apicultrice, qui déclare, et le coordinateur, qui valide. Menace R (répudiation) : une récolte validée sans qu’on sache par qui. Menace T (altération) : une quantité gonflée.

ALERTE. Sensibilité : interne. Qui lit : le coordinateur et l’apicultrice concernée. Qui modifie : le système. Menace D (indisponibilité) : supprimer ou noyer les alertes pour qu’un vol ne soit pas signalé.

UTILISATEUR. Sensibilité : critique. Qui lit : l’administrateur. Qui modifie : l’administrateur. Menace S (usurpation) : se connecter à la place d’un autre. Menace E (élévation de privilèges) : s’attribuer le rôle administrateur. Menace R (répudiation) : effacer l’historique des actions pour cacher ce qu’on a fait.

Lettres STRIDE utilisées : S, T, R, I, D et E.

Les trois cas imposés sont couverts : la mesure rejouée (MESURE), la récolte validée sans qu’on sache par qui (RÉCOLTE) et l’effacement de l’historique des actions (UTILISATEUR).
SCHÉMA RELATIONNEL (LAB 2)

Règle 1 : chaque entité devient une table, et son identifiant devient la clé primaire.
Règle 2 : chaque lien 1,1 – 0,n devient une clé étrangère, placée du côté 1,1. Le lien de validation (0,1 – 0,n) donne une clé étrangère qui peut rester vide : validee_par.
Règle 3 : le lien n,n ADHÈRE devient une table supplémentaire, adhesion, dont la clé primaire réunit les deux clés étrangères et qui garde la date d'adhésion.
Règle 4 : le lien 0,1 – 0,1 entre l'apicultrice et son compte devient une clé étrangère apicultrice_id dans utilisateur, avec UNIQUE pour qu'une apicultrice n'ait jamais deux comptes.

Les tables (clé primaire en premier, # devant une clé étrangère) :

site (id, nom, pays)
cooperative (id, nom, #site_id)
apicultrice (id, nom, telephone, #site_id)
ruche (id, code, latitude, longitude, date_installation, #site_id, #apicultrice_id)
adhesion (#apicultrice_id, #cooperative_id, date_adhesion)
utilisateur (id, login, role, #site_id, #apicultrice_id UNIQUE)
mesure (id, horodatage, poids_kg, temp_int_c, temp_ext_c, humidite_pct, activite_sonore_db, batterie_pct, #ruche_id)
inspection (id, date_inspection, etat_colonie, reine_presente, observations, #ruche_id, #apicultrice_id)
recolte (id, date_recolte, quantite_kg, statut, validee_le, #ruche_id, #validee_par)
alerte (id, type, confiance, date_alerte, statut, #ruche_id)

Total : 10 tables et 14 clés étrangères.

Choix des clés primaires : le site garde un code lisible (SN-CASA), court, stable et pas secret. Toutes les autres tables utilisent un UUID généré par la base, car un numéro 1, 2, 3 se devine : qui voit /ruches/42 essaie /ruches/43.

Règles de protection ajoutées dans schema.sql : le code de ruche et le téléphone sont uniques ; le couple (ruche, horodatage) est unique pour refuser le rejeu d'une mesure ; une quantité récoltée doit être positive ; une récolte validée doit avoir un validateur et une date de validation ; le niveau de confiance d'une alerte est compris entre 0 et 1.
