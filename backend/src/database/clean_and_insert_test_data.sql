-- Script de nettoyage et insertion des données de test pour le système de matching
-- Exécuter dans phpMyAdmin pour créer des équipes, joueurs et annonces avec abonnements premium

USE freeagent_db;

-- ================================================
-- ÉTAPE 1: NETTOYAGE DES DONNÉES EXISTANTES
-- ================================================

-- Supprimer les données de test existantes dans l'ordre des dépendances
DELETE FROM user_limits WHERE user_id IN (
    SELECT id FROM users WHERE email LIKE '%@asvel.com' 
    OR email LIKE '%@parisbasketball.com'
    OR email LIKE '%@monacobasket.com'
    OR email LIKE '%@blmetropole92.com'
    OR email LIKE '%@strasbourg-ig.com'
    OR email LIKE '%@lemansbasket.com'
    OR email LIKE '%@basketeur.com'
);

DELETE FROM subscriptions WHERE user_id IN (
    SELECT id FROM users WHERE email LIKE '%@asvel.com' 
    OR email LIKE '%@parisbasketball.com'
    OR email LIKE '%@monacobasket.com'
    OR email LIKE '%@blmetropole92.com'
    OR email LIKE '%@strasbourg-ig.com'
    OR email LIKE '%@lemansbasket.com'
    OR email LIKE '%@basketeur.com'
);

DELETE FROM annonces WHERE user_id IN (
    SELECT id FROM users WHERE email LIKE '%@asvel.com' 
    OR email LIKE '%@parisbasketball.com'
    OR email LIKE '%@monacobasket.com'
    OR email LIKE '%@blmetropole92.com'
    OR email LIKE '%@strasbourg-ig.com'
    OR email LIKE '%@lemansbasket.com'
);

DELETE FROM player_profiles WHERE user_id IN (
    SELECT id FROM users WHERE email LIKE '%@basketeur.com'
);

DELETE FROM club_profiles WHERE user_id IN (
    SELECT id FROM users WHERE email LIKE '%@asvel.com' 
    OR email LIKE '%@parisbasketball.com'
    OR email LIKE '%@monacobasket.com'
    OR email LIKE '%@blmetropole92.com'
    OR email LIKE '%@strasbourg-ig.com'
    OR email LIKE '%@lemansbasket.com'
);

DELETE FROM users WHERE email LIKE '%@asvel.com' 
    OR email LIKE '%@parisbasketball.com'
    OR email LIKE '%@monacobasket.com'
    OR email LIKE '%@blmetropole92.com'
    OR email LIKE '%@strasbourg-ig.com'
    OR email LIKE '%@lemansbasket.com'
    OR email LIKE '%@basketeur.com';

SELECT 'Nettoyage des données existantes terminé' as Status;

-- ================================================
-- ÉTAPE 2: CRÉATION DES UTILISATEURS ÉQUIPES (PREMIUM)
-- ================================================

INSERT INTO users (name, email, password, profile_type, subscription_type, subscription_expiry, is_premium) VALUES
('ASVEL Lyon-Villeurbanne', 'recrutement@asvel.com', '$2b$10$ExampleHashForTeam001', 'club', 'premium_pro', '2025-12-31 23:59:59', 1),
('Paris Basketball', 'rh@parisbasketball.com', '$2b$10$ExampleHashForTeam002', 'club', 'premium_pro', '2025-12-31 23:59:59', 1),
('Monaco Basket', 'direction@monacobasket.com', '$2b$10$ExampleHashForTeam003', 'club', 'premium_basic', '2025-09-30 23:59:59', 1),
('Boulogne-Levallois', 'recrutement@blmetropole92.com', '$2b$10$ExampleHashForTeam004', 'club', 'premium_pro', '2025-11-30 23:59:59', 1),
('Strasbourg IG', 'contact@strasbourg-ig.com', '$2b$10$ExampleHashForTeam005', 'club', 'premium_basic', '2025-10-31 23:59:59', 1),
('Le Mans Sarthe', 'recrutement@lemansbasket.com', '$2b$10$ExampleHashForTeam006', 'club', 'premium_pro', '2025-12-31 23:59:59', 1);

-- ================================================
-- ÉTAPE 3: CRÉATION DES PROFILS D'ÉQUIPES
-- ================================================

