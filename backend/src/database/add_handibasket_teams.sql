-- Script pour ajouter le support des équipes handibasket

-- 1. Modifier l'énumération profile_type pour inclure handibasket_team
ALTER TABLE users MODIFY COLUMN profile_type ENUM('player', 'handibasket', 'coach_pro', 'coach_basket', 'juriste', 'dieteticienne', 'club', 'handibasket_team') NOT NULL;

-- 2. Créer la table des profils d'équipes handibasket
CREATE TABLE IF NOT EXISTS handibasket_team_profiles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    team_name VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    region VARCHAR(100),
    level ENUM('Regional', 'Nationale 3', 'Nationale 2', 'Nationale 1', 'Elite') NOT NULL,
    division VARCHAR(50),
    founded_year INT,
    description TEXT,
    achievements TEXT,
    contact_person VARCHAR(255),
    phone VARCHAR(20),
    email_contact VARCHAR(255),
    website VARCHAR(255),
    social_media JSON,
    facilities TEXT,
    training_schedule TEXT,
    competition_schedule TEXT,
    recruitment_needs TEXT,
    budget_range VARCHAR(100),
    accommodation_offered BOOLEAN DEFAULT FALSE,
    transport_offered BOOLEAN DEFAULT FALSE,
    medical_support BOOLEAN DEFAULT FALSE,
    coaching_staff JSON,
    player_requirements TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. Créer les index pour optimiser les recherches
CREATE INDEX idx_handibasket_team_city ON handibasket_team_profiles(city);
CREATE INDEX idx_handibasket_team_level ON handibasket_team_profiles(level);
CREATE INDEX idx_handibasket_team_region ON handibasket_team_profiles(region);

-- 4. Ajouter des colonnes pour les opportunités handibasket
ALTER TABLE opportunities ADD COLUMN handibasket_specific BOOLEAN DEFAULT FALSE;
ALTER TABLE opportunities ADD COLUMN handicap_types JSON;
ALTER TABLE opportunities ADD COLUMN classification_required VARCHAR(50);
ALTER TABLE opportunities ADD COLUMN experience_required INT;
ALTER TABLE opportunities ADD COLUMN position_required VARCHAR(100);
ALTER TABLE opportunities ADD COLUMN level_required VARCHAR(100);

-- 5. Créer des équipes handibasket de test
INSERT INTO users (name, email, password, profile_type, gender, nationality) VALUES 
('Paris Handibasket Club', 'contact@paris-handibasket.fr', '$2b$10$kUnMlnw1mXnpVP8Zet7OU.xoTnP0rFscMPD2mFxSjVwsHGKBoBkl6', 'handibasket_team', 'M', 'Française'),
('Lyon Handibasket Association', 'info@lyon-handibasket.fr', '$2b$10$kUnMlnw1mXnpVP8Zet7OU.xoTnP0rFscMPD2mFxSjVwsHGKBoBkl6', 'handibasket_team', 'M', 'Française'),
('Marseille Handibasket Club', 'contact@marseille-handibasket.fr', '$2b$10$kUnMlnw1mXnpVP8Zet7OU.xoTnP0rFscMPD2mFxSjVwsHGKBoBkl6', 'handibasket_team', 'M', 'Française'),
('Toulouse Handibasket', 'info@toulouse-handibasket.fr', '$2b$10$kUnMlnw1mXnpVP8Zet7OU.xoTnP0rFscMPD2mFxSjVwsHGKBoBkl6', 'handibasket_team', 'M', 'Française'),
('Nantes Handibasket Club', 'contact@nantes-handibasket.fr', '$2b$10$kUnMlnw1mXnpVP8Zet7OU.xoTnP0rFscMPD2mFxSjVwsHGKBoBkl6', 'handibasket_team', 'M', 'Française');

-- 6. Récupérer les IDs des équipes créées
SET @paris_id = (SELECT id FROM users WHERE email = 'contact@paris-handibasket.fr');
SET @lyon_id = (SELECT id FROM users WHERE email = 'info@lyon-handibasket.fr');
SET @marseille_id = (SELECT id FROM users WHERE email = 'contact@marseille-handibasket.fr');
SET @toulouse_id = (SELECT id FROM users WHERE email = 'info@toulouse-handibasket.fr');
SET @nantes_id = (SELECT id FROM users WHERE email = 'contact@nantes-handibasket.fr');

