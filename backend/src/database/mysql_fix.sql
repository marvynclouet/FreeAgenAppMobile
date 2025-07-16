-- Script SQL compatible MySQL pour corriger la base de données

-- 1. Corriger la contrainte applications -> annonces
-- (Vérifiez d'abord si elle existe)
SET @constraint_exists = (SELECT COUNT(*) FROM information_schema.REFERENTIAL_CONSTRAINTS 
                         WHERE CONSTRAINT_NAME = 'applications_ibfk_2' 
                         AND TABLE_NAME = 'applications'
                         AND REFERENCED_TABLE_NAME = 'opportunities');

-- Si la contrainte pointe vers opportunities, la supprimer
SET @sql = IF(@constraint_exists > 0, 
              'ALTER TABLE applications DROP FOREIGN KEY applications_ibfk_2', 
              'SELECT "Contrainte n\'existe pas" as status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Ajouter la nouvelle contrainte vers annonces
SET @sql = IF(@constraint_exists > 0, 
              'ALTER TABLE applications ADD CONSTRAINT applications_ibfk_2 FOREIGN KEY (opportunity_id) REFERENCES annonces(id) ON DELETE CASCADE', 
              'SELECT "Contrainte non ajoutée" as status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. Vérifier si les colonnes first_name et last_name existent
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS 
                   WHERE TABLE_NAME = 'users' 
                   AND COLUMN_NAME = 'first_name');

-- Ajouter first_name seulement si elle n'existe pas
SET @sql = IF(@col_exists = 0, 
              'ALTER TABLE users ADD COLUMN first_name VARCHAR(100) AFTER name', 
              'SELECT "first_name existe déjà" as status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Vérifier last_name
SET @col_exists2 = (SELECT COUNT(*) FROM information_schema.COLUMNS 
                    WHERE TABLE_NAME = 'users' 
                    AND COLUMN_NAME = 'last_name');

-- Ajouter last_name seulement si elle n'existe pas
SET @sql = IF(@col_exists2 = 0, 
              'ALTER TABLE users ADD COLUMN last_name VARCHAR(100) AFTER first_name', 
              'SELECT "last_name existe déjà" as status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 3. Migrer les noms existants
UPDATE users 
SET 
  first_name = CASE 
    WHEN first_name IS NULL OR first_name = '' 
    THEN SUBSTRING_INDEX(name, ' ', 1)
    ELSE first_name
  END,
  last_name = CASE 
    WHEN last_name IS NULL OR last_name = ''
    THEN CASE 
      WHEN LOCATE(' ', name) > 0 
      THEN SUBSTRING(name, LOCATE(' ', name) + 1)
      ELSE ''
    END
    ELSE last_name
  END;

-- 4. S'assurer que la table conversations a la bonne structure
CREATE TABLE IF NOT EXISTS conversations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    opportunity_id INT DEFAULT NULL,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    subject VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active TINYINT(1) DEFAULT 1,
    INDEX idx_conversations_sender (sender_id),
    INDEX idx_conversations_receiver (receiver_id),
    INDEX idx_conversations_opportunity (opportunity_id),
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (opportunity_id) REFERENCES annonces(id) ON DELETE SET NULL
);

-- 5. Vérifier la structure de la table messages
SET @table_exists = (SELECT COUNT(*) FROM information_schema.TABLES 
                     WHERE TABLE_NAME = 'messages' 
                     AND TABLE_SCHEMA = DATABASE());

SET @conv_col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS 
                        WHERE TABLE_NAME = 'messages' 
                        AND COLUMN_NAME = 'conversation_id'
                        AND TABLE_SCHEMA = DATABASE());

-- Si messages existe mais n'a pas conversation_id, sauvegarder et recréer
SET @sql = IF(@table_exists > 0 AND @conv_col_exists = 0, 
              'RENAME TABLE messages TO messages_backup', 
              'SELECT "Messages déjà OK ou n\'existe pas" as status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Créer la nouvelle table messages
CREATE TABLE IF NOT EXISTS messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    conversation_id INT NOT NULL,
    sender_id INT NOT NULL,
    content TEXT NOT NULL,
    message_type ENUM('text', 'application', 'system') DEFAULT 'text',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_messages_conversation (conversation_id),
    INDEX idx_messages_sender (sender_id),
    INDEX idx_messages_created_at (created_at),
    INDEX idx_messages_unread (is_read, conversation_id),
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 6. Afficher le statut final
SELECT 'Configuration MySQL terminée avec succès !' as status;
SELECT COUNT(*) as conversations_count FROM conversations;
SELECT COUNT(*) as messages_count FROM messages; 