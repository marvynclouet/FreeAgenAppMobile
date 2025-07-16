-- Script pour corriger les contraintes et adapter la structure

-- 1. Supprimer la contrainte qui fait référence à opportunities
ALTER TABLE applications DROP FOREIGN KEY applications_ibfk_2;

-- 2. Ajouter une contrainte qui fait référence à annonces
ALTER TABLE applications 
ADD CONSTRAINT applications_ibfk_2 
FOREIGN KEY (opportunity_id) REFERENCES annonces(id) ON DELETE CASCADE;

-- 3. Modifier les conversations pour référencer annonces au lieu de opportunities  
ALTER TABLE conversations DROP FOREIGN KEY conversations_ibfk_1;
ALTER TABLE conversations 
ADD CONSTRAINT conversations_ibfk_1 
FOREIGN KEY (opportunity_id) REFERENCES annonces(id) ON DELETE SET NULL;

-- 4. Ajouter les champs first_name et last_name à users si nécessaire
ALTER TABLE users 
ADD COLUMN first_name VARCHAR(100) AFTER name,
ADD COLUMN last_name VARCHAR(100) AFTER first_name;

-- 5. Migrer le champ name vers first_name/last_name
UPDATE users 
SET 
  first_name = SUBSTRING_INDEX(name, ' ', 1),
  last_name = CASE 
    WHEN LOCATE(' ', name) > 0 
    THEN SUBSTRING(name, LOCATE(' ', name) + 1)
    ELSE ''
  END;

-- 6. Mettre à jour la structure de la nouvelle table messages pour la messagerie
DROP TABLE IF EXISTS messages_new;
CREATE TABLE messages_new (
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

-- 7. Renommer l'ancienne table messages et utiliser la nouvelle
RENAME TABLE messages TO messages_old;
RENAME TABLE messages_new TO messages;

-- 8. Créer les index pour optimiser les performances
CREATE INDEX idx_conversations_sender ON conversations(sender_id);
CREATE INDEX idx_conversations_receiver ON conversations(receiver_id);
CREATE INDEX idx_conversations_opportunity ON conversations(opportunity_id);
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_messages_unread ON messages(is_read, conversation_id);

-- 9. Créer la vue pour les conversations avec le dernier message
DROP VIEW IF EXISTS conversation_list;
CREATE VIEW conversation_list AS
SELECT 
    c.*,
    m.content as last_message,
    m.created_at as last_message_at,
    m.sender_id as last_sender_id,
    (SELECT COUNT(*) FROM messages WHERE conversation_id = c.id AND is_read = FALSE AND sender_id != c.sender_id) as unread_count_sender,
    (SELECT COUNT(*) FROM messages WHERE conversation_id = c.id AND is_read = FALSE AND sender_id != c.receiver_id) as unread_count_receiver,
    u1.first_name as sender_first_name,
    u1.last_name as sender_last_name,
    u2.first_name as receiver_first_name,
    u2.last_name as receiver_last_name,
    a.title as opportunity_title
FROM conversations c
LEFT JOIN messages m ON m.id = (
    SELECT id FROM messages 
    WHERE conversation_id = c.id 
    ORDER BY created_at DESC 
    LIMIT 1
)
LEFT JOIN users u1 ON c.sender_id = u1.id
LEFT JOIN users u2 ON c.receiver_id = u2.id
LEFT JOIN annonces a ON c.opportunity_id = a.id
WHERE c.is_active = TRUE; 