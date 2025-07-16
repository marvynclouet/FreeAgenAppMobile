const express = require('express');
const router = express.Router();
const db = require('../config/db.config');
const authMiddleware = require('../middleware/auth.middleware');
const { checkPremiumAccess, checkUsageLimit, incrementUsage } = require('../middleware/premium.middleware');

// Récupérer toutes les annonces filtrées par profil utilisateur
router.get('/', authMiddleware, async (req, res) => {
  try {
    const userProfileType = req.user.profile_type;
    let targetProfile = 'player'; // Par défaut
    
    // Déterminer le type d'annonces à afficher selon le profil utilisateur
    if (userProfileType === 'handibasket') {
      targetProfile = 'handibasket';
    }
    
    console.log(`Récupération des annonces pour profil: ${userProfileType}, target: ${targetProfile}`);
    
    const [annonces] = await db.query(`
      SELECT a.*, u.name as user_name, u.profile_type
      FROM annonces a
      JOIN users u ON a.user_id = u.id
      WHERE a.status = 'open' 
        AND (a.target_profile = ? OR a.target_profile = 'all')
      ORDER BY a.created_at DESC
    `, [targetProfile]);
    
    console.log(`${annonces.length} annonces trouvées pour ${targetProfile}`);
    res.json(annonces);
  } catch (error) {
    console.error('Erreur lors de la récupération des annonces:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Obtenir une annonce spécifique
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const [annonces] = await db.query(`
      SELECT a.*, u.name as user_name, u.profile_type
      FROM annonces a
      JOIN users u ON a.user_id = u.id
      WHERE a.id = ?
    `, [req.params.id]);
    
    if (annonces.length === 0) {
      return res.status(404).json({ message: 'Annonce non trouvée' });
    }

    res.json(annonces[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération de l\'annonce:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Créer une nouvelle annonce
router.post('/', authMiddleware, checkPremiumAccess('post_opportunities'), checkUsageLimit('opportunities'), async (req, res) => {
  try {
    console.log('Requête reçue pour créer une annonce:', req.body);
    const { title, description, type, requirements, salary_range, location } = req.body;
    const userId = req.user.id;
    const userProfileType = req.user.profile_type;

    // Déterminer le target_profile selon le profil de l'utilisateur qui crée l'annonce
    let targetProfile = 'player'; // Par défaut
    if (userProfileType === 'club' && (title.toLowerCase().includes('handibasket') || description.toLowerCase().includes('handibasket'))) {
      targetProfile = 'handibasket';
    } else if (userProfileType === 'handibasket') {
      targetProfile = 'handibasket';
    }

    console.log('Données extraites:', {
      title,
      description,
      type,
      requirements,
      salary_range,
      location,
      userId,
      userProfileType,
      targetProfile
    });

    // Vérifier que le type est valide
    const validTypes = ['recrutement', 'coaching', 'consultation'];
    if (!validTypes.includes(type)) {
      console.log('Erreur: Type d\'annonce invalide:', type);
      return res.status(400).json({ 
        message: 'Type d\'annonce invalide. Les types valides sont: ' + validTypes.join(', ')
      });
    }

    console.log('Tentative d\'insertion dans la base de données');
    const [result] = await db.query(
      `INSERT INTO annonces (user_id, title, description, type, requirements, salary_range, location, target_profile)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [userId, title, description, type, requirements, salary_range, location, targetProfile]
    );

    console.log('Résultat de l\'insertion:', result);

    const [newAnnonce] = await db.query(
      `SELECT a.*, u.name as user_name, u.profile_type
       FROM annonces a
       JOIN users u ON a.user_id = u.id
       WHERE a.id = ?`,
      [result.insertId]
    );

    console.log('Nouvelle annonce créée:', newAnnonce[0]);

    // Incrémenter le compteur d'opportunités
    await db.query(`
      UPDATE user_limits 
      SET opportunities_posted = opportunities_posted + 1 
      WHERE user_id = ?
    `, [userId]);

    res.status(201).json(newAnnonce[0]);
  } catch (error) {
    console.error('Erreur détaillée lors de la création de l\'annonce:', error);
    res.status(500).json({ 
      message: 'Erreur serveur',
      details: error.message,
      code: error.code,
      sqlMessage: error.sqlMessage
    });
  }
});

// Fermer une annonce
router.put('/:id/close', authMiddleware, async (req, res) => {
  try {
    const [annonce] = await db.query(
      'SELECT * FROM annonces WHERE id = ?',
      [req.params.id]
    );

    if (annonce.length === 0) {
      return res.status(404).json({ message: 'Annonce non trouvée' });
    }

    // Vérifier si l'utilisateur est le propriétaire de l'annonce
    if (annonce[0].user_id !== req.user.id) {
      return res.status(403).json({ message: 'Non autorisé' });
    }

    await db.query(
      'UPDATE annonces SET status = ? WHERE id = ?',
      ['closed', req.params.id]
    );

    res.json({ message: 'Annonce fermée avec succès' });
  } catch (error) {
    console.error('Erreur lors de la fermeture de l\'annonce:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Postuler à une annonce
router.post('/:id/apply', authMiddleware, checkUsageLimit('applications'), async (req, res) => {
  const connection = await db.getConnection();
  
  try {
    await connection.beginTransaction();
    
    const { message } = req.body;
    const userId = req.user.id;
    const annonceId = req.params.id;

    // Récupérer l'annonce et son auteur
    const [annonce] = await connection.query(
      'SELECT * FROM annonces WHERE id = ?',
      [annonceId]
    );

    if (annonce.length === 0) {
      return res.status(404).json({ message: 'Annonce non trouvée' });
    }

    const receiverId = annonce[0].user_id;

    // Vérifier que l'utilisateur ne postule pas à sa propre annonce
    if (userId === receiverId) {
      return res.status(400).json({ message: 'Vous ne pouvez pas postuler à votre propre annonce' });
    }

    // Vérifier si l'utilisateur a déjà postulé (chercher une conversation existante)
    const [existingConv] = await connection.query(
      'SELECT * FROM conversations WHERE opportunity_id = ? AND sender_id = ? AND receiver_id = ?',
      [annonceId, userId, receiverId]
    );

    if (existingConv.length > 0) {
      return res.status(400).json({ message: 'Vous avez déjà postulé à cette annonce' });
    }

    // Créer une conversation
    const [convResult] = await connection.query(
      'INSERT INTO conversations (opportunity_id, sender_id, receiver_id, subject) VALUES (?, ?, ?, ?)',
      [annonceId, userId, receiverId, `Candidature: ${annonce[0].title}`]
    );
    const conversationId = convResult.insertId;

    // Créer le message de candidature
    await connection.query(
      'INSERT INTO messages (conversation_id, sender_id, content, message_type) VALUES (?, ?, ?, ?)',
      [conversationId, userId, message, 'application']
    );

    // Créer aussi l'enregistrement dans applications pour compatibilité
    await connection.query(
      'INSERT INTO applications (user_id, opportunity_id, message) VALUES (?, ?, ?)',
      [userId, annonceId, message]
    );

    // Incrémenter le compteur d'applications
    await connection.query(`
      UPDATE user_limits 
      SET applications_count = applications_count + 1 
      WHERE user_id = ?
    `, [userId]);

    await connection.commit();

    res.status(201).json({ 
      message: 'Candidature envoyée avec succès',
      conversationId: conversationId
    });
  } catch (error) {
    await connection.rollback();
    console.error('Erreur lors de la candidature:', error);
    res.status(500).json({ message: 'Erreur serveur', details: error.message });
  } finally {
    connection.release();
  }
});

module.exports = router; 