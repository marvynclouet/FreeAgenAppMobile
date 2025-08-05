-- Vérifier et corriger le schéma de la base de données pour les abonnements

-- 1. Vérifier si les colonnes existent
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'users' 
AND COLUMN_NAME IN ('subscription_type', 'is_premium', 'subscription_expiry');

-- 2. Ajouter les colonnes si elles n'existent pas
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS subscription_type VARCHAR(50) DEFAULT 'free',
ADD COLUMN IF NOT EXISTS is_premium BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS subscription_expiry DATETIME NULL;

-- 3. Mettre à jour les utilisateurs existants
UPDATE users 
SET subscription_type = 'free', 
    is_premium = FALSE 
WHERE subscription_type IS NULL OR subscription_type = '';

-- 4. Vérifier la table user_limits
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'user_limits';

-- 5. Créer la table user_limits si elle n'existe pas
CREATE TABLE IF NOT EXISTS user_limits (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    applications_count INT DEFAULT 0,
    opportunities_posted INT DEFAULT 0,
    messages_sent INT DEFAULT 0,
    last_reset_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 6. Insérer les limites pour les utilisateurs qui n'en ont pas
INSERT IGNORE INTO user_limits (user_id, applications_count, opportunities_posted, messages_sent, last_reset_date)
SELECT id, 0, 0, 0, NOW() FROM users 
WHERE id NOT IN (SELECT user_id FROM user_limits);

-- 7. Vérifier la table subscription_plans
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'subscription_plans';

-- 8. Créer la table subscription_plans si elle n'existe pas
CREATE TABLE IF NOT EXISTS subscription_plans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    duration_months INT NOT NULL,
    max_applications INT NOT NULL,
    max_opportunities INT NOT NULL,
    max_messages INT NOT NULL,
    can_post_opportunities BOOLEAN DEFAULT FALSE,
    has_profile_boost BOOLEAN DEFAULT FALSE,
    has_priority_support BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 9. Insérer les plans par défaut
INSERT IGNORE INTO subscription_plans (type, name, price, duration_months, max_applications, max_opportunities, max_messages, can_post_opportunities, has_profile_boost, has_priority_support) VALUES
('free', 'Gratuit', 0.00, 0, 0, 0, 0, FALSE, FALSE, FALSE),
('premium_basic', 'Premium Basic', 9.99, 1, 10, 5, 50, FALSE, FALSE, FALSE),
('premium_pro', 'Premium Pro', 19.99, 1, -1, -1, -1, TRUE, TRUE, TRUE);

-- 10. Afficher le statut final
SELECT 'SCHEMA FIXED' as status; 