INSERT INTO club_profiles (user_id, club_name, level, location, description) VALUES
((SELECT id FROM users WHERE email = 'recrutement@asvel.com'), 'ASVEL Lyon-Villeurbanne', 'Pro A', 'Lyon', 'Club de haut niveau, multiple champion de France, participations européennes régulières'),
((SELECT id FROM users WHERE email = 'rh@parisbasketball.com'), 'Paris Basketball', 'Pro A', 'Paris', 'Club ambitieux de la capitale, récemment promu en Pro A avec des objectifs européens'),
((SELECT id FROM users WHERE email = 'direction@monacobasket.com'), 'AS Monaco Basket', 'Pro A', 'Monaco', 'Club historique de la Principauté, formation de qualité et ambitions européennes'),
((SELECT id FROM users WHERE email = 'recrutement@blmetropole92.com'), 'Boulogne-Levallois Métropole 92', 'Pro A', 'Boulogne-Billancourt', 'Club francilien avec une forte identité, centre de formation reconnu'),
((SELECT id FROM users WHERE email = 'contact@strasbourg-ig.com'), 'Strasbourg IG', 'Pro A', 'Strasbourg', 'Club alsacien historique, excellent centre de formation'),
((SELECT id FROM users WHERE email = 'recrutement@lemansbasket.com'), 'Le Mans Sarthe Basket', 'Pro A', 'Le Mans', 'Club sarthois ambitieux avec une belle salle et des supporters fidèles');

-- ================================================
-- ÉTAPE 4: CRÉATION DES UTILISATEURS JOUEURS
-- ================================================

INSERT INTO users (name, email, password, profile_type, subscription_type, subscription_expiry, is_premium) VALUES
-- Joueurs Premium Pro
('Antoine Diot', 'antoine.diot@basketeur.com', '$2b$10$ExampleHashPlayer001', 'player', 'premium_pro', '2025-12-31 23:59:59', 1),
('Paul Lacombe', 'paul.lacombe@basketeur.com', '$2b$10$ExampleHashPlayer002', 'player', 'premium_pro', '2025-11-30 23:59:59', 1),
('Marcus Lewis', 'marcus.lewis@basketeur.com', '$2b$10$ExampleHashPlayer003', 'player', 'premium_basic', '2025-10-31 23:59:59', 1),
('Théo Maledon', 'theo.maledon@basketeur.com', '$2b$10$ExampleHashPlayer004', 'player', 'premium_pro', '2025-12-31 23:59:59', 1),
('Hugo Besson', 'hugo.besson@basketeur.com', '$2b$10$ExampleHashPlayer005', 'player', 'premium_basic', '2025-09-30 23:59:59', 1),

-- Joueurs Premium Basic
('Maxime Courby', 'maxime.courby@basketeur.com', '$2b$10$ExampleHashPlayer006', 'player', 'premium_basic', '2025-08-31 23:59:59', 1),
('Jordan Usher', 'jordan.usher@basketeur.com', '$2b$10$ExampleHashPlayer007', 'player', 'premium_basic', '2025-10-31 23:59:59', 1),
('Vincent Poirier', 'vincent.poirier@basketeur.com', '$2b$10$ExampleHashPlayer008', 'player', 'premium_pro', '2025-12-31 23:59:59', 1),
('Isaia Cordinier', 'isaia.cordinier@basketeur.com', '$2b$10$ExampleHashPlayer009', 'player', 'premium_pro', '2025-11-30 23:59:59', 1),
('Léo Westermann', 'leo.westermann@basketeur.com', '$2b$10$ExampleHashPlayer010', 'player', 'premium_basic', '2025-09-30 23:59:59', 1),

-- Joueurs Free (pour comparaison)
('Thomas Heurtel', 'thomas.heurtel@basketeur.com', '$2b$10$ExampleHashPlayer011', 'player', 'free', NULL, 0),
('Joffrey Lauvergne', 'joffrey.lauvergne@basketeur.com', '$2b$10$ExampleHashPlayer012', 'player', 'free', NULL, 0),
('Terry Tarpey', 'terry.tarpey@basketeur.com', '$2b$10$ExampleHashPlayer013', 'player', 'free', NULL, 0);

-- ================================================
-- ÉTAPE 5: CRÉATION DES PROFILS JOUEURS
-- ================================================

INSERT INTO player_profiles (user_id, age, height, weight, position, experience_years, level, achievements, bio) VALUES

