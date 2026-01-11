-- Script de nettoyage des données de test et célébrités
-- À exécuter directement sur la base de données Railway

USE railway;

-- 1. Identifier les utilisateurs de test et célébrités
SELECT 'Utilisateurs de test et célébrités à supprimer:' as info;
SELECT id, name, email, profile_type 
FROM users 
WHERE 
  email LIKE '%@example.com' OR
  name IN ('Victor Wembanyama', 'Evan Fournier', 'Nando De Colo', 'Rudy Gobert', 'Nicolas Batum', 'Tony Parker', 'Boris Diaw', 'Florent Pietrus', 'Mickaël Gelabale', 'Johan Petro', 'Ronny Turiaf', 'Tariq Abdul-Wahad', 'Frédéric Weis', 'Yannick Noah', 'Joakim Noah', 'Kevin Seraphin', 'Ian Mahinmi') OR
  name LIKE '%test%' OR
  name LIKE '%Test%' OR
  email LIKE '%test%' OR
  email LIKE '%Test%';

-- 2. Supprimer les données liées (en cascade)
-- Supprimer les profils de joueurs
DELETE FROM player_profiles 
WHERE user_id IN (
  SELECT id FROM users 
  WHERE 
    email LIKE '%@example.com' OR
    name IN ('Victor Wembanyama', 'Evan Fournier', 'Nando De Colo', 'Rudy Gobert', 'Nicolas Batum', 'Tony Parker', 'Boris Diaw', 'Florent Pietrus', 'Mickaël Gelabale', 'Johan Petro', 'Ronny Turiaf', 'Tariq Abdul-Wahad', 'Frédéric Weis', 'Yannick Noah', 'Joakim Noah', 'Kevin Seraphin', 'Ian Mahinmi') OR
    name LIKE '%test%' OR
    name LIKE '%Test%' OR
    email LIKE '%test%' OR
    email LIKE '%Test%'
);

-- Supprimer les profils handibasket
DELETE FROM handibasket_profiles 
WHERE user_id IN (
  SELECT id FROM users 
  WHERE 
    email LIKE '%@example.com' OR
    name IN ('Victor Wembanyama', 'Evan Fournier', 'Nando De Colo', 'Rudy Gobert', 'Nicolas Batum', 'Tony Parker', 'Boris Diaw', 'Florent Pietrus', 'Mickaël Gelabale', 'Johan Petro', 'Ronny Turiaf', 'Tariq Abdul-Wahad', 'Frédéric Weis', 'Yannick Noah', 'Joakim Noah', 'Kevin Seraphin', 'Ian Mahinmi') OR
    name LIKE '%test%' OR
    name LIKE '%Test%' OR
    email LIKE '%test%' OR
    email LIKE '%Test%'
);

-- Supprimer les profils d'entraîneurs
DELETE FROM coach_profiles 
WHERE user_id IN (
  SELECT id FROM users 
  WHERE 
    email LIKE '%@example.com' OR
    name IN ('Victor Wembanyama', 'Evan Fournier', 'Nando De Colo', 'Rudy Gobert', 'Nicolas Batum', 'Tony Parker', 'Boris Diaw', 'Florent Pietrus', 'Mickaël Gelabale', 'Johan Petro', 'Ronny Turiaf', 'Tariq Abdul-Wahad', 'Frédéric Weis', 'Yannick Noah', 'Joakim Noah', 'Kevin Seraphin', 'Ian Mahinmi') OR
    name LIKE '%test%' OR
    name LIKE '%Test%' OR
    email LIKE '%test%' OR
    email LIKE '%Test%'
);

-- Supprimer les profils de clubs
DELETE FROM club_profiles 
WHERE user_id IN (
  SELECT id FROM users 
  WHERE 
    email LIKE '%@example.com' OR
    name IN ('Victor Wembanyama', 'Evan Fournier', 'Nando De Colo', 'Rudy Gobert', 'Nicolas Batum', 'Tony Parker', 'Boris Diaw', 'Florent Pietrus', 'Mickaël Gelabale', 'Johan Petro', 'Ronny Turiaf', 'Tariq Abdul-Wahad', 'Frédéric Weis', 'Yannick Noah', 'Joakim Noah', 'Kevin Seraphin', 'Ian Mahinmi') OR
    name LIKE '%test%' OR
    name LIKE '%Test%' OR
    email LIKE '%test%' OR
    email LIKE '%Test%'
);

