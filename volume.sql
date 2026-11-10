-- volume.sql : lab 7, 90 jours de mesures, une toutes les 30 minutes, pour chaque ruche
-- A lancer UNE SEULE FOIS : une 2e fois, la contrainte mesure_anti_rejeu refuse tout (c'est voulu).
INSERT INTO mesure (ruche_id, horodatage, poids_kg, temp_int_c, temp_ext_c,
                    humidite_pct, activite_sonore_db, batterie_pct)
SELECT r.id,
       TIMESTAMPTZ '2026-12-14 00:00:00+00' + h * INTERVAL '30 minutes',
       round((30 + random() * 5)::numeric, 2),        -- poids entre 30 et 35 kg
       round((33 + random() * 2)::numeric, 1),        -- temperature interieure vers 34 degres
       round((20 + random() * 12)::numeric, 1),
       50 + floor(random() * 30)::int,
       round((40 + random() * 30)::numeric, 1),
       90                                             -- batterie a 90 %
FROM ruche r CROSS JOIN generate_series(0, 90 * 48 - 1) AS h;
-- Attendu : INSERT 0 47520 (11 ruches x 4 320 mesures)

ANALYZE mesure;