-- Joueurs expérimentés Pro A
((SELECT id FROM users WHERE email = 'antoine.diot@basketeur.com'), 32, 1.93, 84, 'Meneur', 12, 'Pro A', 'International français, multiple champion de France, expérience EuroLeague', 'Meneur expérimenté avec une excellente vision de jeu et un leadership naturel. Passé par plusieurs clubs européens de haut niveau.'),

((SELECT id FROM users WHERE email = 'paul.lacombe@basketeur.com'), 28, 2.05, 95, 'Ailier-Fort', 8, 'Pro A', 'Champion de France 2021, sélection équipe de France', 'Ailier-fort polyvalent, excellent défenseur avec une bonne adresse à 3 points. Formation française de qualité.'),

((SELECT id FROM users WHERE email = 'marcus.lewis@basketeur.com'), 26, 1.91, 86, 'Arrière', 6, 'Pro A', 'Meilleur marqueur Pro B 2020, rookie de l année', 'Arrière américain naturalisé, excellent scoreur avec une mentalité de winner. Adaptation rapide au basket européen.'),

((SELECT id FROM users WHERE email = 'theo.maledon@basketeur.com'), 23, 1.93, 82, 'Meneur', 4, 'Pro A', 'Expérience NBA, international français espoirs', 'Jeune meneur talentueux formé en France, expérience NBA avec Oklahoma City. Retour en Europe avec de grandes ambitions.'),

((SELECT id FROM users WHERE email = 'hugo.besson@basketeur.com'), 22, 1.98, 87, 'Arrière-Ailier', 3, 'Pro A', 'Champion d Europe U20, révélation de l année', 'Jeune talent français très prometteur, polyvalence offensive et belle progression défensive.'),

-- Joueurs confirmés
((SELECT id FROM users WHERE email = 'maxime.courby@basketeur.com'), 29, 2.08, 110, 'Pivot', 9, 'Pro A', 'Défenseur de l année 2019, international français', 'Pivot défensif de référence, excellent rebondeur avec une présence rassurante dans la raquette.'),

((SELECT id FROM users WHERE email = 'jordan.usher@basketeur.com'), 25, 2.01, 93, 'Ailier', 4, 'Pro A', 'Champion NCAA, rookie européen prometteur', 'Ailier athlétique avec un potentiel énorme, adaptation en cours au jeu européen.'),

((SELECT id FROM users WHERE email = 'vincent.poirier@basketeur.com'), 30, 2.13, 115, 'Pivot', 10, 'Pro A', 'Expérience NBA, EuroLeague, international français', 'Pivot mobile avec expérience internationale, capable de jouer loin du cercle.'),

((SELECT id FROM users WHERE email = 'isaia.cordinier@basketeur.com'), 27, 1.95, 88, 'Arrière-Ailier', 7, 'Pro A', 'International français, expérience EuroLeague', 'Arrière-ailier complet, bon défenseur avec une polyvalence appréciée des coaches.'),

((SELECT id FROM users WHERE email = 'leo.westermann@basketeur.com'), 31, 1.98, 89, 'Meneur-Arrière', 11, 'Pro A', 'International français, leader d expérience', 'Meneur-arrière expérimenté, excellent passeur et leader vocal sur le terrain.'),

-- Joueurs free
((SELECT id FROM users WHERE email = 'thomas.heurtel@basketeur.com'), 34, 1.89, 81, 'Meneur', 14, 'Pro A', 'International français, expérience EuroLeague', 'Meneur créateur de classe mondiale, vision de jeu exceptionnelle.'),

((SELECT id FROM users WHERE email = 'joffrey.lauvergne@basketeur.com'), 32, 2.11, 115, 'Pivot', 12, 'Pro A', 'Expérience NBA, international français', 'Pivot technique avec expérience NBA et internationale.'),

((SELECT id FROM users WHERE email = 'terry.tarpey@basketeur.com'), 29, 2.01, 95, 'Ailier-Fort', 8, 'Pro A', 'Naturalisé français, polyvalence remarquable', 'Ailier-fort américain naturalisé, grande polyvalence et intelligence de jeu.');

-- ================================================
-- ÉTAPE 6: CRÉATION DES ANNONCES DE RECRUTEMENT RÉALISTES
-- ================================================

INSERT INTO annonces (user_id, title, description, type, requirements, salary_range, location, status, created_at) VALUES

