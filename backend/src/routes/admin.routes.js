const express = require('express');
const router = express.Router();
const db = require('../database/db');
const authMiddleware = require('../middleware/auth.middleware');

// Route de base pour l'admin
router.get('/', authMiddleware, async (req, res) => {
  try {
    res.json({ message: 'Admin panel accessible' });
  } catch (error) {
    console.error('Erreur admin:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router; 