
BEGIN;

INSERT INTO site (id, nom, pays) VALUES
  ('SN-CASA', 'Casamance', 'Sénégal'),
  ('SN-KOLD', 'Kolda',     'Sénégal'),
  ('CI-KORH', 'Korhogo',   'Côte d''Ivoire'),
  ('CM-BAME', 'Bamenda',   'Cameroun');

INSERT INTO cooperative (nom, site_id) VALUES
  ('Coop Miel de Casamance', 'SN-CASA'),
  ('Coop Abeilles de Kolda', 'SN-KOLD'),
  ('Coop Korhogo Miel',      'CI-KORH'),
  ('Coop Bamenda Honey',     'CM-BAME');

INSERT INTO apicultrice (nom, telephone, site_id) VALUES
  ('Aminata Diop',   '+221 77 100 00 01', 'SN-CASA'),
  ('Aminata Diop',   '+221 77 100 00 02', 'SN-KOLD'),   
  ('Awa Diop',       '+221 77 100 00 03', 'SN-CASA'),
  ('Fatou Sow',      '+221 77 100 00 04', 'SN-KOLD'),
  ('Mariam Kone',    '+225 07 00 00 05',  'CI-KORH'),
  ('Adjoua Kouassi', '+225 07 00 00 06',  'CI-KORH'),
  ('Grace Nkeng',    '+237 670 00 00 07', 'CM-BAME'),
  ('Esther Fon',     '+237 670 00 00 08', 'CM-BAME');


INSERT INTO ruche (code, latitude, longitude, date_installation, site_id, apicultrice_id) VALUES
  ('SN-CASA-014', 12.58310, -16.27190, '2024-03-10', 'SN-CASA', (SELECT id FROM apicultrice WHERE telephone = '+221 77 100 00 01')),
  ('SN-CASA-021', 12.58420, -16.27050, '2024-05-02', 'SN-CASA', (SELECT id FROM apicultrice WHERE telephone = '+221 77 100 00 01')),
  ('SN-CASA-099', 12.59010, -16.26500, '2025-01-15', 'SN-CASA', (SELECT id FROM apicultrice WHERE telephone = '+221 77 100 00 03')),
  ('SN-KOLD-011', 12.89400, -14.94100, '2024-06-20', 'SN-KOLD', (SELECT id FROM apicultrice WHERE telephone = '+221 77 100 00 02')),
  ('SN-KOLD-012', 12.89520, -14.94330, '2024-07-01', 'SN-KOLD', (SELECT id FROM apicultrice WHERE telephone = '+221 77 100 00 04')),
  ('CI-KORH-001',  9.45800,  -5.62900, '2023-11-12', 'CI-KORH', (SELECT id FROM apicultrice WHERE telephone = '+225 07 00 00 05')),
  ('CI-KORH-002',  9.45950,  -5.63110, '2024-02-08', 'CI-KORH', (SELECT id FROM apicultrice WHERE telephone = '+225 07 00 00 05')),
  ('CI-KORH-003',  9.46100,  -5.62750, '2024-09-30', 'CI-KORH', (SELECT id FROM apicultrice WHERE telephone = '+225 07 00 00 06')),
  ('CM-BAME-001',  5.95970,  10.14590, '2024-04-18', 'CM-BAME', (SELECT id FROM apicultrice WHERE telephone = '+237 670 00 00 07')),
  ('CM-BAME-002',  5.96120,  10.14800, '2024-08-22', 'CM-BAME', (SELECT id FROM apicultrice WHERE telephone = '+237 670 00 00 07')),
  ('CM-BAME-003',  5.95800,  10.14300, '2025-02-05', 'CM-BAME', (SELECT id FROM apicultrice WHERE telephone = '+237 670 00 00 08'));

INSERT INTO adhesion (apicultrice_id, cooperative_id)
SELECT a.id, c.id FROM apicultrice a JOIN cooperative c ON c.site_id = a.site_id;

INSERT INTO utilisateur (login, role, site_id, apicultrice_id)
SELECT lower(left(nom, 1)) || '.' || lower(split_part(nom, ' ', 2)), 'apicultrice', site_id, id
FROM apicultrice;

INSERT INTO utilisateur (login, role, site_id) VALUES
  ('k.ndiaye', 'coordinateur', 'SN-CASA'),
  ('admin',    'admin',        NULL);

INSERT INTO mesure (ruche_id, horodatage, poids_kg, temp_int_c, temp_ext_c,
                    humidite_pct, activite_sonore_db, batterie_pct)
SELECT r.id,
       TIMESTAMPTZ '2026-11-02 00:00+00' + h * INTERVAL '30 minutes',
       round((25 + random() * 15)::numeric, 2),
       round((33 + random() * 3)::numeric, 1),
       round((22 + random() * 12)::numeric, 1),
       50 + floor(random() * 30)::int,
       round((40 + random() * 30)::numeric, 1),
       100 - h
FROM ruche r CROSS JOIN generate_series(0, 47) AS h;

INSERT INTO inspection (ruche_id, apicultrice_id, date_inspection, etat_colonie, reine_presente, observations)
SELECT r.id, r.apicultrice_id, v.d::date, v.etat, v.reine, v.obs
FROM (VALUES
  ('SN-CASA-014', '2026-10-20', 'bonne',   true,  'cadres de couvain pleins'),
  ('SN-CASA-014', '2026-11-01', 'bonne',   true,  'miellée en cours'),
  ('SN-KOLD-011', '2026-10-25', 'moyenne', true,  'quelques varroas'),
  ('CI-KORH-001', '2026-10-28', 'faible',  false, 'reine absente, cellules royales'),
  ('CI-KORH-003', '2026-10-30', 'bonne',   true,  NULL),
  ('CM-BAME-001', '2026-10-31', 'bonne',   true,  'colonie calme')
) AS v(code, d, etat, reine, obs)
JOIN ruche r ON r.code = v.code;

INSERT INTO recolte (ruche_id, date_recolte, quantite_kg, statut, validee_par, validee_le)
SELECT r.id, v.d::date, v.q, v.statut,
       CASE WHEN v.statut = 'validee' THEN (SELECT id FROM utilisateur WHERE role = 'coordinateur') END,
       CASE WHEN v.statut = 'validee' THEN TIMESTAMPTZ '2026-11-03 10:00+00' END
FROM (VALUES
  ('SN-CASA-014', '2026-10-15', 12.50, 'validee'),
  ('SN-CASA-021', '2026-10-18',  8.00, 'declaree'),
  ('CI-KORH-002', '2026-10-22', 10.20, 'declaree')
) AS v(code, d, q, statut)
JOIN ruche r ON r.code = v.code;

INSERT INTO alerte (ruche_id, type, confiance, statut)
SELECT r.id, v.t, v.c, v.s
FROM (VALUES
  ('SN-CASA-099', 'vol',                0.85, 'ouverte'),
  ('CI-KORH-002', 'essaimage',          0.70, 'ouverte'),
  ('CM-BAME-001', 'capteur_silencieux', 0.95, 'fermee'),
  ('SN-CASA-014', 'essaimage',          0.40, 'fermee')
) AS v(code, t, c, s)
JOIN ruche r ON r.code = v.code;

COMMIT;