-- Supprimer les profils de diététiciens
DELETE FROM dietitian_profiles 
WHERE user_id IN (
  SELECT id FROM users 
  WHERE 
    email LIKE '%@example.com' OR
    name IN ('Victor Wembanyama', 'Evan Fournier', 'Nando De Colo', 'Rudy Gobert', 'Nicolas Batum', 'Tony Parker', 'Boris Diaw', 'Florent Pietrus', 'Mickaël Gelabale', 'Johan Petro', 'Ronny Turiaf', 'Tariq Abdul-Wahad', 'Frédéric Weis', 'Yannick Noah', 'Joakim Noah', 'Kevin Seraphin', 'Ian Mahinmi') OR
    name LIKE '%test%' OR
    name LIKE '%Test%' OR
    email LIKE '%test%' OR
    email LIKE '%Test%'
);

-- Supprimer les profils de juristes
DELETE FROM lawyer_profiles 
WHERE user_id IN (
  SELECT id FROM users 
  WHERE 
    email LIKE '%@example.com' OR
    name IN ('Victor Wembanyama', 'Evan Fournier', 'Nando De Colo', 'Rudy Gobert', 'Nicolas Batum', 'Tony Parker', 'Boris Diaw', 'Florent Pietrus', 'Mickaël Gelabale', 'Johan Petro', 'Ronny Turiaf', 'Tariq Abdul-Wahad', 'Frédéric Weis', 'Yannick Noah', 'Joakim Noah', 'Kevin Seraphin', 'Ian Mahinmi') OR
    name LIKE '%test%' OR
    name LIKE '%Test%' OR
    email LIKE '%test%' OR
    email LIKE '%Test%'
);

-- Supprimer les messages
DELETE FROM messages 
WHERE sender_id IN (
  SELECT id FROM users 
  WHERE 
    email LIKE '%@example.com' OR
    name IN ('Victor Wembanyama', 'Evan Fournier', 'Nando De Colo', 'Rudy Gobert', 'Nicolas Batum', 'Tony Parker', 'Boris Diaw', 'Florent Pietrus', 'Mickaël Gelabale', 'Johan Petro', 'Ronny Turiaf', 'Tariq Abdul-Wahad', 'Frédéric Weis', 'Yannick Noah', 'Joakim Noah', 'Kevin Seraphin', 'Ian Mahinmi') OR
    name LIKE '%test%' OR
    name LIKE '%Test%' OR
    email LIKE '%test%' OR
    email LIKE '%Test%'
) OR receiver_id IN (
  SELECT id FROM users 
  WHERE 
    email LIKE '%@example.com' OR
    name IN ('Victor Wembanyama', 'Evan Fournier', 'Nando De Colo', 'Rudy Gobert', 'Nicolas Batum', 'Tony Parker', 'Boris Diaw', 'Florent Pietrus', 'Mickaël Gelabale', 'Johan Petro', 'Ronny Turiaf', 'Tariq Abdul-Wahad', 'Frédéric Weis', 'Yannick Noah', 'Joakim Noah', 'Kevin Seraphin', 'Ian Mahinmi') OR
    name LIKE '%test%' OR
    name LIKE '%Test%' OR
    email LIKE '%test%' OR
    email LIKE '%Test%'
);

-- Supprimer les posts
DELETE FROM posts 
WHERE user_id IN (
  SELECT id FROM users 
  WHERE 
    email LIKE '%@example.com' OR
    name IN ('Victor Wembanyama', 'Evan Fournier', 'Nando De Colo', 'Rudy Gobert', 'Nicolas Batum', 'Tony Parker', 'Boris Diaw', 'Florent Pietrus', 'Mickaël Gelabale', 'Johan Petro', 'Ronny Turiaf', 'Tariq Abdul-Wahad', 'Frédéric Weis', 'Yannick Noah', 'Joakim Noah', 'Kevin Seraphin', 'Ian Mahinmi') OR
    name LIKE '%test%' OR
    name LIKE '%Test%' OR
    email LIKE '%test%' OR
    email LIKE '%Test%'
);

-- Supprimer les candidatures
DELETE FROM applications 
WHERE user_id IN (
  SELECT id FROM users 
  WHERE 
    email LIKE '%@example.com' OR
    name IN ('Victor Wembanyama', 'Evan Fournier', 'Nando De Colo', 'Rudy Gobert', 'Nicolas Batum', 'Tony Parker', 'Boris Diaw', 'Florent Pietrus', 'Mickaël Gelabale', 'Johan Petro', 'Ronny Turiaf', 'Tariq Abdul-Wahad', 'Frédéric Weis', 'Yannick Noah', 'Joakim Noah', 'Kevin Seraphin', 'Ian Mahinmi') OR
    name LIKE '%test%' OR
    name LIKE '%Test%' OR
    email LIKE '%test%' OR
    email LIKE '%Test%'
);

