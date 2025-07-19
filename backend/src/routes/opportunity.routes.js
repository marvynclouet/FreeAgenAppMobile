const express = require('express');
const router = express.Router();
const db = require('../database/db');
const authMiddleware = require('../middleware/auth.middleware');

// Récupérer toutes les opportunités (depuis annonces)
router.get('/', authMiddleware, async (req, res) => {
  try {
    const [opportunities] = await db.execute(`
      SELECT a.*, u.name as user_name, u.email as user_email
      FROM annonces a
      JOIN users u ON a.user_id = u.id
      WHERE a.status = 'open'
      ORDER BY a.created_at DESC
    `);
    res.json(opportunities);
  } catch (error) {
    console.error('Erreur lors de la récupération des opportunités:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Obtenir une opportunité spécifique
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const [opportunities] = await db.execute(`
      SELECT o.*, t.name as team_name, t.city as team_city
      FROM opportunities o
      JOIN teams t ON o.team_id = t.id
      WHERE o.id = ?
    `, [req.params.id]);
    
    if (opportunities.length === 0) {
      return res.status(404).json({ message: 'Opportunité non trouvée' });
    }

    res.json(opportunities[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération de l\'opportunité:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Créer une nouvelle opportunité
router.post('/', authMiddleware, async (req, res) => {
  try {
    console.log('Requête reçue pour créer une opportunité:', req.body);
    const { title, description, type, requirements, salary_range, location, team_id } = req.body;
    const userId = req.user.id;

    console.log('Données extraites:', {
      title,
      description,
      type,
      requirements,
      salary_range,
      location,
      team_id,
      userId
    });

    // Vérifier si l'utilisateur est un club
    const [user] = await db.execute(
      'SELECT profile_type FROM users WHERE id = ?',
      [userId]
    );

    console.log('Type de profil de l\'utilisateur:', user[0]?.profile_type);

    if (user[0].profile_type !== 'club') {
      console.log('Erreur: L\'utilisateur n\'est pas un club');
      return res.status(403).json({ message: 'Seuls les clubs peuvent créer des opportunités' });
    }

    // Vérifier si l'équipe existe
    const [team] = await db.execute(
      'SELECT id FROM teams WHERE id = ?',
      [team_id]
    );

    console.log('Équipe trouvée:', team[0]);

    if (team.length === 0) {
      console.log('Erreur: Équipe non trouvée');
      return res.status(404).json({ message: 'Équipe non trouvée' });
    }

    // Vérifier que le type est valide
    const validTypes = ['recrutement', 'coaching', 'consultation'];
    if (!validTypes.includes(type)) {
      console.log('Erreur: Type d\'opportunité invalide:', type);
      return res.status(400).json({ 
        message: 'Type d\'opportunité invalide. Les types valides sont: ' + validTypes.join(', ')
      });
    }

    console.log('Tentative d\'insertion dans la base de données');
    const [result] = await db.execute(
      `INSERT INTO opportunities (team_id, title, description, type, requirements, salary_range, location)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [team_id, title, description, type, requirements, salary_range, location]
    );

    console.log('Résultat de l\'insertion:', result);

    const [newOpportunity] = await db.execute(
      `SELECT o.*, t.name as team_name, t.city as team_city
       FROM opportunities o
       JOIN teams t ON o.team_id = t.id
       WHERE o.id = ?`,
      [result.insertId]
    );

    console.log('Nouvelle opportunité créée:', newOpportunity[0]);

    res.status(201).json(newOpportunity[0]);
  } catch (error) {
    console.error('Erreur détaillée lors de la création de l\'opportunité:', error);
    res.status(500).json({ 
      message: 'Erreur serveur',
      details: error.message,
      code: error.code,
      sqlMessage: error.sqlMessage
    });
  }
});

// Mettre à jour une opportunité
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const { title, description, team_id, position, requirements, salary_range, location } = req.body;

    await db.execute(
      `UPDATE opportunities 
      SET title = ?, description = ?, team_id = ?, position = ?, 
          requirements = ?, salary_range = ?, location = ?
      WHERE id = ?`,
      [title, description, team_id, position, requirements, salary_range, location, req.params.id]
    );

    res.json({ message: 'Opportunité mise à jour avec succès' });
  } catch (error) {
    console.error('Erreur lors de la mise à jour de l\'opportunité:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Supprimer une opportunité
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    await db.execute('DELETE FROM opportunities WHERE id = ?', [req.params.id]);
    res.json({ message: 'Opportunité supprimée avec succès' });
  } catch (error) {
    console.error('Erreur lors de la suppression de l\'opportunité:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Postuler à une opportunité (via messagerie)
router.post('/:id/apply', authMiddleware, async (req, res) => {
  try {
    const { message } = req.body;
    const userId = req.user.id;
    const annonceId = req.params.id;

    console.log('Tentative de candidature:', { userId, annonceId, message });

    // Vérifier que l'annonce existe
    const [annonce] = await db.execute(
      'SELECT * FROM annonces WHERE id = ? AND status = "open"',
      [annonceId]
    );

    if (annonce.length === 0) {
      return res.status(404).json({ message: 'Annonce non trouvée ou fermée' });
    }

    const receiverId = annonce[0].user_id;

    // Vérifier si une conversation existe déjà
    let conversationId;
    const [existingConv] = await db.execute(
      'SELECT id FROM conversations WHERE opportunity_id = ? AND sender_id = ? AND receiver_id = ?',
      [annonceId, userId, receiverId]
    );

    if (existingConv.length > 0) {
      conversationId = existingConv[0].id;
    } else {
      // Créer une nouvelle conversation
      const [convResult] = await db.execute(
        'INSERT INTO conversations (opportunity_id, sender_id, receiver_id, subject) VALUES (?, ?, ?, ?)',
        [annonceId, userId, receiverId, `Candidature: ${annonce[0].title}`]
      );
      conversationId = convResult.insertId;
    }

    // Ajouter le message
    await db.execute(
      'INSERT INTO messages (conversation_id, sender_id, content, message_type) VALUES (?, ?, ?, ?)',
      [conversationId, userId, message, 'application']
    );

    res.json({ message: 'Candidature envoyée avec succès' });
  } catch (error) {
    console.error('Erreur lors de l\'envoi de la candidature:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Obtenir les candidatures pour une opportunité (pour les clubs)
router.get('/:id/applications', authMiddleware, async (req, res) => {
  try {
    const [opportunity] = await db.execute(
      'SELECT * FROM opportunities WHERE id = ?',
      [req.params.id]
    );

    if (opportunity.length === 0) {
      return res.status(404).json({ message: 'Opportunité non trouvée' });
    }

    // Vérifier que l'utilisateur est le propriétaire de l'opportunité
    const [user] = await db.execute(
      'SELECT profile_type FROM users WHERE id = ?',
      [req.user.id]
    );

    if (user[0].profile_type !== 'club') {
      return res.status(403).json({ message: 'Accès non autorisé' });
    }

    const [applications] = await db.execute(`
      SELECT c.*, u.name as applicant_name, u.email as applicant_email
      FROM conversations c
      JOIN users u ON c.sender_id = u.id
      WHERE c.opportunity_id = ?
      ORDER BY c.created_at DESC
    `, [req.params.id]);

    res.json(applications);
  } catch (error) {
    console.error('Erreur lors de la récupération des candidatures:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router; 