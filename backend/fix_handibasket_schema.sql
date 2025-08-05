-- Fix pour la table handibasket_profiles
-- Ajouter des valeurs par défaut pour éviter l'erreur "Field doesn't have a default value"

ALTER TABLE handibasket_profiles 
MODIFY COLUMN birth_date DATE DEFAULT '1990-01-01';

ALTER TABLE handibasket_profiles 
MODIFY COLUMN handicap_type VARCHAR(50) DEFAULT 'moteur';

ALTER TABLE handibasket_profiles 
MODIFY COLUMN cat VARCHAR(20) DEFAULT 'Sport';

ALTER TABLE handibasket_profiles 
MODIFY COLUMN residence VARCHAR(100) DEFAULT 'Non spécifié';

ALTER TABLE handibasket_profiles 
MODIFY COLUMN profession VARCHAR(100) DEFAULT 'Non spécifié';

-- Vérifier la structure
DESCRIBE handibasket_profiles;