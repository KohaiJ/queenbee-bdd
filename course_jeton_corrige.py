"""course_jeton_corrige.py : deux clics simultanes, version CORRIGEE.
Verifier et agir en une seule instruction : UPDATE ... WHERE utilise_le IS NULL ... RETURNING.
Usage : python course_jeton_corrige.py RT-a.diop-12"""
import sys
import threading
import time

import psycopg

JETON = sys.argv[1]
depart = threading.Barrier(2)
resultats = {}


def rafraichir(nom):
    try:
        with psycopg.connect(dbname="queenbee") as conn:
            depart.wait()
            row = conn.execute(
                """UPDATE jeton SET utilise_le = now()
                   WHERE valeur = %s AND utilise_le IS NULL AND expire_le > now()
                   RETURNING id, utilisateur_id""", (JETON,)).fetchone()
            if row is None:
                resultats[nom] = "refusé : jeton déjà utilisé ou expiré"
                return
            time.sleep(0.2)
            conn.execute(
                "INSERT INTO session_app (utilisateur_id, jeton_id) VALUES (%s, %s)",
                (row[1], row[0]))
            resultats[nom] = "accepté : session ouverte"
    except psycopg.Error as e:
        resultats[nom] = "erreur de la base : " + e.diag.message_primary


fils = [threading.Thread(target=rafraichir, args=(n,)) for n in ("clic 1", "clic 2")]
for f in fils:
    f.start()
for f in fils:
    f.join()
for nom in sorted(resultats):
    print(nom, "->", resultats[nom])
with psycopg.connect(dbname="queenbee") as conn:
    n = conn.execute("""SELECT count(*) FROM session_app s
                        JOIN jeton j ON j.id = s.jeton_id
                        WHERE j.valeur = %s""", (JETON,)).fetchone()[0]
print("sessions ouvertes avec ce jeton :", n)
