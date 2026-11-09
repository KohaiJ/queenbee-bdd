# query_vuln.py : VOLONTAIREMENT vulnérable à l'injection SQL (démonstration du lab 3)
import psycopg

conn = psycopg.connect(dbname="queenbee")
code = input("Code ruche : ")
sql = "SELECT code, site_id FROM ruche WHERE code = '" + code + "'"
print("Requête envoyée :", sql)
for row in conn.execute(sql):
    print(row)
