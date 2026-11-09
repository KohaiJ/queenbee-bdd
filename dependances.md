Dépendances fonctionnelles

LES DF DE EXTRAIT_PLAT

site_id -> site_nom, pays : un site a un seul nom et un seul pays.

ruche_code -> site_id, telephone : une ruche est installée sur un seul site et appartient à une seule apicultrice, identifiée par son téléphone.

telephone -> apicultrice, cooperative : un téléphone désigne une seule apicultrice et sa coopérative.

ruche_code, horodatage -> poids_kg, temp_int_c : il n'y a qu'une mesure par ruche et par instant.

FERMETURE DE {site_id}

Tour 0 : aucune DF utilisée. {site_id}
Tour 1 : site_id -> site_nom, pays. On ajoute site_nom et pays.
Tour 2 : plus rien ne s'ajoute.
Conclusion : {site_id}+ = {site_id, site_nom, pays}, soit 3 colonnes sur 10. Ce n'est pas une clé.

FERMETURE DE {ruche_code}

Tour 0 : aucune DF utilisée. {ruche_code}
Tour 1 : ruche_code -> site_id, telephone. On ajoute site_id et telephone.
Tour 2 : site_id -> site_nom, pays et telephone -> apicultrice, cooperative. On ajoute site_nom, pays, apicultrice et cooperative.
Tour 3 : plus rien ne s'ajoute.
Conclusion : {ruche_code}+ contient 7 colonnes sur 10. Il manque horodatage, poids_kg et temp_int_c. Ce n'est pas une clé.

FERMETURE DE {ruche_code, horodatage}

Tour 0 : aucune DF utilisée. {ruche_code, horodatage}
Tour 1 : ruche_code -> site_id, telephone et ruche_code, horodatage -> poids_kg, temp_int_c. On ajoute site_id, telephone, poids_kg et temp_int_c.
Tour 2 : site_id -> site_nom, pays et telephone -> apicultrice, cooperative. On ajoute site_nom, pays, apicultrice et cooperative.
Tour 3 : plus rien ne s'ajoute.
Conclusion : {ruche_code, horodatage}+ contient les 10 colonnes. C'est une clé.

CLÉ CANDIDATE

La clé candidate de extrait_plat est {ruche_code, horodatage}.

On ne peut rien en retirer : sans horodatage, {ruche_code}+ ne donne que 7 colonnes (une ruche a 48 mesures) ; sans ruche_code, {horodatage}+ = {horodatage}, car toutes les ruches mesurent au même instant. Elle est donc minimale.

CONFRONTATION AUX DONNÉES

Les quatre DF ci-dessus donnent 0 ligne de contre-exemple dans les données.

La fausse dépendance apicultrice -> telephone est contredite : « Aminata Diop » a 2 téléphones.
