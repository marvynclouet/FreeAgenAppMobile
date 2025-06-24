const express = require('express');
const router = express.Router();
const db = require('../config/db.config');
const verifyToken = require('../middleware/auth.middleware');

// Obtenir toutes les équipes
router.get('/', async (req, res) => {
  try {
    const [teams] = await db.query('SELECT * FROM teams');
    res.json(teams);
  } catch (error) {
    console.error('Erreur lors de la récupération des équipes:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Obtenir une équipe spécifique
router.get('/:id', async (req, res) => {
  try {
    const [teams] = await db.query('SELECT * FROM teams WHERE id = ?', [req.params.id]);
    
    if (teams.length === 0) {
      return res.status(404).json({ message: 'Équipe non trouvée' });
    }

    res.json(teams[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération de l\'équipe:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Créer une nouvelle équipe
router.post('/', verifyToken, async (req, res) => {
  try {
    const { name, city, description, logo_url } = req.body;

    const [result] = await db.query(
      'INSERT INTO teams (name, city, description, logo_url) VALUES (?, ?, ?, ?)',
      [name, city, description, logo_url]
    );

    res.status(201).json({
      message: 'Équipe créée avec succès',
      teamId: result.insertId
    });
  } catch (error) {
    console.error('Erreur lors de la création de l\'équipe:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Mettre à jour une équipe
router.put('/:id', verifyToken, async (req, res) => {
  try {
    const { name, city, description, logo_url } = req.body;

    await db.query(
      'UPDATE teams SET name = ?, city = ?, description = ?, logo_url = ? WHERE id = ?',
      [name, city, description, logo_url, req.params.id]
    );

    res.json({ message: 'Équipe mise à jour avec succès' });
  } catch (error) {
    console.error('Erreur lors de la mise à jour de l\'équipe:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Supprimer une équipe
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    await db.query('DELETE FROM teams WHERE id = ?', [req.params.id]);
    res.json({ message: 'Équipe supprimée avec succès' });
  } catch (error) {
    console.error('Erreur lors de la suppression de l\'équipe:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router; 