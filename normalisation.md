Normalisation – Groupe ___

LES TROIS ANOMALIES ET LA DÉPENDANCE QUI LES CAUSE

Anomalie de mise à jour (pays) : en changeant « Sénégal » en « Senegal » sur une seule ligne, le site SN-KOLD a deux pays et l'enquête passe de 3 à 4 pays. Cause : site_id -> pays. Le pays est recopié sur chaque mesure au lieu d'être écrit une seule fois.

Anomalie de mise à jour (téléphone) : en changeant le téléphone sur une seule ligne, Awa Diop a deux téléphones. Cause : ruche_code -> telephone, recopié sur les 48 mesures de la ruche.

Anomalie de suppression : en supprimant les mesures de Fatou Sow, son téléphone disparaît de la base. Cause : telephone -> apicultrice. L'apicultrice n'existe qu'à travers ses mesures.

Anomalie d'insertion : on ne peut pas ajouter le site SN-THIE tant qu'il n'a ni ruche ni mesure, car ruche_code fait partie de la clé et ne peut pas être vide. Cause : site_id -> site_nom, pays. Le site n'a pas de table à lui.

CLASSEMENT DES DÉPENDANCES (clé de extrait_plat : ruche_code, horodatage)

1NF, chaque case contient une seule valeur : aucune dépendance ne la viole. extrait_plat est en 1NF.

2NF, aucune colonne ne dépend d'une partie de la clé : violée par ruche_code -> site_id, telephone (et, par transitivité, site_nom, pays, apicultrice, cooperative). ruche_code n'est qu'une partie de la clé (ruche_code, horodatage).

3NF, aucune colonne ne dépend d'une colonne qui n'est pas la clé : violée par site_id -> site_nom, pays et par telephone -> apicultrice, cooperative. site_id et telephone ne sont pas des clés.

BCNF, la partie gauche de toute dépendance est une clé : violée par les trois dépendances ruche_code -> …, site_id -> … et telephone -> …, car aucune de ces parties gauches n'est une clé de extrait_plat.

LE DÉCOUPAGE : UNE TABLE PAR DÉTERMINANT

norm.site (site_id, site_nom, pays) : déterminant site_id.
norm.apicultrice (telephone, apicultrice, cooperative) : déterminant telephone.
norm.ruche (ruche_code, site_id, telephone) : déterminant ruche_code.
norm.mesure (ruche_code, horodatage, poids_kg, temp_int_c) : clé (ruche_code, horodatage).

Lancée sur les données corrompues, la migration est refusée (duplicate key sur site_pkey : SN-KOLD a deux pays). Après correction du pays et du téléphone, elle passe : 4 sites, 8 apicultrices, 11 ruches, 528 mesures.

VÉRIFICATION BCNF, TABLE PAR TABLE

norm.site : seule dépendance site_id -> site_nom, pays. site_id est la clé primaire. En BCNF.
norm.apicultrice : seule dépendance telephone -> apicultrice, cooperative. telephone est la clé primaire. En BCNF.
norm.ruche : seule dépendance ruche_code -> site_id, telephone. ruche_code est la clé primaire. En BCNF.
norm.mesure : seule dépendance ruche_code, horodatage -> poids_kg, temp_int_c. (ruche_code, horodatage) est la clé primaire. En BCNF.

Les quatre tables sont en BCNF.

PREUVE SANS PERTE

La vue norm.reconstruit rejoint les quatre tables. La comparaison avec extrait_plat dans les deux sens (EXCEPT puis EXCEPT inverse) renvoie 0 ligne : la décomposition est sans perte.

Attaques rejouées : un second pays pour SN-CASA est refusé par la clé primaire de norm.site ; un site sans ruche (SN-THIE) est accepté. L'enquête par pays redonne 3 pays.

CONCLUSION

Une seule ligne modifiée a fait passer l'enquête de 3 à 4 pays. Une base non normalisée ne peut pas servir de preuve.
