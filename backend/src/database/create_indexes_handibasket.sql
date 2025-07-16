-- Script pour créer les index pour handibasket_profiles
-- Compatible avec toutes les versions de MySQL

USE freeagent_db;

-- Méthode sûre : supprimer l'index s'il existe, puis le créer
-- Cela évite les erreurs si l'index existe déjà

-- Index pour la classification CAT
DROP INDEX IF EXISTS idx_handibasket_cat ON handibasket_profiles;
CREATE INDEX idx_handibasket_cat ON handibasket_profiles(cat);

-- Index pour la résidence
DROP INDEX IF EXISTS idx_handibasket_residence ON handibasket_profiles;
CREATE INDEX idx_handibasket_residence ON handibasket_profiles(residence);

-- Index pour le club
DROP INDEX IF EXISTS idx_handibasket_club ON handibasket_profiles;
CREATE INDEX idx_handibasket_club ON handibasket_profiles(club);

-- Vérifier que les index ont été créés
SHOW INDEX FROM handibasket_profiles;

SELECT 'Index créés avec succès!' as Status; 