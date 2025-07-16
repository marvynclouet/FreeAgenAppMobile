-- Script SQL pour créer les tables de la messagerie

-- Table des conversations
CREATE TABLE IF NOT EXISTS conversations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    opportunity_id INT,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    subject VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (opportunity_id) REFERENCES opportunities(id) ON DELETE SET NULL,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_conversation (opportunity_id, sender_id, receiver_id)
);

-- Table des messages
CREATE TABLE IF NOT EXISTS messages (
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

-- Index pour optimiser les requêtes
CREATE INDEX idx_conversations_sender ON conversations(sender_id);
CREATE INDEX idx_conversations_receiver ON conversations(receiver_id);
CREATE INDEX idx_conversations_opportunity ON conversations(opportunity_id);
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_messages_unread ON messages(is_read, conversation_id);

-- Vue pour les conversations avec le dernier message
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
    o.title as opportunity_title
FROM conversations c
LEFT JOIN messages m ON m.id = (
    SELECT id FROM messages 
    WHERE conversation_id = c.id 
    ORDER BY created_at DESC 
    LIMIT 1
)
LEFT JOIN users u1 ON c.sender_id = u1.id
LEFT JOIN users u2 ON c.receiver_id = u2.id
LEFT JOIN opportunities o ON c.opportunity_id = o.id
WHERE c.is_active = TRUE; 