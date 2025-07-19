const express = require('express');
const router = express.Router();
const db = require('../database/db');
const authMiddleware = require('../middleware/auth.middleware');
const { checkPremiumAccess, checkUsageLimit } = require('../middleware/premium.middleware');

// Route racine pour tester
router.get('/', (req, res) => {
  res.json({ message: 'Messages API is working' });
});

// Obtenir toutes les conversations d'un utilisateur
router.get('/conversations', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    console.log('🔄 Récupération des conversations pour l\'utilisateur:', userId);
    
    // Version simplifiée avec fallback pour les noms
    const query = `
      SELECT 
        c.*,
        COALESCE(u1.first_name, u1.name) as sender_first_name,
        COALESCE(u1.last_name, '') as sender_last_name,
        u1.name as sender_full_name,
        COALESCE(u2.first_name, u2.name) as receiver_first_name,
        COALESCE(u2.last_name, '') as receiver_last_name,
        u2.name as receiver_full_name,
        a.title as opportunity_title,
        (SELECT content FROM messages WHERE conversation_id = c.id ORDER BY created_at DESC LIMIT 1) as last_message,
        (SELECT created_at FROM messages WHERE conversation_id = c.id ORDER BY created_at DESC LIMIT 1) as last_message_at,
        (SELECT COUNT(*) FROM messages WHERE conversation_id = c.id AND is_read = FALSE AND sender_id != ?) as unread_count
      FROM conversations c
      LEFT JOIN users u1 ON c.sender_id = u1.id
      LEFT JOIN users u2 ON c.receiver_id = u2.id
      LEFT JOIN annonces a ON c.opportunity_id = a.id
      WHERE (c.sender_id = ? OR c.receiver_id = ?) AND c.is_active = TRUE
      ORDER BY last_message_at DESC
    `;
    
    const [conversations] = await db.execute(query, [userId, userId, userId]);
    console.log('📥 Conversations trouvées:', conversations.length);
    
    // Ajouter les informations du contact pour chaque conversation
    const conversationsWithContact = conversations.map(conv => {
      const isCurrentUserSender = conv.sender_id === userId;
      
      // Utiliser le nom complet en fallback si first_name/last_name sont vides
      let contactName;
      if (isCurrentUserSender) {
        contactName = conv.receiver_first_name && conv.receiver_last_name 
          ? `${conv.receiver_first_name} ${conv.receiver_last_name}`.trim()
          : conv.receiver_full_name || 'Utilisateur inconnu';
      } else {
        contactName = conv.sender_first_name && conv.sender_last_name 
          ? `${conv.sender_first_name} ${conv.sender_last_name}`.trim()
          : conv.sender_full_name || 'Utilisateur inconnu';
      }
      
      return {
        ...conv,
        contact_name: contactName,
        contact_id: isCurrentUserSender ? conv.receiver_id : conv.sender_id,
        unread_count: conv.unread_count || 0
      };
    });
    
    console.log('✅ Conversations avec contacts:', conversationsWithContact.length);
    res.json({ conversations: conversationsWithContact });
  } catch (error) {
    console.error('❌ Erreur lors de la récupération des conversations:', error);
    res.status(500).json({ error: 'Erreur serveur', details: error.message });
  }
});