-- ASVEL - Recherche meneur titulaire
((SELECT id FROM users WHERE email = 'recrutement@asvel.com'), 
'Recherche Meneur Titulaire Pro A', 
'L ASVEL recherche un meneur de jeu expérimenté pour la saison 2025-2026. Nous souhaitons un joueur capable de diriger une équipe ambitieuse avec des objectifs européens. Le candidat idéal possède une expérience significative en Pro A ou dans un championnat équivalent.',
'recrutement',
'- Minimum 5 ans d expérience en Pro A ou équivalent
- Poste: Meneur de jeu
- Age: 25-33 ans
- Expérience internationale appréciée
- Leadership et mentalité de winner
- Bonne condition physique
- Maîtrise du français souhaitée',
'80000-120000€/an',
'Lyon',
'open',
'2024-12-01 10:00:00'),

-- Paris Basketball - Recherche ailier-fort
((SELECT id FROM users WHERE email = 'rh@parisbasketball.com'),
'Ailier-Fort pour Projet Européen',
'Paris Basketball, club ambitieux de Pro A, recherche un ailier-fort pour renforcer son secteur intérieur. Nous visons les playoffs et une qualification européenne. Le profil recherché doit allier physique et technique.',
'recrutement',
'- Taille minimum: 2m03
- Poste: Ailier-Fort
- Expérience Pro A ou EuroLeague
- Age: 23-30 ans
- Bon rebondeur défensif
- Adresse à 3 points appréciée
- Mentalité professionnelle',
'60000-90000€/an',
'Paris',
'open',
'2024-12-02 14:30:00'),

-- Monaco - Recherche jeune talent
((SELECT id FROM users WHERE email = 'direction@monacobasket.com'),
'Jeune Arrière Prometteur',
'L AS Monaco Basket recherche un jeune arrière talentueux dans le cadre de sa politique de formation. Nous offrons un environnement professionnel de qualité et un temps de jeu évolutif.',
'recrutement',
'- Age: 20-25 ans
- Poste: Arrière ou Arrière-Ailier
- Formation française appréciée
- Potentiel de progression
- Bon état d esprit
- Motivation et ambition
- Niveau Pro A ou Pro B',
'35000-55000€/an',
'Monaco',
'open',
'2024-12-03 09:15:00'),

-- Boulogne-Levallois - Recherche pivot
((SELECT id FROM users WHERE email = 'recrutement@blmetropole92.com'),
'Pivot Défensif Expérimenté',
'Boulogne-Levallois Métropole 92 recherche un pivot défensif pour solidifier sa raquette. Nous privilégions l expérience et le leadership pour encadrer notre groupe jeune.',
'recrutement',
'- Taille minimum: 2m08
- Poste: Pivot
- Age: 28-35 ans
- Expérience Pro A minimum 6 ans
- Excellent rebondeur
- Leadership et mentalité défensive
- Capacité d encadrement',
'50000-75000€/an',
'Boulogne-Billancourt',
'open',
'2024-12-04 11:45:00'),

-- Strasbourg - Recherche polyvalent
((SELECT id FROM users WHERE email = 'contact@strasbourg-ig.com'),
'Joueur Polyvalent Postes 2-3-4',
'Strasbourg IG recherche un joueur polyvalent capable d évoluer sur plusieurs postes. Nous valorisons l intelligence de jeu et la capacité d adaptation.',
'recrutement',
'- Postes: Arrière-Ailier-Ailier Fort
- Taille: 1m95 à 2m05
- Age: 24-32 ans
- Polyvalence offensive et défensive
- Expérience Pro A ou équivalent
- Bon coéquipier
- Mentalité de travail',
'45000-70000€/an',
'Strasbourg',
'open',
'2024-12-05 16:20:00'),

-- Le Mans - Recherche meneur remplaçant
((SELECT id FROM users WHERE email = 'recrutement@lemansbasket.com'),
'Meneur Remplaçant de Qualité',
'Le Mans Sarthe Basket recherche un meneur pour compléter sa rotation. Profil de backup capable de prendre des responsabilités ponctuellement.',
'recrutement',
'- Poste: Meneur de jeu
- Age: 22-30 ans
- Expérience Pro A ou Pro B
- Acceptation du rôle de remplaçant
- Bonne relation avec le staff
- Capacité à être prêt rapidement
- Formation française appréciée',
'30000-45000€/an',
'Le Mans',
'open',
'2024-12-06 13:10:00'),

