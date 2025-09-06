USE freeagent_db;

-- Supprimer les utilisateurs handibasket s'ils existent déjà
DELETE FROM handibasket_profiles WHERE user_id IN (
    SELECT id FROM users WHERE email IN (
        'handibasket1@freeagent.com',
        'handibasket2@freeagent.com',
        'handibasket3@freeagent.com',
        'handibasket4@freeagent.com',
        'handibasket5@freeagent.com'
    )
);

DELETE FROM users WHERE email IN (
    'handibasket1@freeagent.com',
    'handibasket2@freeagent.com',
    'handibasket3@freeagent.com',
    'handibasket4@freeagent.com',
    'handibasket5@freeagent.com'
);

-- Insérer les utilisateurs handibasket
INSERT INTO users (name, email, password, profile_type, gender, nationality) VALUES 
('Marie Dubois', 'handibasket1@freeagent.com', '$2b$10$kUnMlnw1mXnpVP8Zet7OU.xoTnP0rFscMPD2mFxSjVwsHGKBoBkl6', 'handibasket', 'F', 'Française'),
('Thomas Martin', 'handibasket2@freeagent.com', '$2b$10$kUnMlnw1mXnpVP8Zet7OU.xoTnP0rFscMPD2mFxSjVwsHGKBoBkl6', 'handibasket', 'M', 'Français'),
('Sophie Leroy', 'handibasket3@freeagent.com', '$2b$10$kUnMlnw1mXnpVP8Zet7OU.xoTnP0rFscMPD2mFxSjVwsHGKBoBkl6', 'handibasket', 'F', 'Française'),
('Alexandre Petit', 'handibasket4@freeagent.com', '$2b$10$kUnMlnw1mXnpVP8Zet7OU.xoTnP0rFscMPD2mFxSjVwsHGKBoBkl6', 'handibasket', 'M', 'Français'),
('Camille Moreau', 'handibasket5@freeagent.com', '$2b$10$kUnMlnw1mXnpVP8Zet7OU.xoTnP0rFscMPD2mFxSjVwsHGKBoBkl6', 'handibasket', 'F', 'Française');

-- Récupérer les IDs des utilisateurs créés
SET @user1_id = (SELECT id FROM users WHERE email = 'handibasket1@freeagent.com');
SET @user2_id = (SELECT id FROM users WHERE email = 'handibasket2@freeagent.com');
SET @user3_id = (SELECT id FROM users WHERE email = 'handibasket3@freeagent.com');
SET @user4_id = (SELECT id FROM users WHERE email = 'handibasket4@freeagent.com');
SET @user5_id = (SELECT id FROM users WHERE email = 'handibasket5@freeagent.com');

-- Insérer les profils handibasket détaillés
INSERT INTO handibasket_profiles (
    user_id, birth_date, handicap_type, cat, residence, profession, 
    position, championship_level, height, weight, passport_type, 
    experience_years, level, classification, stats, achievements, 
    video_url, bio, club, coach
) VALUES 
-- Marie Dubois - Pivot expérimentée
(@user1_id, '1995-03-15', 'Moteur', 'I', 'Paris', 'Éducatrice spécialisée', 
 'Pivot', 'Nationale 1', 175, 68, 'Français', 
 8, 'Élite', 'I', 
 '{"points": 12.5, "rebounds": 8.2, "assists": 2.1, "steals": 1.8, "blocks": 1.2}',
 'Championne de France 2023, Vice-championne d\'Europe 2022, 3 sélections en équipe de France',
 'https://youtube.com/watch?v=marie_handibasket',
 'Passionnée de handibasket depuis l\'âge de 12 ans, je recherche une équipe compétitive pour continuer à progresser. Mon handicap moteur ne m\'empêche pas de donner le meilleur de moi-même sur le terrain.',
 'Paris Handibasket Club', 'Jean-Pierre Durand'),

