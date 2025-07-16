-- Mise à jour de la table club_profiles pour ajouter les colonnes manquantes
USE freeagent_db;

-- Ajouter les colonnes manquantes à la table club_profiles
ALTER TABLE club_profiles 
ADD COLUMN IF NOT EXISTS address VARCHAR(255),
ADD COLUMN IF NOT EXISTS city VARCHAR(255),
ADD COLUMN IF NOT EXISTS phone VARCHAR(20),
ADD COLUMN IF NOT EXISTS website VARCHAR(255),
ADD COLUMN IF NOT EXISTS social_media TEXT;

-- Renommer location en address si elle n'existe pas déjà
-- ALTER TABLE club_profiles CHANGE COLUMN location address VARCHAR(255);

-- Vérifier la structure mise à jour
DESCRIBE club_profiles; 