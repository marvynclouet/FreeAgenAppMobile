const express = require('express');
const router = express.Router();
const db = require('../config/db.config');
const verifyToken = require('../middleware/auth.middleware');

// Récupérer tous les joueurs avec filtres
router.get('/', verifyToken, async (req, res) => {
  try {
    // Récupérer les paramètres de filtre
    const { championship_level, gender, position, passport_type } = req.query;
    
    let query = `
      SELECT 
        pp.id,
        pp.user_id,
        pp.age,
        pp.height,
        pp.weight,
        pp.position,
        pp.experience_years,
        pp.level,
        pp.championship_level,
        pp.passport_type,
        pp.achievements,
        pp.stats,
        pp.video_url,
        pp.bio,
        pp.created_at,
        pp.updated_at,
        u.name,
        u.email,
        u.gender,
        u.nationality,
        u.profile_image_url
      FROM player_profiles pp
      JOIN users u ON pp.user_id = u.id
      WHERE 1=1
    `;
    
    const queryParams = [];
    
    // Ajouter les filtres si fournis
    if (championship_level && championship_level !== 'all') {
      query += ' AND pp.championship_level = ?';
      queryParams.push(championship_level);
    }
    
    if (gender && gender !== 'all') {
      query += ' AND u.gender = ?';
      queryParams.push(gender);
    }
    
    if (position && position !== 'all') {
      query += ' AND pp.position = ?';
      queryParams.push(position);
    }
    
    if (passport_type && passport_type !== 'all') {
      query += ' AND pp.passport_type = ?';
      queryParams.push(passport_type);
    }
    
    query += ' ORDER BY u.name';

    const [players] = await db.query(query, queryParams);
    console.log('Données des joueurs récupérées avec filtres:', {
      filtres: { championship_level, gender, position, passport_type },
      nombre_resultats: players.length
    });
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
        pp.championship_level,
        pp.passport_type,
        pp.achievements,
        pp.stats,
        pp.video_url,
        pp.bio,
        pp.created_at,
        pp.updated_at,
        u.name,
        u.email,
        u.gender,
        u.nationality,
        u.profile_image_url
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