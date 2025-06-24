const express = require('express');
const router = express.Router();
const db = require('../config/db.config');
const verifyToken = require('../middleware/auth.middleware');

// Récupérer tous les joueurs
router.get('/', verifyToken, async (req, res) => {
  try {
    const query = `
      SELECT 
        pp.id,
        pp.user_id,
        pp.age,
        pp.height,
        pp.weight,
        pp.position,
        pp.experience_years,
        pp.level,
        pp.achievements,
        pp.stats,
        pp.video_url,
        pp.bio,
        pp.created_at,
        pp.updated_at,
        u.name,
        u.email
      FROM player_profiles pp
      JOIN users u ON pp.user_id = u.id
      ORDER BY u.name
    `;

    const [players] = await db.query(query);
    console.log('Données des joueurs récupérées:', JSON.stringify(players, null, 2));
    res.json(players);
  } catch (error) {
    console.error('Erreur lors de la récupération des joueurs:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Récupérer un joueur spécifique
router.get('/:id', verifyToken, async (req, res) => {
  try {
    const query = `
      SELECT 
        pp.id,
        pp.user_id,
        pp.age,
        pp.height,
        pp.weight,
        pp.position,
        pp.experience_years,
        pp.level,
        pp.achievements,
        pp.stats,
        pp.video_url,
        pp.bio,
        pp.created_at,
        pp.updated_at,
        u.name,
        u.email
      FROM player_profiles pp
      JOIN users u ON pp.user_id = u.id
      WHERE pp.id = ?
    `;

    const [players] = await db.query(query, [req.params.id]);
    console.log('Données du joueur récupérées:', JSON.stringify(players[0], null, 2));
    
    if (players.length === 0) {
      return res.status(404).json({ message: 'Joueur non trouvé' });
    }

    res.json(players[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération du joueur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router; 