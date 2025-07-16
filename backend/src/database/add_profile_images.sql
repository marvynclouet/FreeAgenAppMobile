-- Script pour ajouter le support des photos de profil
-- Exécuter ce script dans votre base de données MySQL

USE freeagent_db;

-- Ajouter les colonnes pour les photos de profil dans la table users
ALTER TABLE users ADD COLUMN profile_image_url VARCHAR(500) DEFAULT NULL;
ALTER TABLE users ADD COLUMN profile_image_uploaded_at TIMESTAMP DEFAULT NULL;

-- Ajouter les colonnes pour les photos de profil dans les tables de profils
ALTER TABLE player_profiles ADD COLUMN profile_image_url VARCHAR(500) DEFAULT NULL;
ALTER TABLE coach_pro_profiles ADD COLUMN profile_image_url VARCHAR(500) DEFAULT NULL;
ALTER TABLE coach_basket_profiles ADD COLUMN profile_image_url VARCHAR(500) DEFAULT NULL;
ALTER TABLE juriste_profiles ADD COLUMN profile_image_url VARCHAR(500) DEFAULT NULL;
ALTER TABLE dieteticienne_profiles ADD COLUMN profile_image_url VARCHAR(500) DEFAULT NULL;
ALTER TABLE club_profiles ADD COLUMN profile_image_url VARCHAR(500) DEFAULT NULL;
ALTER TABLE handibasket_profiles ADD COLUMN profile_image_url VARCHAR(500) DEFAULT NULL;

-- Créer des index pour optimiser les recherches
CREATE INDEX IF NOT EXISTS idx_users_profile_image ON users(profile_image_url);

-- Afficher un message de confirmation
SELECT 'Base de données mise à jour avec succès pour le support des photos de profil!' as Status; 