-- Annonce de coaching
((SELECT id FROM users WHERE email = 'recrutement@asvel.com'),
'Coach Assistant Spécialisé Défense',
'L ASVEL recherche un coach assistant spécialisé dans le travail défensif pour compléter son staff technique.',
'coaching',
'- Expérience coaching minimum 5 ans
- Spécialisation défensive
- Diplômes coaching requis
- Expérience Pro A appréciée
- Anglais souhaité pour communication internationale',
'40000-60000€/an',
'Lyon',
'open',
'2024-12-07 10:30:00');

-- ================================================
-- ÉTAPE 7: CRÉATION DES ABONNEMENTS
-- ================================================

INSERT INTO subscriptions (user_id, subscription_type, price, duration_months, start_date, end_date, status, payment_method) VALUES
-- Abonnements équipes
((SELECT id FROM users WHERE email = 'recrutement@asvel.com'), 'premium_pro', 90.00, 12, '2024-01-01 00:00:00', '2025-12-31 23:59:59', 'active', 'credit_card'),
((SELECT id FROM users WHERE email = 'rh@parisbasketball.com'), 'premium_pro', 90.00, 12, '2024-02-01 00:00:00', '2025-12-31 23:59:59', 'active', 'credit_card'),
((SELECT id FROM users WHERE email = 'direction@monacobasket.com'), 'premium_basic', 59.99, 12, '2024-01-15 00:00:00', '2025-09-30 23:59:59', 'active', 'paypal'),
((SELECT id FROM users WHERE email = 'recrutement@blmetropole92.com'), 'premium_pro', 90.00, 12, '2024-03-01 00:00:00', '2025-11-30 23:59:59', 'active', 'credit_card'),
((SELECT id FROM users WHERE email = 'contact@strasbourg-ig.com'), 'premium_basic', 59.99, 12, '2024-02-15 00:00:00', '2025-10-31 23:59:59', 'active', 'bank_transfer'),
((SELECT id FROM users WHERE email = 'recrutement@lemansbasket.com'), 'premium_pro', 90.00, 12, '2024-01-01 00:00:00', '2025-12-31 23:59:59', 'active', 'credit_card'),

-- Abonnements joueurs
((SELECT id FROM users WHERE email = 'antoine.diot@basketeur.com'), 'premium_pro', 90.00, 12, '2024-01-10 00:00:00', '2025-12-31 23:59:59', 'active', 'credit_card'),
((SELECT id FROM users WHERE email = 'paul.lacombe@basketeur.com'), 'premium_pro', 90.00, 12, '2024-02-01 00:00:00', '2025-11-30 23:59:59', 'active', 'paypal'),
((SELECT id FROM users WHERE email = 'marcus.lewis@basketeur.com'), 'premium_basic', 59.99, 12, '2024-03-01 00:00:00', '2025-10-31 23:59:59', 'active', 'credit_card'),
((SELECT id FROM users WHERE email = 'theo.maledon@basketeur.com'), 'premium_pro', 90.00, 12, '2024-01-15 00:00:00', '2025-12-31 23:59:59', 'active', 'credit_card'),
((SELECT id FROM users WHERE email = 'hugo.besson@basketeur.com'), 'premium_basic', 59.99, 12, '2024-04-01 00:00:00', '2025-09-30 23:59:59', 'active', 'bank_transfer'),
((SELECT id FROM users WHERE email = 'maxime.courby@basketeur.com'), 'premium_basic', 59.99, 12, '2024-03-15 00:00:00', '2025-08-31 23:59:59', 'active', 'paypal'),
((SELECT id FROM users WHERE email = 'jordan.usher@basketeur.com'), 'premium_basic', 59.99, 12, '2024-02-20 00:00:00', '2025-10-31 23:59:59', 'active', 'credit_card'),
((SELECT id FROM users WHERE email = 'vincent.poirier@basketeur.com'), 'premium_pro', 90.00, 12, '2024-01-05 00:00:00', '2025-12-31 23:59:59', 'active', 'credit_card'),
((SELECT id FROM users WHERE email = 'isaia.cordinier@basketeur.com'), 'premium_pro', 90.00, 12, '2024-03-10 00:00:00', '2025-11-30 23:59:59', 'active', 'paypal'),
((SELECT id FROM users WHERE email = 'leo.westermann@basketeur.com'), 'premium_basic', 59.99, 12, '2024-04-15 00:00:00', '2025-09-30 23:59:59', 'active', 'bank_transfer');

-- ================================================
-- ÉTAPE 8: INITIALISATION DES LIMITES UTILISATEURS
-- ================================================

