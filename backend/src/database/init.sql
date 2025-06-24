
-- Table des joueurs
CREATE TABLE IF NOT EXISTS players (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des profils de joueurs
CREATE TABLE IF NOT EXISTS player_profiles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    player_id INT NOT NULL,
    age INT,
    height INT,
    weight INT,
    position VARCHAR(50),
    experience_years INT,
    level VARCHAR(50),
    achievements TEXT,
    video_url VARCHAR(255),
    bio TEXT,
    stats JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);

-- Trigger pour créer automatiquement un profil de joueur lors de la création d'un joueur
DELIMITER //
CREATE TRIGGER after_player_insert
AFTER INSERT ON players
FOR EACH ROW
BEGIN
    INSERT INTO player_profiles (player_id) VALUES (NEW.id);
END//
DELIMITER ;

-- Supprimer la table opportunities si elle existe
DROP TABLE IF EXISTS applications;
DROP TABLE IF EXISTS opportunities;

-- Recréer la table opportunities avec la structure existante
CREATE TABLE `opportunities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `team_id` int NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `type` enum('recrutement','coaching','consultation') NOT NULL,
  `requirements` text,
  `salary_range` varchar(100) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `status` enum('open','closed') DEFAULT 'open',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `team_id` (`team_id`),
  CONSTRAINT `opportunities_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Recréer la table applications
CREATE TABLE applications (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  opportunity_id INT NOT NULL,
  message TEXT,
  status ENUM('pending', 'accepted', 'rejected') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (opportunity_id) REFERENCES opportunities(id) ON DELETE CASCADE
); 