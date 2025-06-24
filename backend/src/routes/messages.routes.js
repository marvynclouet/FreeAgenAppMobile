const express = require('express');
const router = express.Router();
const db = require('../database/db');
const verifyToken = require('../middleware/auth.middleware');

// Récupérer toutes les conversations d'un utilisateur
router.get('/conversations', verifyToken, async (req, res) => {
    try {
        const userId = req.user.id;
        const query = `
            SELECT DISTINCT 
                m.sender_id, 
                m.receiver_id,
                u.username as other_user_name,
                u.profile_image as other_user_image,
                (SELECT content FROM messages 
                 WHERE (sender_id = m.sender_id AND receiver_id = m.receiver_id)
                    OR (sender_id = m.receiver_id AND receiver_id = m.sender_id)
                 ORDER BY created_at DESC LIMIT 1) as last_message,
                (SELECT created_at FROM messages 
                 WHERE (sender_id = m.sender_id AND receiver_id = m.receiver_id)
                    OR (sender_id = m.receiver_id AND receiver_id = m.sender_id)
                 ORDER BY created_at DESC LIMIT 1) as last_message_time
            FROM messages m
            JOIN users u ON (
                CASE 
                    WHEN m.sender_id = ? THEN m.receiver_id = u.id
                    ELSE m.sender_id = u.id
                END
            )
            WHERE m.sender_id = ? OR m.receiver_id = ?
            ORDER BY last_message_time DESC
        `;
        
        const [conversations] = await db.query(query, [userId, userId, userId]);
        res.json(conversations);
    } catch (error) {
        console.error('Error fetching conversations:', error);
        res.status(500).json({ message: 'Erreur lors de la récupération des conversations' });
    }
});

// Récupérer les messages entre deux utilisateurs
router.get('/:userId', verifyToken, async (req, res) => {
    try {
        const currentUserId = req.user.id;
        const otherUserId = req.params.userId;
        
        const query = `
            SELECT m.*, 
                   u.username as sender_name,
                   u.profile_image as sender_image
            FROM messages m
            JOIN users u ON m.sender_id = u.id
            WHERE (m.sender_id = ? AND m.receiver_id = ?)
               OR (m.sender_id = ? AND m.receiver_id = ?)
            ORDER BY m.created_at ASC
        `;
        
        const [messages] = await db.query(query, [
            currentUserId, otherUserId,
            otherUserId, currentUserId
        ]);
        
        // Marquer les messages comme lus
        await db.query(
            'UPDATE messages SET is_read = true WHERE sender_id = ? AND receiver_id = ? AND is_read = false',
            [otherUserId, currentUserId]
        );
        
        res.json(messages);
    } catch (error) {
        console.error('Error fetching messages:', error);
        res.status(500).json({ message: 'Erreur lors de la récupération des messages' });
    }
});

// Envoyer un message
router.post('/', verifyToken, async (req, res) => {
    try {
        const { receiverId, content } = req.body;
        const senderId = req.user.id;
        
        const query = `
            INSERT INTO messages (sender_id, receiver_id, content, created_at)
            VALUES (?, ?, ?, NOW())
        `;
        
        const [result] = await db.query(query, [senderId, receiverId, content]);
        
        const [newMessage] = await db.query(
            'SELECT m.*, u.username as sender_name, u.profile_image as sender_image FROM messages m JOIN users u ON m.sender_id = u.id WHERE m.id = ?',
            [result.insertId]
        );
        
        res.status(201).json(newMessage[0]);
    } catch (error) {
        console.error('Error sending message:', error);
        res.status(500).json({ message: 'Erreur lors de l\'envoi du message' });
    }
});

module.exports = router; 