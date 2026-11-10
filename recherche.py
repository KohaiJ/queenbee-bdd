"""recherche.py : version corrigee. Le tri est choisi dans une liste blanche,
insere avec sql.Identifier, et l'erreur de la base n'est jamais affichee."""
import psycopg
from psycopg import sql

TRIS = {
    "code": sql.Identifier("code"),
    "date_installation": sql.Identifier("date_installation"),
}

conn = psycopg.connect(dbname="queenbee")
site = input("Site : ")
tri = input("Trier par (code ou date_installation) : ")
if tri not in TRIS:
    print("Tri refusé : choisissez code ou date_installation")
    raise SystemExit(1)

requete = sql.SQL("SELECT code, site_id, date_installation FROM ruche "
                  "WHERE site_id = %s ORDER BY {}").format(TRIS[tri])
try:
    for row in conn.execute(requete, (site,)):
        print(row)
except psycopg.Error:
    print("Erreur : la recherche a échoué")            # message generique, rien de la base
