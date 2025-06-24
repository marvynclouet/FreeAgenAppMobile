USE freeagent_db;

-- Supprimer l'utilisateur s'il existe déjà
DELETE FROM users WHERE email = 'user123@freeagent.com';

-- Insérer l'utilisateur de test
INSERT INTO users (name, email, password, profile_type) 
VALUES (
    'User123',
    'user123@freeagent.com',
    '$2b$10$kUnMlnw1mXnpVP8Zet7OU.xoTnP0rFscMPD2mFxSjVwsHGKBoBkl6',
    'player'
); 