-- Créer la table pour les profils de coachs professionnels
CREATE TABLE IF NOT EXISTS coach_pro_profiles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  experience_years INT DEFAULT 0,
  level VARCHAR(50),
  specialization VARCHAR(255),
  achievements TEXT,
  description TEXT,
  phone VARCHAR(20),
  website VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Créer la table pour les profils de coachs de basket
CREATE TABLE IF NOT EXISTS coach_basket_profiles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  experience_years INT DEFAULT 0,
  level VARCHAR(50),
  specialization VARCHAR(255),
  achievements TEXT,
  description TEXT,
  phone VARCHAR(20),
  website VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Créer la table pour les profils de diététiciennes
CREATE TABLE IF NOT EXISTS dieteticienne_profiles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  experience_years INT DEFAULT 0,
  level VARCHAR(50),
  specialization VARCHAR(255),
  achievements TEXT,
  description TEXT,
  phone VARCHAR(20),
  website VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Créer la table pour les profils de juristes
CREATE TABLE IF NOT EXISTS juriste_profiles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  experience_years INT DEFAULT 0,
  level VARCHAR(50),
  specialization VARCHAR(255),
  achievements TEXT,
  description TEXT,
  phone VARCHAR(20),
  website VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
