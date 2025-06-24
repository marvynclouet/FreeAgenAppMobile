-- Script pour mettre à jour la base de données avec les colonnes manquantes
-- Exécuter ce script sur votre base de données freeagent_db

USE freeagent_db;

-- Ajouter les colonnes services et availability à dieteticienne_profiles
ALTER TABLE dieteticienne_profiles 
ADD COLUMN services TEXT,
ADD COLUMN availability TEXT;

-- Ajouter les colonnes services et availability à juriste_profiles  
ALTER TABLE juriste_profiles
ADD COLUMN services TEXT,
ADD COLUMN availability TEXT;

-- Ajouter les colonnes services et availability à coach_pro_profiles
ALTER TABLE coach_pro_profiles
ADD COLUMN services TEXT,
ADD COLUMN availability TEXT;

-- Vérifier que les colonnes ont été ajoutées
DESCRIBE dieteticienne_profiles;
DESCRIBE juriste_profiles;
DESCRIBE coach_pro_profiles;

-- Optionnel : Mettre à jour les données existantes avec des valeurs par défaut
UPDATE dieteticienne_profiles SET 
    services = 'Services à définir',
    availability = 'Disponibilités à définir'
WHERE services IS NULL OR availability IS NULL;

UPDATE juriste_profiles SET 
    services = 'Services à définir', 
    availability = 'Disponibilités à définir'
WHERE services IS NULL OR availability IS NULL;

UPDATE coach_pro_profiles SET
    services = 'Services à définir',
    availability = 'Disponibilités à définir'  
WHERE services IS NULL OR availability IS NULL; 