-- Supprimer les opportunités créées par ces utilisateurs
DELETE FROM opportunities 
WHERE user_id IN (
  SELECT id FROM users 
  WHERE 
    email LIKE '%@example.com' OR
    name IN ('Victor Wembanyama', 'Evan Fournier', 'Nando De Colo', 'Rudy Gobert', 'Nicolas Batum', 'Tony Parker', 'Boris Diaw', 'Florent Pietrus', 'Mickaël Gelabale', 'Johan Petro', 'Ronny Turiaf', 'Tariq Abdul-Wahad', 'Frédéric Weis', 'Yannick Noah', 'Joakim Noah', 'Kevin Seraphin', 'Ian Mahinmi') OR
    name LIKE '%test%' OR
    name LIKE '%Test%' OR
    email LIKE '%test%' OR
    email LIKE '%Test%'
);

-- Supprimer les annonces
DELETE FROM annonces 
WHERE user_id IN (
  SELECT id FROM users 
  WHERE 
    email LIKE '%@example.com' OR
    name IN ('Victor Wembanyama', 'Evan Fournier', 'Nando De Colo', 'Rudy Gobert', 'Nicolas Batum', 'Tony Parker', 'Boris Diaw', 'Florent Pietrus', 'Mickaël Gelabale', 'Johan Petro', 'Ronny Turiaf', 'Tariq Abdul-Wahad', 'Frédéric Weis', 'Yannick Noah', 'Joakim Noah', 'Kevin Seraphin', 'Ian Mahinmi') OR
    name LIKE '%test%' OR
    name LIKE '%Test%' OR
    email LIKE '%test%' OR
    email LIKE '%Test%'
);

-- Supprimer les likes de posts
DELETE FROM post_likes 
WHERE user_id IN (
  SELECT id FROM users 
  WHERE 
    email LIKE '%@example.com' OR
    name IN ('Victor Wembanyama', 'Evan Fournier', 'Nando De Colo', 'Rudy Gobert', 'Nicolas Batum', 'Tony Parker', 'Boris Diaw', 'Florent Pietrus', 'Mickaël Gelabale', 'Johan Petro', 'Ronny Turiaf', 'Tariq Abdul-Wahad', 'Frédéric Weis', 'Yannick Noah', 'Joakim Noah', 'Kevin Seraphin', 'Ian Mahinmi') OR
    name LIKE '%test%' OR
    name LIKE '%Test%' OR
    email LIKE '%test%' OR
    email LIKE '%Test%'
);

-- Supprimer les commentaires
DELETE FROM post_comments 
WHERE user_id IN (
  SELECT id FROM users 
  WHERE 
    email LIKE '%@example.com' OR
    name IN ('Victor Wembanyama', 'Evan Fournier', 'Nando De Colo', 'Rudy Gobert', 'Nicolas Batum', 'Tony Parker', 'Boris Diaw', 'Florent Pietrus', 'Mickaël Gelabale', 'Johan Petro', 'Ronny Turiaf', 'Tariq Abdul-Wahad', 'Frédéric Weis', 'Yannick Noah', 'Joakim Noah', 'Kevin Seraphin', 'Ian Mahinmi') OR
    name LIKE '%test%' OR
    name LIKE '%Test%' OR
    email LIKE '%test%' OR
    email LIKE '%Test%'
);

-- 3. Supprimer les utilisateurs de test et célébrités
DELETE FROM users 
WHERE 
  email LIKE '%@example.com' OR
  name IN ('Victor Wembanyama', 'Evan Fournier', 'Nando De Colo', 'Rudy Gobert', 'Nicolas Batum', 'Tony Parker', 'Boris Diaw', 'Florent Pietrus', 'Mickaël Gelabale', 'Johan Petro', 'Ronny Turiaf', 'Tariq Abdul-Wahad', 'Frédéric Weis', 'Yannick Noah', 'Joakim Noah', 'Kevin Seraphin', 'Ian Mahinmi') OR
  name LIKE '%test%' OR
  name LIKE '%Test%' OR
  email LIKE '%test%' OR
  email LIKE '%Test%';

-- 4. Nettoyer les équipes de test
DELETE FROM teams 
WHERE 
  name LIKE '%test%' OR 
  name LIKE '%Test%' OR
  name IN ('Équipe Test', 'Test Team', 'Équipe de Test');

-- 5. Vérification finale
SELECT 'Vérification finale:' as info;
SELECT 'Utilisateurs restants:' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Équipes restantes:', COUNT(*) FROM teams
UNION ALL
SELECT 'Messages restants:', COUNT(*) FROM messages
UNION ALL
SELECT 'Posts restants:', COUNT(*) FROM posts;

-- Afficher les utilisateurs restants
SELECT 'Utilisateurs restants:' as info;
SELECT id, name, email, profile_type, created_at FROM users ORDER BY created_at DESC;