-- 7. Créer les profils détaillés des équipes
INSERT INTO handibasket_team_profiles (
    user_id, team_name, city, region, level, division, founded_year, description,
    achievements, contact_person, phone, email_contact, website, facilities,
    training_schedule, recruitment_needs, budget_range, accommodation_offered,
    transport_offered, medical_support, player_requirements
) VALUES 
(@paris_id, 'Paris Handibasket Club', 'Paris', 'Île-de-France', 'Elite', 'Championnat de France', 1995,
 'Club de handibasket de haut niveau basé à Paris, évoluant en Elite. Nous recherchons des joueurs talentueux pour renforcer notre effectif.',
 'Champions de France 2023, Vice-champions d\'Europe 2022, 3 titres de champion de France',
 'Jean-Pierre Durand', '01 23 45 67 89', 'contact@paris-handibasket.fr', 'https://paris-handibasket.fr',
 'Gymnase moderne avec équipements adaptés, salle de musculation, vestiaires accessibles',
 'Mardi et Jeudi 19h-21h, Samedi 14h-16h',
 'Recherche 2 pivots et 1 meneur de jeu pour la saison 2024-2025',
 '2000-5000€/mois', TRUE, TRUE, TRUE,
 'Classification I-II, expérience minimum 3 ans, niveau Elite ou Nationale 1'),

(@lyon_id, 'Lyon Handibasket Association', 'Lyon', 'Auvergne-Rhône-Alpes', 'Nationale 1', 'Championnat de France', 1988,
 'Association handibasket dynamique de Lyon, évoluant en Nationale 1. Nous développons le handibasket dans la région.',
 'Champions de France Nationale 2 en 2022, Finalistes coupe de France 2023',
 'Marie-Claire Bernard', '04 78 12 34 56', 'info@lyon-handibasket.fr', 'https://lyon-handibasket.fr',
 'Complexe sportif avec 2 terrains, salle de réunion, espace détente',
 'Lundi et Mercredi 18h30-20h30, Dimanche 10h-12h',
 'Recherche 1 ailier et 1 arrière pour compléter l\'effectif',
 '1500-3000€/mois', FALSE, TRUE, TRUE,
 'Classification II-III, expérience minimum 2 ans, niveau Nationale 1 ou 2'),

(@marseille_id, 'Marseille Handibasket Club', 'Marseille', 'Provence-Alpes-Côte d\'Azur', 'Nationale 2', 'Championnat de France', 1992,
 'Club handibasket de Marseille, évoluant en Nationale 2. Nous accueillons des joueurs de tous niveaux.',
 'Champions de France Nationale 3 en 2021, Montée en Nationale 2 en 2022',
 'Pierre Lefebvre', '04 91 23 45 67', 'contact@marseille-handibasket.fr', 'https://marseille-handibasket.fr',
 'Gymnase municipal adapté, parking gratuit, accès transport en commun',
 'Mardi et Jeudi 19h-21h, Samedi 15h-17h',
 'Recherche 1 pivot et 1 meneur pour la saison prochaine',
 '1000-2500€/mois', FALSE, FALSE, FALSE,
 'Classification I-IV, expérience minimum 1 an, niveau Nationale 2 ou 3'),

(@toulouse_id, 'Toulouse Handibasket', 'Toulouse', 'Occitanie', 'Nationale 1', 'Championnat de France', 1990,
 'Club handibasket de Toulouse, évoluant en Nationale 1. Nous formons de jeunes talents et recrutons des joueurs expérimentés.',
 'Champions de France Nationale 2 en 2020, 3 montées consécutives',
 'Claire Martin', '05 61 23 45 67', 'info@toulouse-handibasket.fr', 'https://toulouse-handibasket.fr',
 'Complexe sportif moderne, salle de musculation, espace détente, restaurant',
 'Lundi et Mercredi 18h-20h, Samedi 14h-16h',
 'Recherche 2 ailiers et 1 arrière pour renforcer l\'effectif',
 '1800-4000€/mois', TRUE, TRUE, TRUE,
 'Classification I-III, expérience minimum 2 ans, niveau Nationale 1'),