-- Thomas Martin - Meneur technique
(@user2_id, '1992-07-22', 'Moteur', 'II', 'Lyon', 'Ingénieur informatique', 
 'Meneur', 'Nationale 2', 168, 65, 'Français', 
 10, 'Élite', 'II', 
 '{"points": 8.3, "rebounds": 3.1, "assists": 6.8, "steals": 2.5, "blocks": 0.3}',
 'Meilleur passeur du championnat 2023, Finaliste coupe de France 2022',
 'https://youtube.com/watch?v=thomas_handibasket',
 'Meneur de jeu expérimenté, je privilégie le collectif et la tactique. Je recherche une équipe qui partage mes valeurs de fair-play et d\'excellence.',
 'Lyon Handibasket', 'Marie-Claire Bernard'),

-- Sophie Leroy - Ailière polyvalente
(@user3_id, '1998-11-08', 'Moteur', 'I', 'Marseille', 'Kinésithérapeute', 
 'Ailière', 'Nationale 1', 165, 58, 'Français', 
 5, 'Élite', 'I', 
 '{"points": 15.2, "rebounds": 4.8, "assists": 3.2, "steals": 2.1, "blocks": 0.8}',
 'Révélation de l\'année 2023, Championne de France 2023',
 'https://youtube.com/watch?v=sophie_handibasket',
 'Jeune joueuse dynamique et déterminée. Mon handicap moteur m\'a appris la persévérance. Je cherche une équipe ambitieuse pour continuer ma progression.',
 'Marseille Handibasket', 'Pierre Lefebvre'),

-- Alexandre Petit - Intérieur défensif
(@user4_id, '1990-12-03', 'Moteur', 'II', 'Toulouse', 'Professeur d\'EPS', 
 'Intérieur', 'Nationale 2', 180, 75, 'Français', 
 12, 'Élite', 'II', 
 '{"points": 6.8, "rebounds": 9.5, "assists": 1.8, "steals": 1.2, "blocks": 2.3}',
 'Meilleur défenseur 2022, Champion de France 2021, 5 sélections en équipe de France',
 'https://youtube.com/watch?v=alexandre_handibasket',
 'Spécialiste de la défense et du rebond. Mon expérience et ma détermination font de moi un pilier défensif. Je recherche une équipe qui valorise le travail défensif.',
 'Toulouse Handibasket', 'Claire Martin'),

-- Camille Moreau - Ailière forte
(@user5_id, '1996-05-18', 'Moteur', 'I', 'Nantes', 'Architecte', 
 'Ailière forte', 'Nationale 1', 170, 62, 'Français', 
 7, 'Élite', 'I', 
 '{"points": 11.4, "rebounds": 6.2, "assists": 2.8, "steals": 1.9, "blocks": 1.1}',
 'Vice-championne d\'Europe 2023, 2 sélections en équipe de France',
 'https://youtube.com/watch?v=camille_handibasket',
 'Joueuse complète alliant technique et physique. Mon handicap moteur m\'a rendue plus forte mentalement. Je cherche une équipe de haut niveau pour relever de nouveaux défis.',
 'Nantes Handibasket', 'Michel Rousseau');

-- Mettre à jour les limites d'utilisation pour ces utilisateurs
INSERT INTO user_limits (user_id, messages_sent, opportunities_posted, applications_submitted, last_reset_date) VALUES
(@user1_id, 0, 0, 0, CURDATE()),
(@user2_id, 0, 0, 0, CURDATE()),
(@user3_id, 0, 0, 0, CURDATE()),
(@user4_id, 0, 0, 0, CURDATE()),
(@user5_id, 0, 0, 0, CURDATE());

-- Afficher les profils créés
SELECT 
    u.name,
    u.email,
    u.gender,
    u.nationality,
    hp.position,
    hp.championship_level,
    hp.classification,
    hp.handicap_type,
    hp.experience_years,
    hp.club,
    hp.coach
FROM users u
JOIN handibasket_profiles hp ON u.id = hp.user_id
WHERE u.profile_type = 'handibasket'
ORDER BY u.name;
