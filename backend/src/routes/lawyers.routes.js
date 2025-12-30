const express = require('express');
const router = express.Router();
const db = require('../config/db.config');
const authMiddleware = require('../middleware/auth.middleware');

// Récupérer tous les avocats/juristes
router.get('/', authMiddleware, async (req, res) => {
  try {
    const [lawyers] = await db.query(`
      SELECT 
        jp.*,
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
      FROM juriste_profiles jp
      JOIN users u ON jp.user_id = u.id
      WHERE u.profile_type = 'juriste'
      ORDER BY u.name
    `);
    res.json(lawyers);
  } catch (error) {
    console.error('Erreur lors de la récupération des avocats:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Récupérer un avocat spécifique
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const [lawyers] = await db.query(`
      SELECT 
        jp.*,
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
      FROM juriste_profiles jp
      JOIN users u ON jp.user_id = u.id
      WHERE jp.id = ? AND u.profile_type = 'juriste'
    `, [req.params.id]);

    if (lawyers.length === 0) {
      return res.status(404).json({ message: 'Avocat non trouvé' });
    }

    res.json(lawyers[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération de l\'avocat:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router;