(@nantes_id, 'Nantes Handibasket Club', 'Nantes', 'Pays de la Loire', 'Nationale 2', 'Championnat de France', 1993,
 'Club handibasket de Nantes, évoluant en Nationale 2. Nous développons le handibasket dans l\'Ouest de la France.',
 'Champions de France Nationale 3 en 2023, Montée en Nationale 2',
 'Michel Rousseau', '02 40 12 34 56', 'contact@nantes-handibasket.fr', 'https://nantes-handibasket.fr',
 'Gymnase universitaire, salle de musculation, espace détente',
 'Mardi et Jeudi 19h-21h, Dimanche 10h-12h',
 'Recherche 1 pivot et 1 ailier pour la saison 2024-2025',
 '1200-2800€/mois', FALSE, TRUE, FALSE,
 'Classification II-IV, expérience minimum 1 an, niveau Nationale 2 ou 3');

-- 8. Créer des opportunités handibasket de test
INSERT INTO opportunities (
    team_id, title, description, type, requirements, salary_range, location, status,
    handibasket_specific, handicap_types, classification_required, experience_required,
    position_required, level_required
) VALUES 
(@paris_id, 'Recherche Pivot Elite Handibasket', 
 'Le Paris Handibasket Club recherche un pivot de haut niveau pour évoluer en Elite. Poste à pourvoir immédiatement.',
 'recrutement',
 'Classification I-II, expérience minimum 5 ans en Elite ou Nationale 1, excellent niveau technique et physique',
 '3000-5000€/mois',
 'Paris, France',
 'open',
 TRUE,
 '["Moteur", "Amputé membre inférieur"]',
 'I-II',
 5,
 'Pivot',
 'Elite'),

(@lyon_id, 'Recherche Meneur de Jeu Handibasket',
 'Lyon Handibasket Association recherche un meneur de jeu expérimenté pour évoluer en Nationale 1.',
 'recrutement',
 'Classification II-III, expérience minimum 3 ans, excellent leadership et vision de jeu',
 '2000-3500€/mois',
 'Lyon, France',
 'open',
 TRUE,
 '["Moteur", "Amputé membre inférieur", "Spina bifida"]',
 'II-III',
 3,
 'Meneur',
 'Nationale 1'),

(@marseille_id, 'Recherche Ailier Handibasket',
 'Marseille Handibasket Club recherche un ailier polyvalent pour compléter son effectif.',
 'recrutement',
 'Classification I-IV, expérience minimum 2 ans, polyvalence appréciée',
 '1500-2500€/mois',
 'Marseille, France',
 'open',
 TRUE,
 '["Moteur", "Amputé membre inférieur", "Spina bifida", "Paraplégie"]',
 'I-IV',
 2,
 'Ailier',
 'Nationale 2'),

(@toulouse_id, 'Recherche Arrière Handibasket',
 'Toulouse Handibasket recherche un arrière talentueux pour évoluer en Nationale 1.',
 'recrutement',
 'Classification I-III, expérience minimum 3 ans, excellent shoot et défense',
 '2200-4000€/mois',
 'Toulouse, France',
 'open',
 TRUE,
 '["Moteur", "Amputé membre inférieur", "Spina bifida"]',
 'I-III',
 3,
 'Arrière',
 'Nationale 1'),

(@nantes_id, 'Recherche Pivot Handibasket',
 'Nantes Handibasket Club recherche un pivot pour renforcer son effectif en Nationale 2.',
 'recrutement',
 'Classification II-IV, expérience minimum 2 ans, bon niveau technique',
 '1800-3000€/mois',
 'Nantes, France',
 'open',
 TRUE,
 '["Moteur", "Amputé membre inférieur", "Spina bifida"]',
 'II-IV',
 2,
 'Pivot',
 'Nationale 2');

-- 9. Afficher les équipes créées
SELECT 
    u.name as team_name,
    u.email,
    htp.city,
    htp.level,
    htp.contact_person,
    htp.phone
FROM users u
JOIN handibasket_team_profiles htp ON u.id = htp.user_id
WHERE u.profile_type = 'handibasket_team'
ORDER BY htp.level DESC, u.name;

-- 10. Afficher les opportunités créées
SELECT 
    o.title,
    u.name as team_name,
    o.location,
    o.salary_range,
    o.classification_required,
    o.position_required,
    o.level_required
FROM opportunities o
JOIN users u ON o.team_id = u.id
WHERE o.handibasket_specific = TRUE
ORDER BY o.created_at DESC;
