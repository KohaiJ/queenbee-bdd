# | Saisie                | query_vuln.py               | query.py |
# | code normal           | 1 ligne                     | 1 ligne  |
# | ' OR '1'='1           | 11 lignes (toutes)          | 0 ligne  |
# | ' UNION SELECT ... -- | 8 noms + téléphones         | 0 ligne  |
# Pourquoi query.py résiste : la saisie est envoyée à PostgreSQL comme une VALEUR,
# séparément du texte de la requête (%s est un paramètre, pas un morceau de chaîne).
# Elle n'est jamais analysée comme du SQL : elle est seulement comparée à la colonne code.
import psycopg

conn = psycopg.connect(dbname="queenbee")
code = input("Code ruche : ")
rows = conn.execute(
    "SELECT code, site_id FROM ruche WHERE code = %s", (code,)
).fetchall()
print(len(rows), "ligne(s)")
for row in rows:
    print(row)
