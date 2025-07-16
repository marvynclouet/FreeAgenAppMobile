-- Script pour ajouter le support des profils handibasket
USE freeagent_db;

-- Modifier l'énumération profile_type pour inclure handibasket
ALTER TABLE users MODIFY COLUMN profile_type ENUM('player', 'handibasket', 'coach_pro', 'coach_basket', 'juriste', 'dieteticienne', 'club') NOT NULL;

-- Créer la table des profils handibasket
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

-- Créer un index pour optimiser les recherches
CREATE INDEX idx_handibasket_cat ON handibasket_profiles(cat);
CREATE INDEX idx_handibasket_residence ON handibasket_profiles(residence);
CREATE INDEX idx_handibasket_club ON handibasket_profiles(club); 