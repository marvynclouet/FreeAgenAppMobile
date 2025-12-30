const express = require('express');
const router = express.Router();
const db = require('../config/db.config');
const authMiddleware = require('../middleware/auth.middleware');

// Récupérer toutes les diététiciennes
router.get('/', authMiddleware, async (req, res) => {
  try {
    const [dietitians] = await db.query(`
      SELECT 
        dp.*,
        u.id as user_id,
        u.name,
        u.email,
        u.profile_type,
        u.profile_image_url,
        u.gender,
        u.nationality,
        u.created_at,
        u.is_premium,
        u.subscription_type
      FROM dieteticienne_profiles dp
      JOIN users u ON dp.user_id = u.id
      WHERE u.profile_type = 'dieteticienne'
      ORDER BY u.name
    `);
    res.json(dietitians);
  } catch (error) {
    console.error('Erreur lors de la récupération des diététiciennes:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Récupérer une diététicienne spécifique
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const [dietitians] = await db.query(`
      SELECT 
        dp.*,
        u.id as user_id,
        u.name,
        u.email,
        u.profile_type,
        u.profile_image_url,
        u.gender,
        u.nationality,
        u.created_at,
        u.is_premium,
        u.subscription_type
      FROM dieteticienne_profiles dp
      JOIN users u ON dp.user_id = u.id
      WHERE dp.id = ? AND u.profile_type = 'dieteticienne'
    `, [req.params.id]);

    if (dietitians.length === 0) {
      return res.status(404).json({ message: 'Diététicienne non trouvée' });
    }

    res.json(dietitians[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération de la diététicienne:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router;
