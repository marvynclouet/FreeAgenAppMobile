-- Script pour corriger les problèmes de l'utilisateur Carole
-- Exécuter ce script sur votre base de données freeagent_db

USE freeagent_db;

-- 1. Vérifier si l'utilisateur Carole (ID 29) existe
SELECT * FROM users WHERE id = 29;

-- 2. Si l'utilisateur n'existe pas, l'ajouter avec le bon profile_type
INSERT IGNORE INTO users (id, name, email, password, profile_type, created_at, updated_at) 
VALUES (29, 'Carole', 'carole@example.com', '$2b$10$example_hash', 'dieteticienne', NOW(), NOW());

-- 3. Si l'utilisateur existe mais avec le mauvais profile_type, le corriger
UPDATE users 
SET profile_type = 'dieteticienne', updated_at = NOW() 
WHERE id = 29 AND profile_type != 'dieteticienne';

-- 4. Créer le profil diététicienne correspondant si il n'existe pas
INSERT IGNORE INTO dieteticienne_profiles (user_id, speciality, certifications, experience_years, hourly_rate, services, availability) 
VALUES (29, 'Nutrition sportive', 'Diplôme de diététicienne', 5, 120.00, 'Services de nutrition', 'Lundi-Vendredi 9h-17h');

-- 5. Vérifier les résultats
SELECT 'Utilisateur Carole:' as Info;
SELECT id, name, email, profile_type FROM users WHERE id = 29;

SELECT 'Profil diététicienne de Carole:' as Info;
SELECT * FROM dieteticienne_profiles WHERE user_id = 29;

-- 6. Optionnel: Rechercher d'autres utilisateurs avec des profile_type potentiellement incorrects
SELECT 'Tous les utilisateurs diététiciennes:' as Info;
SELECT id, name, email, profile_type FROM users WHERE profile_type = 'dieteticienne';

-- 7. Vérifier l'intégrité des données
SELECT 'Vérification intégrité - utilisateurs sans profil correspondant:' as Info;
SELECT u.id, u.name, u.profile_type 
FROM users u 
LEFT JOIN dieteticienne_profiles dp ON u.id = dp.user_id 
WHERE u.profile_type = 'dieteticienne' AND dp.user_id IS NULL; 