INSERT INTO user_limits (user_id, applications_count, opportunities_posted, messages_sent, last_reset_date) VALUES
-- Limites équipes
((SELECT id FROM users WHERE email = 'recrutement@asvel.com'), 0, 2, 5, CURDATE()),
((SELECT id FROM users WHERE email = 'rh@parisbasketball.com'), 0, 1, 3, CURDATE()),
((SELECT id FROM users WHERE email = 'direction@monacobasket.com'), 0, 1, 2, CURDATE()),
((SELECT id FROM users WHERE email = 'recrutement@blmetropole92.com'), 0, 1, 4, CURDATE()),
((SELECT id FROM users WHERE email = 'contact@strasbourg-ig.com'), 0, 1, 1, CURDATE()),
((SELECT id FROM users WHERE email = 'recrutement@lemansbasket.com'), 0, 1, 2, CURDATE()),

-- Limites joueurs
((SELECT id FROM users WHERE email = 'antoine.diot@basketeur.com'), 2, 0, 8, CURDATE()),
((SELECT id FROM users WHERE email = 'paul.lacombe@basketeur.com'), 1, 0, 5, CURDATE()),
((SELECT id FROM users WHERE email = 'marcus.lewis@basketeur.com'), 0, 0, 3, CURDATE()),
((SELECT id FROM users WHERE email = 'theo.maledon@basketeur.com'), 1, 0, 4, CURDATE()),
((SELECT id FROM users WHERE email = 'hugo.besson@basketeur.com'), 0, 0, 2, CURDATE()),
((SELECT id FROM users WHERE email = 'maxime.courby@basketeur.com'), 1, 0, 1, CURDATE()),
((SELECT id FROM users WHERE email = 'jordan.usher@basketeur.com'), 0, 0, 3, CURDATE()),
((SELECT id FROM users WHERE email = 'vincent.poirier@basketeur.com'), 2, 0, 6, CURDATE()),
((SELECT id FROM users WHERE email = 'isaia.cordinier@basketeur.com'), 1, 0, 4, CURDATE()),
((SELECT id FROM users WHERE email = 'leo.westermann@basketeur.com'), 0, 0, 2, CURDATE()),
((SELECT id FROM users WHERE email = 'thomas.heurtel@basketeur.com'), 1, 0, 2, CURDATE()),
((SELECT id FROM users WHERE email = 'joffrey.lauvergne@basketeur.com'), 0, 0, 1, CURDATE()),
((SELECT id FROM users WHERE email = 'terry.tarpey@basketeur.com'), 1, 0, 1, CURDATE());

-- ================================================
-- ÉTAPE 9: VÉRIFICATION DES DONNÉES CRÉÉES
-- ================================================

SELECT 'RÉSUMÉ DES DONNÉES DE TEST CRÉÉES' as Info;

SELECT 
    'ÉQUIPES PREMIUM' as Type,
    COUNT(*) as Nombre
FROM users u 
JOIN club_profiles cp ON u.id = cp.user_id 
WHERE u.profile_type = 'club' AND u.is_premium = 1

UNION ALL

SELECT 
    'JOUEURS PREMIUM' as Type,
    COUNT(*) as Nombre
FROM users u 
JOIN player_profiles pp ON u.id = pp.user_id 
WHERE u.profile_type = 'player' AND u.is_premium = 1

UNION ALL

SELECT 
    'JOUEURS FREE' as Type,
    COUNT(*) as Nombre
FROM users u 
JOIN player_profiles pp ON u.id = pp.user_id 
WHERE u.profile_type = 'player' AND u.is_premium = 0

UNION ALL

SELECT 
    'ANNONCES ACTIVES' as Type,
    COUNT(*) as Nombre
FROM annonces 
WHERE status = 'open'

UNION ALL

SELECT 
    'ABONNEMENTS ACTIFS' as Type,
    COUNT(*) as Nombre
FROM subscriptions 
WHERE status = 'active';

-- Afficher les annonces créées
SELECT 
    a.title as 'Titre Annonce',
    u.name as 'Équipe',
    a.type as 'Type',
    a.salary_range as 'Salaire',
    a.location as 'Localisation'
FROM annonces a
JOIN users u ON a.user_id = u.id
WHERE a.status = 'open'
ORDER BY a.created_at DESC;

SELECT 'Données de test créées avec succès ! Le système de matching peut maintenant être testé.' as Message; 