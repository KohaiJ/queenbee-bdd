"""recherche_vuln.py : VOLONTAIREMENT vulnerable (lab 10, injection par le tri).
Le site est parametre, mais le tri est recopie dans la requete."""
import psycopg

conn = psycopg.connect(dbname="queenbee")
site = input("Site : ")
tri = input("Trier par (code ou date_installation) : ")
sql = ("SELECT code, site_id, date_installation FROM ruche "
       "WHERE site_id = %s ORDER BY " + tri)          # valeur parametree, tri recopie
try:
    for row in conn.execute(sql, (site,)):
        print(row)
except psycopg.Error as e:
    print("Erreur :", e)                               # affiche l'erreur de la base
