const express = require('express');
const router = express.Router();
const db = require('../config/db.config');
const authMiddleware = require('../middleware/auth.middleware');

// Middleware pour vérifier le type de profil
const checkProfileType = (allowedTypes) => {
  return (req, res, next) => {
    if (!allowedTypes.includes(req.user.profile_type)) {
      return res.status(403).json({ message: 'Accès non autorisé' });
    }
    next();
  };
};

// Récupérer tous les clubs
router.get('/', authMiddleware, async (req, res) => {
  try {
    const [clubs] = await db.query(`
      SELECT cp.*, u.name as club_name, u.email, u.profile_image_url
      FROM club_profiles cp
      JOIN users u ON cp.user_id = u.id
      WHERE u.profile_type = 'club'
    `);
    res.json(clubs);
  } catch (error) {
    console.error('Erreur lors de la récupération des clubs:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Récupérer un club spécifique
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const [clubs] = await db.query(`
      SELECT cp.*, u.name as club_name, u.email, u.profile_image_url
      FROM club_profiles cp
      JOIN users u ON cp.user_id = u.id
      WHERE cp.id = ? AND u.profile_type = 'club'
    `, [req.params.id]);

    if (clubs.length === 0) {
      return res.status(404).json({ message: 'Club non trouvé' });
    }

    res.json(clubs[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération du club:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Mettre à jour un profil club
router.put('/profile', authMiddleware, checkProfileType(['club']), async (req, res) => {
  try {
    const { club_name, level, location, description } = req.body;
    const userId = req.user.id;

    // Vérifier si le profil existe déjà
    const [existingProfile] = await db.query(
      'SELECT * FROM club_profiles WHERE user_id = ?',
      [userId]
    );

    if (existingProfile.length > 0) {
      // Mettre à jour le profil existant
      await db.query(
        `UPDATE club_profiles 
         SET club_name = ?, level = ?, location = ?, description = ?
         WHERE user_id = ?`,
        [club_name, level, location, description, userId]
      );
    } else {
      // Créer un nouveau profil
      await db.query(
        `INSERT INTO club_profiles (user_id, club_name, level, location, description)
         VALUES (?, ?, ?, ?, ?)`,
        [userId, club_name, level, location, description]
      );
    }

    res.json({ message: 'Profil club mis à jour avec succès' });
  } catch (error) {
    console.error('Erreur lors de la mise à jour du profil club:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router; 