-- Créer un utilisateur administrateur pour l'application d'administration
-- Email: admin@freeagentapp.com
-- Mot de passe: Admin123!

INSERT INTO `users` (`name`, `email`, `password`, `profile_type`, `created_at`, `updated_at`) 
VALUES (
    'Administrateur FreeAgent',
    'admin@freeagentapp.com',
    '$2b$10$YSHSQFYG3BDUGyWRVDWV0u.klCVgVB/UXRu6d8tY2BnUtT/LK95Fi', -- Admin123!
    'player', -- Type par défaut, on ajoutera un champ admin
    NOW(),
    NOW()
);

-- Ajouter une colonne admin à la table users si elle n'existe pas
ALTER TABLE `users` ADD COLUMN `is_admin` BOOLEAN DEFAULT FALSE;

-- Marquer l'utilisateur admin comme administrateur
UPDATE `users` SET `is_admin` = TRUE WHERE `email` = 'admin@freeagentapp.com'; 