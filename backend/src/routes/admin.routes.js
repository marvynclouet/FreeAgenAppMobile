const express = require('express');
const router = express.Router();
const pool = require('../config/db.config');

// Route temporaire pour exécuter du SQL (à supprimer en production)
router.post('/execute-sql', async (req, res) => {
  try {
    const { sql } = req.body;
    
    if (!sql) {
      return res.status(400).json({ message: 'SQL requis' });
    }

    // Exécuter la requête SQL
    const [result] = await pool.query(sql);
    
    res.json({ 
      message: 'SQL exécuté avec succès',
      result: result
    });
  } catch (error) {
    console.error('Erreur lors de l\'exécution SQL:', error);
    res.status(500).json({ 
      message: 'Erreur serveur',
      error: error.message
    });
  }
});

module.exports = router;