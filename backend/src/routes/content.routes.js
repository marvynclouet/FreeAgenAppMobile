const express = require('express');
const router = express.Router();
const mysql = require('mysql2/promise');
const authMiddleware = require('../middleware/auth.middleware');
const dbConfig = require('../config/db.config');

// Récupérer le fil d'actualités (posts + opportunités)
router.get('/feed', authMiddleware, async (req, res) => {
  let connection;
  try {
    connection = await dbConfig.getConnection();
    
    // Récupérer les posts
    const [posts] = await connection.execute(`
      SELECT 
        p.id,
        'post' as type,
        p.content,
        p.image_urls,
        p.event_date,
        p.event_location,
        p.created_at,
        p.likes_count,
        p.comments_count,
        u.name as author_name,
        u.profile_type as author_type,
        u.profile_image_url as author_avatar
      FROM posts p
      JOIN users u ON p.user_id = u.id
      ORDER BY p.created_at DESC
      LIMIT 20
    `);

    // Récupérer les opportunités
    const [opportunities] = await connection.execute(`
      SELECT 
        a.id,
        'opportunity' as type,
        a.title,
        a.description as content,
        NULL as image_url,
        a.location,
        a.salary_range,
        a.requirements,
        a.created_at,
        u.name as author_name,
        u.profile_type as author_type,
        u.profile_image_url as author_avatar
      FROM annonces a
      JOIN users u ON a.user_id = u.id
      WHERE a.status = 'open'
      ORDER BY a.created_at DESC
      LIMIT 10
    `);

    // Récupérer les événements
    const [events] = await connection.execute(`
      SELECT 
        e.id,
        'event' as type,
        e.title,
        e.description as content,
        e.image_url,
        e.event_date,
        e.event_time,
        e.event_location,
        e.created_at,
        u.name as author_name,
        u.profile_type as author_type,
        u.profile_image_url as author_avatar
      FROM events e
      JOIN users u ON e.user_id = u.id
      WHERE e.event_date >= CURDATE()
      ORDER BY e.event_date ASC
      LIMIT 10
    `);

    // Combiner et trier par date
    const feed = [...posts, ...opportunities, ...events]
      .sort((a, b) => new Date(b.created_at) - new Date(a.created_at));

    res.json({ feed });
  } catch (error) {
    console.error('Erreur lors de la récupération du fil d\'actualités:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  } finally {
    if (connection) {
      connection.release();
    }
  }
});

// Créer un nouveau post
router.post('/posts', authMiddleware, async (req, res) => {
  let connection;
  try {
    const { content, imageUrls, eventDate, eventLocation, eventTime } = req.body;
    const userId = req.user.id;

    connection = await dbConfig.getConnection();
    
    // Vérifier le statut d'abonnement de l'utilisateur
    const [subscriptionResult] = await connection.execute(`
      SELECT subscription_type FROM users WHERE id = ?
    `, [userId]);

    if (subscriptionResult.length === 0) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    const subscriptionType = subscriptionResult[0].subscription_type;
    if (!subscriptionType || subscriptionType === 'free') {
      return res.status(403).json({ 
        message: 'Fonctionnalité réservée aux abonnés premium',
        requiresPremium: true 
      });
    }
    
    const [result] = await connection.execute(`
      INSERT INTO posts (user_id, content, image_urls, event_date, event_time, event_location, created_at)
      VALUES (?, ?, ?, ?, ?, ?, NOW())
    `, [userId, content, JSON.stringify(imageUrls || []), eventDate, eventTime, eventLocation]);

    res.status(201).json({ 
      message: 'Post créé avec succès',
      postId: result.insertId 
    });
  } catch (error) {
    console.error('Erreur lors de la création du post:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  } finally {
    if (connection) {
      connection.release();
    }
  }
});

// Liker/unliker un post
router.post('/posts/:postId/like', authMiddleware, async (req, res) => {
  let connection;
  try {
    const { postId } = req.params;
    const userId = req.user.id;

    connection = await dbConfig.getConnection();
    
    // Vérifier si l'utilisateur a déjà liké
    const [existingLike] = await connection.execute(`
      SELECT id FROM post_likes WHERE post_id = ? AND user_id = ?
    `, [postId, userId]);

    if (existingLike.length > 0) {
      // Unliker
      await connection.execute(`
        DELETE FROM post_likes WHERE post_id = ? AND user_id = ?
      `, [postId, userId]);
      
      await connection.execute(`
        UPDATE posts SET likes_count = likes_count - 1 WHERE id = ?
      `, [postId]);
    } else {
      // Liker
      await connection.execute(`
        INSERT INTO post_likes (post_id, user_id, created_at) VALUES (?, ?, NOW())
      `, [postId, userId]);
      
      await connection.execute(`
        UPDATE posts SET likes_count = likes_count + 1 WHERE id = ?
      `, [postId]);
    }

    res.json({ message: 'Like mis à jour' });
  } catch (error) {
    console.error('Erreur lors du like:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  } finally {
    if (connection) {
      connection.release();
    }
  }
});

// Commenter un post
router.post('/posts/:postId/comments', authMiddleware, async (req, res) => {
  let connection;
  try {
    const { postId } = req.params;
    const { content } = req.body;
    const userId = req.user.id;

    connection = await dbConfig.getConnection();
    
    const [result] = await connection.execute(`
      INSERT INTO post_comments (post_id, user_id, content, created_at)
      VALUES (?, ?, ?, NOW())
    `, [postId, userId, content]);

    await connection.execute(`
      UPDATE posts SET comments_count = comments_count + 1 WHERE id = ?
    `, [postId]);

    res.status(201).json({ 
      message: 'Commentaire ajouté',
      commentId: result.insertId 
    });
  } catch (error) {
    console.error('Erreur lors de l\'ajout du commentaire:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  } finally {
    if (connection) {
      connection.release();
    }
  }
});

// Récupérer les commentaires d'un post
router.get('/posts/:postId/comments', authMiddleware, async (req, res) => {
  let connection;
  try {
    const { postId } = req.params;

    connection = await dbConfig.getConnection();
    
    const [comments] = await connection.execute(`
      SELECT 
        pc.id,
        pc.content,
        pc.created_at,
        u.name as author_name,
        u.profile_image_url as author_avatar
      FROM post_comments pc
      JOIN users u ON pc.user_id = u.id
      WHERE pc.post_id = ?
      ORDER BY pc.created_at DESC
    `, [postId]);

    res.json({ comments });
  } catch (error) {
    console.error('Erreur lors de la récupération des commentaires:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  } finally {
    if (connection) {
      connection.release();
    }
  }
});


// Route racine pour tester
router.get('/', (req, res) => {
  res.json({ message: 'content API is working' });
});


module.exports = router; 