-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost:8889
-- Généré le : lun. 02 juin 2025 à 17:24
-- Version du serveur : 8.0.40
-- Version de PHP : 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `freeagent_db`
--

-- --------------------------------------------------------

--
-- Structure de la table `applications`
--

CREATE TABLE `applications` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `opportunity_id` int NOT NULL,
  `message` text,
  `status` enum('pending','accepted','rejected') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `club_profiles`
--

CREATE TABLE `club_profiles` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `club_name` varchar(255) DEFAULT NULL,
  `level` varchar(50) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `description` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `coach_basket_profiles`
--

CREATE TABLE `coach_basket_profiles` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `level` varchar(50) DEFAULT NULL,
  `experience_years` int DEFAULT NULL,
  `teams_coached` text,
  `achievements` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `coach_pro_profiles`
--

CREATE TABLE `coach_pro_profiles` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `speciality` varchar(255) DEFAULT NULL,
  `experience_years` int DEFAULT NULL,
  `certifications` text,
  `hourly_rate` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `contents`
--

CREATE TABLE `contents` (
  `id` int NOT NULL,
  `title` varchar(100) NOT NULL,
  `content` text NOT NULL,
  `author_id` int NOT NULL,
  `type` enum('article','video','image') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dieteticienne_profiles`
--

CREATE TABLE `dieteticienne_profiles` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `speciality` varchar(255) DEFAULT NULL,
  `certifications` text,
  `experience_years` int DEFAULT NULL,
  `hourly_rate` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `juriste_profiles`
--

CREATE TABLE `juriste_profiles` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `speciality` varchar(255) DEFAULT NULL,
  `bar_number` varchar(100) DEFAULT NULL,
  `experience_years` int DEFAULT NULL,
  `hourly_rate` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `messages`
--

CREATE TABLE `messages` (
  `id` int NOT NULL,
  `sender_id` int NOT NULL,
  `receiver_id` int NOT NULL,
  `content` text NOT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `opportunities`
--


-- --------------------------------------------------------

--
-- Structure de la table `player_profiles`
--

CREATE TABLE `player_profiles` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `age` int DEFAULT NULL,
  `height` float DEFAULT NULL,
  `weight` float DEFAULT NULL,
  `position` varchar(50) DEFAULT NULL,
  `experience_years` int DEFAULT NULL,
  `level` varchar(50) DEFAULT NULL,
  `achievements` text,
  `stats` json DEFAULT NULL,
  `video_url` varchar(255) DEFAULT NULL,
  `bio` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `player_profiles`
--

INSERT INTO `player_profiles` (`id`, `user_id`, `age`, `height`, `weight`, `position`, `experience_years`, `level`, `achievements`, `stats`, `video_url`, `bio`, `created_at`, `updated_at`) VALUES
(1, 1, 25, 183, 90, 'Meneur', 5, 'Amateur', '', '{\"blocks\": \"\", \"points\": \"\", \"steals\": \"\", \"assists\": \"\", \"rebounds\": \"\"}', '', '', '2025-06-02 16:59:21', '2025-06-02 16:59:21');

-- --------------------------------------------------------

--
-- Structure de la table `teams`
--

CREATE TABLE `teams` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `city` varchar(100) NOT NULL,
  `description` text,
  `logo_url` varchar(255) DEFAULT NULL,
  `level` varchar(50) DEFAULT NULL,
  `division` varchar(50) DEFAULT NULL,
  `founded_year` int DEFAULT NULL,
  `achievements` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `profile_type` enum('player','coach_pro','coach_basket','juriste','dieteticienne','club') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `profile_type`, `created_at`, `updated_at`) VALUES
(1, 'Marvyn', 'marvyn@gmail.com', '$2b$10$YSHSQFYG3BDUGyWRVDWV0u.klCVgVB/UXRu6d8tY2BnUtT/LK95Fi', 'player', '2025-06-02 16:31:48', '2025-06-02 16:31:48'),
(2, 'Victor Wembanyama', 'victor.wembanyama@example.com', '$2b$10$example_hash', 'player', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(3, 'Evan Fournier', 'evan.fournier@example.com', '$2b$10$example_hash', 'player', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(4, 'Nando De Colo', 'nando.decolo@example.com', '$2b$10$example_hash', 'player', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(5, 'Rudy Gobert', 'rudy.gobert@example.com', '$2b$10$example_hash', 'player', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(6, 'Nicolas Batum', 'nicolas.batum@example.com', '$2b$10$example_hash', 'player', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(7, 'Vincent Collet', 'vincent.collet@example.com', '$2b$10$example_hash', 'coach_pro', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(8, 'Pascal Donnadieu', 'pascal.donnadieu@example.com', '$2b$10$example_hash', 'coach_pro', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(9, 'Laurent Foirest', 'laurent.foirest@example.com', '$2b$10$example_hash', 'coach_pro', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(10, 'Frederic Fauthoux', 'frederic.fauthoux@example.com', '$2b$10$example_hash', 'coach_basket', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(11, 'Jean-Aimé Toupane', 'jean-aime.toupane@example.com', '$2b$10$example_hash', 'coach_basket', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(12, 'Laurent Pluvy', 'laurent.pluvy@example.com', '$2b$10$example_hash', 'coach_basket', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(13, 'Marie Dupont', 'marie.dupont@example.com', '$2b$10$example_hash', 'juriste', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(14, 'Pierre Martin', 'pierre.martin@example.com', '$2b$10$example_hash', 'juriste', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(15, 'Sophie Bernard', 'sophie.bernard@example.com', '$2b$10$example_hash', 'juriste', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(16, 'Julie Petit', 'julie.petit@example.com', '$2b$10$example_hash', 'dieteticienne', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(17, 'Camille Dubois', 'camille.dubois@example.com', '$2b$10$example_hash', 'dieteticienne', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(18, 'Léa Moreau', 'lea.moreau@example.com', '$2b$10$example_hash', 'dieteticienne', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(19, 'ASVEL Villeurbanne', 'contact@asvel.com', '$2b$10$example_hash', 'club', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(20, 'Stade Rennais Basket', 'contact@staderennaisbasket.com', '$2b$10$example_hash', 'club', '2025-06-02 17:17:13', '2025-06-02 17:17:13'),
(21, 'Paris Basketball', 'contact@parisbasketball.com', '$2b$10$example_hash', 'club', '2025-06-02 17:17:13', '2025-06-02 17:17:13');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `applications`
--
ALTER TABLE `applications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `opportunity_id` (`opportunity_id`);

--
-- Index pour la table `club_profiles`
--
ALTER TABLE `club_profiles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Index pour la table `coach_basket_profiles`
--
ALTER TABLE `coach_basket_profiles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Index pour la table `coach_pro_profiles`
--
ALTER TABLE `coach_pro_profiles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Index pour la table `contents`
--
ALTER TABLE `contents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `author_id` (`author_id`);

--
-- Index pour la table `dieteticienne_profiles`
--
ALTER TABLE `dieteticienne_profiles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Index pour la table `juriste_profiles`
--
ALTER TABLE `juriste_profiles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Index pour la table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sender_id` (`sender_id`),
  ADD KEY `receiver_id` (`receiver_id`);

--
-- Index pour la table `opportunities`
--
ALTER TABLE `opportunities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `team_id` (`team_id`);

--
-- Index pour la table `player_profiles`
--
ALTER TABLE `player_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Index pour la table `teams`
--
ALTER TABLE `teams`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `applications`
--
ALTER TABLE `applications`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `club_profiles`
--
ALTER TABLE `club_profiles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `coach_basket_profiles`
--
ALTER TABLE `coach_basket_profiles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `coach_pro_profiles`
--
ALTER TABLE `coach_pro_profiles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `contents`
--
ALTER TABLE `contents`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dieteticienne_profiles`
--
ALTER TABLE `dieteticienne_profiles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `juriste_profiles`
--
ALTER TABLE `juriste_profiles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `opportunities`
--
ALTER TABLE `opportunities`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `player_profiles`
--
ALTER TABLE `player_profiles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `teams`
--
ALTER TABLE `teams`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `applications`
--
ALTER TABLE `applications`
  ADD CONSTRAINT `applications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `applications_ibfk_2` FOREIGN KEY (`opportunity_id`) REFERENCES `opportunities` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `club_profiles`
--
ALTER TABLE `club_profiles`
  ADD CONSTRAINT `club_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `coach_basket_profiles`
--
ALTER TABLE `coach_basket_profiles`
  ADD CONSTRAINT `coach_basket_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `coach_pro_profiles`
--
ALTER TABLE `coach_pro_profiles`
  ADD CONSTRAINT `coach_pro_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `contents`
--
ALTER TABLE `contents`
  ADD CONSTRAINT `contents_ibfk_1` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `dieteticienne_profiles`
--
ALTER TABLE `dieteticienne_profiles`
  ADD CONSTRAINT `dieteticienne_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `juriste_profiles`
--
ALTER TABLE `juriste_profiles`
  ADD CONSTRAINT `juriste_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `opportunities`
--
ALTER TABLE `opportunities`
  ADD CONSTRAINT `opportunities_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `player_profiles`
--
ALTER TABLE `player_profiles`
  ADD CONSTRAINT `player_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
