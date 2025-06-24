const express = require('express');
const router = express.Router();
const db = require('../config/db.config');
const authMiddleware = require('../middleware/auth.middleware');

// Récupérer toutes les annonces
router.get('/', authMiddleware, async (req, res) => {
  try {
    const [annonces] = await db.query(`
      SELECT a.*, u.name as user_name, u.profile_type
      FROM annonces a
      JOIN users u ON a.user_id = u.id
      WHERE a.status = 'open'
      ORDER BY a.created_at DESC
    `);
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
router.post('/', authMiddleware, async (req, res) => {
  try {
    console.log('Requête reçue pour créer une annonce:', req.body);
    const { title, description, type, requirements, salary_range, location } = req.body;
    const userId = req.user.id;

    console.log('Données extraites:', {
      title,
      description,
      type,
      requirements,
      salary_range,
      location,
      userId
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
      `INSERT INTO annonces (user_id, title, description, type, requirements, salary_range, location)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [userId, title, description, type, requirements, salary_range, location]
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
router.post('/:id/apply', authMiddleware, async (req, res) => {
  try {
    const { message } = req.body;
    const userId = req.user.id;
    const annonceId = req.params.id;

    // Vérifier si l'utilisateur a déjà postulé
    const [existing] = await db.query(
      'SELECT * FROM applications WHERE user_id = ? AND opportunity_id = ?',
      [userId, annonceId]
    );

    if (existing.length > 0) {
      return res.status(400).json({ message: 'Vous avez déjà postulé à cette annonce' });
    }

    // Créer la candidature
    await db.query(
      'INSERT INTO applications (user_id, opportunity_id, message) VALUES (?, ?, ?)',
      [userId, annonceId, message]
    );

    res.status(201).json({ message: 'Candidature envoyée avec succès' });
  } catch (error) {
    console.error('Erreur lors de la candidature:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router; 