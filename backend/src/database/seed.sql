-- Suppression des données existantes (dans l'ordre des dépendances)
DELETE FROM club_profiles;
DELETE FROM dieteticienne_profiles;
DELETE FROM juriste_profiles;
DELETE FROM coach_basket_profiles;
DELETE FROM coach_pro_profiles;
DELETE FROM player_profiles;
DELETE FROM users;

-- Réinitialisation des auto-increments
ALTER TABLE club_profiles AUTO_INCREMENT = 1;
ALTER TABLE dieteticienne_profiles AUTO_INCREMENT = 1;
ALTER TABLE juriste_profiles AUTO_INCREMENT = 1;
ALTER TABLE coach_basket_profiles AUTO_INCREMENT = 1;
ALTER TABLE coach_pro_profiles AUTO_INCREMENT = 1;
ALTER TABLE player_profiles AUTO_INCREMENT = 1;
ALTER TABLE users AUTO_INCREMENT = 1;

-- Insertion des utilisateurs
INSERT INTO users (name, email, password, profile_type) VALUES
-- Joueurs
('Victor Wembanyama', 'victor.wembanyama@example.com', '$2b$10$example_hash', 'player'),
('Evan Fournier', 'evan.fournier@example.com', '$2b$10$example_hash', 'player'),
('Nando De Colo', 'nando.decolo@example.com', '$2b$10$example_hash', 'player'),
('Rudy Gobert', 'rudy.gobert@example.com', '$2b$10$example_hash', 'player'),
('Nicolas Batum', 'nicolas.batum@example.com', '$2b$10$example_hash', 'player'),

-- Coachs professionnels
('Vincent Collet', 'vincent.collet@example.com', '$2b$10$example_hash', 'coach_pro'),
('Pascal Donnadieu', 'pascal.donnadieu@example.com', '$2b$10$example_hash', 'coach_pro'),
('Laurent Foirest', 'laurent.foirest@example.com', '$2b$10$example_hash', 'coach_pro'),

-- Coachs de basket
('Frederic Fauthoux', 'frederic.fauthoux@example.com', '$2b$10$example_hash', 'coach_basket'),
('Jean-Aimé Toupane', 'jean-aime.toupane@example.com', '$2b$10$example_hash', 'coach_basket'),
('Laurent Pluvy', 'laurent.pluvy@example.com', '$2b$10$example_hash', 'coach_basket'),

-- Juristes
('Marie Dupont', 'marie.dupont@example.com', '$2b$10$example_hash', 'juriste'),
('Pierre Martin', 'pierre.martin@example.com', '$2b$10$example_hash', 'juriste'),
('Sophie Bernard', 'sophie.bernard@example.com', '$2b$10$example_hash', 'juriste'),
('Thomas Dubois', 'thomas.dubois@example.com', '$2b$10$example_hash', 'juriste'),
('Julie Moreau', 'julie.moreau@example.com', '$2b$10$example_hash', 'juriste'),

-- Diététiciennes
('Julie Petit', 'julie.petit@example.com', '$2b$10$example_hash', 'dieteticienne'),
('Camille Dubois', 'camille.dubois@example.com', '$2b$10$example_hash', 'dieteticienne'),
('Léa Moreau', 'lea.moreau@example.com', '$2b$10$example_hash', 'dieteticienne'),

-- Clubs
('ASVEL Villeurbanne', 'contact@asvel.com', '$2b$10$example_hash', 'club'),
('Stade Rennais Basket', 'contact@staderennaisbasket.com', '$2b$10$example_hash', 'club'),
('Paris Basketball', 'contact@parisbasketball.com', '$2b$10$example_hash', 'club');

-- Insertion des profils joueurs
INSERT INTO player_profiles (user_id, age, height, weight, position, experience_years, level, achievements, stats, bio) VALUES
(2, 20, 224, 95, 'Pivot', 5, 'Pro A', 'MVP LNB 2023', '{"points": 22.5, "rebounds": 10.2, "assists": 2.8, "steals": 1.5, "blocks": 3.2}', 'Jeune pivot prometteur avec un grand potentiel défensif'),
(3, 31, 201, 93, 'Arrière', 12, 'NBA', 'Champion NBA 2023', '{"points": 15.8, "rebounds": 2.5, "assists": 3.2, "steals": 1.1, "blocks": 0.3}', 'Arrière expérimenté avec un excellent tir à trois points'),
(4, 36, 196, 91, 'Meneur', 15, 'EuroLeague', 'MVP EuroLeague 2016', '{"points": 18.2, "rebounds": 2.8, "assists": 5.6, "steals": 1.2, "blocks": 0.1}', 'Meneur de jeu expérimenté avec une excellente vision du jeu'),
(5, 31, 216, 117, 'Pivot', 10, 'NBA', '3x DPOY NBA', '{"points": 12.8, "rebounds": 13.5, "assists": 1.2, "steals": 0.8, "blocks": 2.1}', 'Pivot défensif de premier plan'),
(6, 34, 203, 95, 'Ailier', 14, 'NBA', 'Champion NBA 2019', '{"points": 8.5, "rebounds": 5.2, "assists": 3.8, "steals": 1.0, "blocks": 0.7}', 'Ailier polyvalent avec une grande expérience');

-- Insertion des profils coachs professionnels
INSERT INTO coach_pro_profiles (user_id, speciality, experience_years, certifications, hourly_rate) VALUES
(7, 'Préparation physique', 20, 'DEJEPS, CQP', 150.00),
(8, 'Performance mentale', 15, 'Master en psychologie du sport', 180.00),
(9, 'Récupération', 12, 'Kinésithérapeute du sport', 160.00);

-- Insertion des profils coachs de basket
INSERT INTO coach_basket_profiles (user_id, level, experience_years, teams_coached, achievements) VALUES
(10, 'Pro A', 15, 'ASVEL, Limoges', 'Champion de France 2022'),
(11, 'Pro B', 12, 'Rouen, Chalon', 'Finaliste Leaders Cup 2023'),
(12, 'NM1', 10, 'Boulogne, Dijon', 'Champion NM1 2021');

-- Insertion des profils juristes
INSERT INTO juriste_profiles (user_id, speciality, bar_number, experience_years, hourly_rate) VALUES
(13, 'Droit du sport', 'BAR123456', 8, 150.00),
(14, 'Droit des contrats', 'BAR234567', 10, 180.00),
(15, 'Droit du travail', 'BAR345678', 7, 140.00);

-- Insertion des profils diététiciennes
INSERT INTO dieteticienne_profiles (user_id, speciality, certifications, experience_years, hourly_rate) VALUES
(16, 'Nutrition sportive', 'Diplôme en nutrition sportive', 5, 120.00),
(17, 'Récupération', 'Master en nutrition sportive', 4, 130.00),
(18, 'Perte de poids', 'Diplôme en diététique sportive', 6, 125.00);

-- Insertion des profils clubs
INSERT INTO club_profiles (user_id, club_name, level, location, description) VALUES
(19, 'ASVEL Villeurbanne', 'Pro A', 'Villeurbanne', 'Club historique du basket français'),
(20, 'Stade Rennais Basket', 'Pro B', 'Rennes', 'Club en développement'),
(21, 'Paris Basketball', 'Pro A', 'Paris', 'Club ambitieux de la capitale'); 