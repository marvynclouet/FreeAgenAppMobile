-- Script pour ajouter le support des abonnements premium
USE freeagent_db;

-- 1. Modifier la table users pour ajouter les colonnes d'abonnement
ALTER TABLE users ADD COLUMN IF NOT EXISTS subscription_type ENUM('free', 'premium_basic', 'premium_pro') DEFAULT 'free';
ALTER TABLE users ADD COLUMN IF NOT EXISTS subscription_expiry DATETIME NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS subscription_created_at DATETIME NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_premium BOOLEAN DEFAULT FALSE;

-- 2. Créer la table des abonnements pour historique et gestion
CREATE TABLE IF NOT EXISTS subscriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    subscription_type ENUM('premium_basic', 'premium_pro') NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    duration_months INT NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    status ENUM('active', 'cancelled', 'expired') DEFAULT 'active',
    payment_method VARCHAR(50) DEFAULT 'manual',
    payment_id VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. Créer la table des limitations pour suivre l'utilisation
CREATE TABLE IF NOT EXISTS user_limits (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    applications_count INT DEFAULT 0,
    opportunities_posted INT DEFAULT 0,
    messages_sent INT DEFAULT 0,
    last_reset_date DATE DEFAULT (CURRENT_DATE),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 4. Créer la table des plans d'abonnement
CREATE TABLE IF NOT EXISTS subscription_plans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    type ENUM('premium_basic', 'premium_pro') NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    duration_months INT NOT NULL,
    max_applications INT DEFAULT -1 COMMENT '-1 = illimité',
    max_opportunities INT DEFAULT -1 COMMENT '-1 = illimité',
    max_messages INT DEFAULT -1 COMMENT '-1 = illimité',
    can_post_opportunities BOOLEAN DEFAULT FALSE,
    has_profile_boost BOOLEAN DEFAULT FALSE,
    has_priority_support BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 5. Insérer les plans d'abonnement
INSERT INTO subscription_plans (name, type, price, duration_months, max_applications, max_opportunities, max_messages, can_post_opportunities, has_profile_boost, has_priority_support) VALUES
('Premium Basic Mensuel', 'premium_basic', 5.99, 1, 3, 3, -1, TRUE, FALSE, FALSE),
('Premium Basic Annuel', 'premium_basic', 59.99, 12, 3, 3, -1, TRUE, FALSE, FALSE),
('Premium Pro Mensuel', 'premium_pro', 9.00, 1, -1, -1, -1, TRUE, TRUE, TRUE),
('Premium Pro Annuel', 'premium_pro', 90.00, 12, -1, -1, -1, TRUE, TRUE, TRUE);

-- 6. Créer les index pour optimiser les performances
CREATE INDEX IF NOT EXISTS idx_users_subscription ON users(subscription_type, subscription_expiry);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user ON subscriptions(user_id, status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_dates ON subscriptions(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_user_limits_user ON user_limits(user_id);

-- 7. Créer un trigger pour initialiser les limites des nouveaux utilisateurs
DELIMITER //
CREATE TRIGGER IF NOT EXISTS after_user_insert_limits
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO user_limits (user_id) VALUES (NEW.id);
END//
DELIMITER ;

-- 8. Créer un trigger pour mettre à jour le statut premium automatiquement
DELIMITER //
CREATE TRIGGER IF NOT EXISTS before_user_update_premium
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    IF NEW.subscription_expiry IS NOT NULL AND NEW.subscription_expiry > NOW() THEN
        SET NEW.is_premium = TRUE;
    ELSE
        SET NEW.is_premium = FALSE;
    END IF;
END//
DELIMITER ;

-- 9. Créer une procédure stockée pour vérifier et expirer les abonnements
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS ExpireSubscriptions()
BEGIN
    -- Expirer les abonnements
    UPDATE subscriptions 
    SET status = 'expired' 
    WHERE end_date < NOW() AND status = 'active';
    
    -- Mettre à jour les utilisateurs
    UPDATE users 
    SET is_premium = FALSE, 
        subscription_type = 'free',
        subscription_expiry = NULL
    WHERE subscription_expiry < NOW() AND is_premium = TRUE;
END//
DELIMITER ;

-- 10. Créer un événement pour exécuter la procédure quotidiennement
CREATE EVENT IF NOT EXISTS daily_subscription_cleanup
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
  CALL ExpireSubscriptions();

-- 11. Vérifier que les modifications ont été appliquées
SELECT 
    COLUMN_NAME, 
    COLUMN_TYPE, 
    IS_NULLABLE, 
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'freeagent_db' 
AND TABLE_NAME = 'users' 
AND COLUMN_NAME IN ('subscription_type', 'subscription_expiry', 'is_premium');

-- 12. Afficher les plans d'abonnement créés
SELECT * FROM subscription_plans ORDER BY price; 