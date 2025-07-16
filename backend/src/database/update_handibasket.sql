-- Script pour ajouter le support des profils handibasket
-- Exécuter ce script dans votre base de données MySQL

USE freeagent_db;

-- 1. Modifier l'énumération profile_type pour inclure handibasket
-- Méthode sûre : ajouter handibasket à la liste existante
ALTER TABLE users MODIFY COLUMN profile_type ENUM('player', 'coach_pro', 'coach_basket', 'juriste', 'dieteticienne', 'club', 'handibasket') NOT NULL;

-- 2. Créer la table des profils handibasket
CREATE TABLE IF NOT EXISTS handibasket_profiles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    birth_date DATE NOT NULL,
    handicap_type VARCHAR(255) NOT NULL,
    cat VARCHAR(10) NOT NULL COMMENT 'Classification athletique (ex: 1.0, 2.0, 3.0, 4.0, 4.5)',
    residence VARCHAR(255) NOT NULL,
    club VARCHAR(255) DEFAULT NULL,
    coach VARCHAR(255) DEFAULT NULL,
    profession VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. Créer des index pour optimiser les recherches
CREATE INDEX IF NOT EXISTS idx_handibasket_cat ON handibasket_profiles(cat);
CREATE INDEX IF NOT EXISTS idx_handibasket_residence ON handibasket_profiles(residence);
CREATE INDEX IF NOT EXISTS idx_handibasket_club ON handibasket_profiles(club);

-- 4. Vérifier que la modification a fonctionné
SELECT COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'freeagent_db' 
AND TABLE_NAME = 'users' 
AND COLUMN_NAME = 'profile_type';

-- 5. Insérer quelques données de test (optionnel)
-- Décommentez les lignes suivantes si vous voulez des données de test

/*
-- Utilisateur de test handibasket
INSERT INTO users (name, email, password, profile_type) VALUES 
('Alexandre Jollien', 'alexandre.jollien@handibasket.fr', '$2b$10$example_hash_for_test123', 'handibasket');

-- Récupérer l'ID de l'utilisateur inséré
SET @user_id = LAST_INSERT_ID();

-- Profil handibasket associé
INSERT INTO handibasket_profiles (user_id, birth_date, handicap_type, cat, residence, club, coach, profession) VALUES 
(@user_id, '1975-11-10', 'Paraplégie', '1.0', 'Sion, Suisse', 'Club Handibasket Valais', 'Michel Dubois', 'Écrivain et philosophe');

-- Autre utilisateur de test
INSERT INTO users (name, email, password, profile_type) VALUES 
('Marie Amelie Le Fur', 'marie.lefur@handibasket.fr', '$2b$10$example_hash_for_test456', 'handibasket');

SET @user_id2 = LAST_INSERT_ID();

INSERT INTO handibasket_profiles (user_id, birth_date, handicap_type, cat, residence, club, coach, profession) VALUES 
(@user_id2, '1988-01-26', 'Amputation membre inférieur', '4.5', 'Paris, France', 'Paris Handibasket', 'Jean-Pierre Martin', 'Athlète paralympique');
*/

-- Afficher un message de confirmation
SELECT 'Base de données mise à jour avec succès pour le support handibasket!' as Status; 

ALTER TABLE posts ADD COLUMN event_time TIME NULL; 