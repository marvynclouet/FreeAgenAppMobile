-- ================================================
-- 4. CRÉATION DES PROFILS JOUEURS (VERSION FORMATÉE)
-- ================================================

INSERT INTO player_profiles (user_id, age, height, weight, position, experience_years, level, achievements, bio) VALUES

-- Joueurs expérimentés Pro A
(
    (SELECT id FROM users WHERE email = 'antoine.diot@basketeur.com'), 
    32, 1.93, 84, 'Meneur', 12, 'Pro A', 
    'International français, multiple champion de France, expérience EuroLeague', 
    'Meneur expérimenté avec une excellente vision de jeu et un leadership naturel. Passé par plusieurs clubs européens de haut niveau.'
),

(
    (SELECT id FROM users WHERE email = 'paul.lacombe@basketeur.com'), 
    28, 2.05, 95, 'Ailier-Fort', 8, 'Pro A', 
    'Champion de France 2021, sélection équipe de France', 
    'Ailier-fort polyvalent, excellent défenseur avec une bonne adresse à 3 points. Formation française de qualité.'
),

(
    (SELECT id FROM users WHERE email = 'marcus.lewis@basketeur.com'), 
    26, 1.91, 86, 'Arrière', 6, 'Pro A', 
    'Meilleur marqueur Pro B 2020, rookie de l année', 
    'Arrière américain naturalisé, excellent scoreur avec une mentalité de winner. Adaptation rapide au basket européen.'
),

(
    (SELECT id FROM users WHERE email = 'theo.maledon@basketeur.com'), 
    23, 1.93, 82, 'Meneur', 4, 'Pro A', 
    'Expérience NBA, international français espoirs', 
    'Jeune meneur talentueux formé en France, expérience NBA avec Oklahoma City. Retour en Europe avec de grandes ambitions.'
),

(
    (SELECT id FROM users WHERE email = 'hugo.besson@basketeur.com'), 
    22, 1.98, 87, 'Arrière-Ailier', 3, 'Pro A', 
    'Champion d Europe U20, révélation de l année', 
    'Jeune talent français très prometteur, polyvalence offensive et belle progression défensive.'
),

-- Joueurs confirmés
(
    (SELECT id FROM users WHERE email = 'maxime.courby@basketeur.com'), 
    29, 2.08, 110, 'Pivot', 9, 'Pro A', 
    'Défenseur de l année 2019, international français', 
    'Pivot défensif de référence, excellent rebondeur avec une présence rassurante dans la raquette.'
),

(
    (SELECT id FROM users WHERE email = 'jordan.usher@basketeur.com'), 
    25, 2.01, 93, 'Ailier', 4, 'Pro A', 
    'Champion NCAA, rookie européen prometteur', 
    'Ailier athlétique avec un potentiel énorme, adaptation en cours au jeu européen.'
),

(
    (SELECT id FROM users WHERE email = 'vincent.poirier@basketeur.com'), 
    30, 2.13, 115, 'Pivot', 10, 'Pro A', 
    'Expérience NBA, EuroLeague, international français', 
    'Pivot mobile avec expérience internationale, capable de jouer loin du cercle.'
),

(
    (SELECT id FROM users WHERE email = 'isaia.cordinier@basketeur.com'), 
    27, 1.95, 88, 'Arrière-Ailier', 7, 'Pro A', 
    'International français, expérience EuroLeague', 
    'Arrière-ailier complet, bon défenseur avec une polyvalence appréciée des coaches.'
),

(
    (SELECT id FROM users WHERE email = 'leo.westermann@basketeur.com'), 
    31, 1.98, 89, 'Meneur-Arrière', 11, 'Pro A', 
    'International français, leader d expérience', 
    'Meneur-arrière expérimenté, excellent passeur et leader vocal sur le terrain.'
),

-- Joueurs free
(
    (SELECT id FROM users WHERE email = 'thomas.heurtel@basketeur.com'), 
    34, 1.89, 81, 'Meneur', 14, 'Pro A', 
    'International français, expérience EuroLeague', 
    'Meneur créateur de classe mondiale, vision de jeu exceptionnelle.'
),

(
    (SELECT id FROM users WHERE email = 'joffrey.lauvergne@basketeur.com'), 
    32, 2.11, 115, 'Pivot', 12, 'Pro A', 
    'Expérience NBA, international français', 
    'Pivot technique avec expérience NBA et internationale.'
),

(
    (SELECT id FROM users WHERE email = 'terry.tarpey@basketeur.com'), 
    29, 2.01, 95, 'Ailier-Fort', 8, 'Pro A', 
    'Naturalisé français, polyvalence remarquable', 
    'Ailier-fort américain naturalisé, grande polyvalence et intelligence de jeu.'
);

-- Vérification des profils créés
SELECT 
    u.name as 'Nom Joueur',
    pp.position as 'Poste',
    pp.age as 'Age',
    pp.experience_years as 'Expérience',
    pp.level as 'Niveau',
    u.subscription_type as 'Abonnement'
FROM users u
JOIN player_profiles pp ON u.id = pp.user_id
WHERE u.profile_type = 'player'
ORDER BY pp.experience_years DESC; 