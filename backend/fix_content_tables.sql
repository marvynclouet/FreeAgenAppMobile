-- Vérifier et créer les tables pour le système de contenu

-- Table posts
CREATE TABLE IF NOT EXISTS posts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  content TEXT NOT NULL,
  image_urls JSON,
  event_date DATE,
  event_time TIME,
  event_location VARCHAR(255),
  likes_count INT DEFAULT 0,
  comments_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table post_likes
CREATE TABLE IF NOT EXISTS post_likes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  post_id INT NOT NULL,
  user_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_like (post_id, user_id)
);

-- Table post_comments
CREATE TABLE IF NOT EXISTS post_comments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  post_id INT NOT NULL,
  user_id INT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table events
CREATE TABLE IF NOT EXISTS events (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  image_url VARCHAR(500),
  event_date DATE NOT NULL,
  event_time TIME,
  event_location VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insérer quelques posts de test
INSERT IGNORE INTO posts (user_id, content, created_at) VALUES
(1, 'Bienvenue sur FreeAgent App ! 🏀', NOW()),
(2, 'Nouvelle opportunité de recrutement disponible', NOW()),
(3, 'Stage de préparation physique ce weekend', NOW());

-- Insérer quelques événements de test
INSERT IGNORE INTO events (user_id, title, description, event_date, event_location, created_at) VALUES
(1, 'Tournoi de basket amateur', 'Tournoi ouvert à tous les niveaux', DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'Paris', NOW()),
(2, 'Stage de coaching', 'Stage intensif pour jeunes joueurs', DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'Lyon', NOW());

-- Vérifier les tables créées
SHOW TABLES LIKE '%post%';
SHOW TABLES LIKE '%event%'; 