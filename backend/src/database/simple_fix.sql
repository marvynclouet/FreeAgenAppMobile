-- Script SQL simplifié pour corriger rapidement

-- 1. Vérifier et corriger la contrainte applications -> annonces
SELECT CONSTRAINT_NAME FROM information_schema.KEY_COLUMN_USAGE 
WHERE TABLE_NAME = 'applications' AND COLUMN_NAME = 'opportunity_id';

-- Si la contrainte existe et pointe vers opportunities, la supprimer et recréer
-- (Exécutez ceci seulement si nécessaire)
-- ALTER TABLE applications DROP FOREIGN KEY applications_ibfk_2;
-- ALTER TABLE applications ADD CONSTRAINT applications_ibfk_2 FOREIGN KEY (opportunity_id) REFERENCES annonces(id) ON DELETE CASCADE;

-- 2. Ajouter first_name et last_name à users si elles n'existent pas
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS first_name VARCHAR(100) AFTER name,
ADD COLUMN IF NOT EXISTS last_name VARCHAR(100) AFTER first_name;

-- 3. Migrer les noms existants seulement si first_name est vide
UPDATE users 
SET 
  first_name = COALESCE(NULLIF(first_name, ''), SUBSTRING_INDEX(name, ' ', 1)),
  last_name = COALESCE(NULLIF(last_name, ''), 
    CASE 
      WHEN LOCATE(' ', name) > 0 
      THEN SUBSTRING(name, LOCATE(' ', name) + 1)
      ELSE ''
    END)
WHERE first_name IS NULL OR first_name = '';

-- 4. S'assurer que la table conversations existe
CREATE TABLE IF NOT EXISTS conversations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    opportunity_id INT DEFAULT NULL,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    subject VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active TINYINT(1) DEFAULT 1,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 5. S'assurer que la table messages a la bonne structure
CREATE TABLE IF NOT EXISTS messages_new (
    id INT PRIMARY KEY AUTO_INCREMENT,
    conversation_id INT NOT NULL,
    sender_id INT NOT NULL,
    content TEXT NOT NULL,
    message_type ENUM('text', 'application', 'system') DEFAULT 'text',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 6. Si messages_new est différente de messages, faire la migration
-- (Vérifiez d'abord la structure avant d'exécuter)
-- DROP TABLE IF EXISTS messages_old;
-- RENAME TABLE messages TO messages_old;
-- RENAME TABLE messages_new TO messages;

-- 7. Test simple
SELECT 'Configuration terminée' as status; 