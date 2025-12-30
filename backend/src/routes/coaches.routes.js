const express = require('express');
const router = express.Router();
const db = require('../config/db.config');
const authMiddleware = require('../middleware/auth.middleware');

// Récupérer tous les coachs
router.get('/', authMiddleware, async (req, res) => {
  try {
    const [coaches] = await db.query(`
      SELECT 
        cp.*,
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
      FROM coach_pro_profiles cp
      JOIN users u ON cp.user_id = u.id
      WHERE u.profile_type = 'coach_pro'
      UNION ALL
      SELECT 
        cb.*,
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
      FROM coach_basket_profiles cb
      JOIN users u ON cb.user_id = u.id
      WHERE u.profile_type = 'coach_basket'
      ORDER BY name
    `);
    res.json(coaches);
  } catch (error) {
    console.error('Erreur lors de la récupération des coachs:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Récupérer un coach spécifique
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const [coaches] = await db.query(`
      SELECT 
        cp.*,
        u.name,
        u.email,
        u.profile_image_url,
        'coach_pro' as type
      FROM coach_pro_profiles cp
      JOIN users u ON cp.user_id = u.id
      WHERE cp.id = ? AND u.profile_type = 'coach_pro'
      UNION ALL
      SELECT 
        cb.*,
        u.name,
        u.email,
        u.profile_image_url,
        'coach_basket' as type
      FROM coach_basket_profiles cb
      JOIN users u ON cb.user_id = u.id
      WHERE cb.id = ? AND u.profile_type = 'coach_basket'
    `, [req.params.id, req.params.id]);

    if (coaches.length === 0) {
      return res.status(404).json({ message: 'Coach non trouvé' });
    }

    res.json(coaches[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération du coach:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router; 