// Obtenir les messages d'une conversation
router.get('/conversations/:conversationId/messages', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const conversationId = req.params.conversationId;
    
    // Vérifier que l'utilisateur fait partie de la conversation
    const [conversationCheck] = await db.execute(
      'SELECT * FROM conversations WHERE id = ? AND (sender_id = ? OR receiver_id = ?)',
      [conversationId, userId, userId]
    );
    
    if (conversationCheck.length === 0) {
      return res.status(403).json({ error: 'Accès non autorisé à cette conversation' });
    }
    
    // Récupérer les messages
    const query = `
      SELECT m.*, u.first_name, u.last_name 
      FROM messages m
      JOIN users u ON m.sender_id = u.id
      WHERE m.conversation_id = ?
      ORDER BY m.created_at ASC
    `;
    
    const [messages] = await db.execute(query, [conversationId]);
    
    // Marquer les messages comme lus
    await db.execute(
      'UPDATE messages SET is_read = TRUE WHERE conversation_id = ? AND sender_id != ?',
      [conversationId, userId]
    );
    
    res.json({ messages });
  } catch (error) {
    console.error('Erreur lors de la récupération des messages:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Créer une nouvelle conversation/message (pour postuler à une annonce)
router.post('/conversations', authMiddleware, checkPremiumAccess('messaging'), checkUsageLimit('messages'), async (req, res) => {
  const connection = await db.getConnection();
  
  try {
    await connection.beginTransaction();
    
    const senderId = req.user.id;
    const { receiverId, opportunityId, subject, content } = req.body;
    
    if (!receiverId || !content) {
      return res.status(400).json({ error: 'Destinataire et contenu requis' });
    }
    
    // Vérifier si une conversation existe déjà
    let conversationId;
    const [existingConv] = await connection.execute(
      'SELECT id FROM conversations WHERE opportunity_id = ? AND sender_id = ? AND receiver_id = ?',
      [opportunityId, senderId, receiverId]
    );
    
    if (existingConv.length > 0) {
      conversationId = existingConv[0].id;
    } else {
      // Créer une nouvelle conversation
      const [convResult] = await connection.execute(
        'INSERT INTO conversations (opportunity_id, sender_id, receiver_id, subject) VALUES (?, ?, ?, ?)',
        [opportunityId, senderId, receiverId, subject || 'Candidature']
      );
      conversationId = convResult.insertId;
    }
    
    // Ajouter le message
    const messageType = opportunityId ? 'application' : 'text';
    await connection.execute(
      'INSERT INTO messages (conversation_id, sender_id, content, message_type) VALUES (?, ?, ?, ?)',
      [conversationId, senderId, content, messageType]
    );
    
    // Incrémenter le compteur de messages
    await connection.execute(`
      UPDATE user_limits 
      SET messages_sent = messages_sent + 1 
      WHERE user_id = ?
    `, [senderId]);
    
    await connection.commit();
    
    res.json({ 
      success: true, 
      conversationId,
      message: 'Message envoyé avec succès' 
    });
  } catch (error) {
    await connection.rollback();
    console.error('Erreur lors de la création du message:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  } finally {
    connection.release();
  }
});

// Envoyer un message dans une conversation existante
router.post('/conversations/:conversationId/messages', authMiddleware, checkPremiumAccess('messaging'), checkUsageLimit('messages'), async (req, res) => {
  try {
    const userId = req.user.id;
    const conversationId = req.params.conversationId;
    const { content } = req.body;
    
    if (!content) {
      return res.status(400).json({ error: 'Contenu du message requis' });
    }
    
    // Vérifier que l'utilisateur fait partie de la conversation
    const [conversationCheck] = await db.execute(
      'SELECT * FROM conversations WHERE id = ? AND (sender_id = ? OR receiver_id = ?)',
      [conversationId, userId, userId]
    );
    
    if (conversationCheck.length === 0) {
      return res.status(403).json({ error: 'Accès non autorisé à cette conversation' });
    }
    
    // Ajouter le message
    const [result] = await db.execute(
      'INSERT INTO messages (conversation_id, sender_id, content) VALUES (?, ?, ?)',
      [conversationId, userId, content]
    );
    
    // Incrémenter le compteur de messages
    await db.execute(`
      UPDATE user_limits 
      SET messages_sent = messages_sent + 1 
      WHERE user_id = ?
    `, [userId]);
    
    res.json({ 
      success: true, 
      messageId: result.insertId,
      message: 'Message envoyé avec succès' 
    });
  } catch (error) {
    console.error('Erreur lors de l\'envoi du message:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Marquer une conversation comme lue
router.put('/conversations/:conversationId/read', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const conversationId = req.params.conversationId;
    
    await db.execute(
      'UPDATE messages SET is_read = TRUE WHERE conversation_id = ? AND sender_id != ?',
      [conversationId, userId]
    );
    
    res.json({ success: true, message: 'Messages marqués comme lus' });
  } catch (error) {
    console.error('Erreur lors du marquage des messages:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Obtenir le nombre de messages non lus
router.get('/unread-count', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    
    const [result] = await db.execute(`
      SELECT COUNT(*) as unread_count
      FROM messages m
      JOIN conversations c ON m.conversation_id = c.id
      WHERE (c.sender_id = ? OR c.receiver_id = ?) 
        AND m.sender_id != ? 
        AND m.is_read = FALSE
    `, [userId, userId, userId]);
    
    res.json({ unread_count: result[0].unread_count });
  } catch (error) {
    console.error('Erreur lors du comptage des messages non lus:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router; 