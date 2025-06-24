const express = require('express');
const router = express.Router();
const db = require('../config/db.config');
const verifyToken = require('../middleware/auth.middleware');

// Obtenir le profil de l'utilisateur connecté
router.get('/profile', verifyToken, async (req, res) => {
  try {
    const [users] = await db.query(
      'SELECT id, name, email, profile_type, created_at FROM users WHERE id = ?',
      [req.user.id]
    );

    if (users.length === 0) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    res.json(users[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération du profil:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Mettre à jour le profil
router.put('/profile', verifyToken, async (req, res) => {
  try {
    const { name, email } = req.body;

    // Vérifier si l'email est déjà utilisé par un autre utilisateur
    if (email) {
      const [existingUsers] = await db.query(
        'SELECT id FROM users WHERE email = ? AND id != ?',
        [email, req.user.id]
      );

      if (existingUsers.length > 0) {
        return res.status(400).json({ message: 'Cet email est déjà utilisé' });
      }
    }

    // Mettre à jour le profil
    await db.query(
      'UPDATE users SET name = ?, email = ? WHERE id = ?',
      [name, email, req.user.id]
    );

    res.json({ message: 'Profil mis à jour avec succès' });
  } catch (error) {
    console.error('Erreur lors de la mise à jour du profil:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Obtenir la liste des utilisateurs (pour les administrateurs)
router.get('/', verifyToken, async (req, res) => {
  try {
    const [users] = await db.query(
      'SELECT id, name, email, profile_type, created_at FROM users'
    );
    res.json(users);
  } catch (error) {
    console.error('Erreur lors de la récupération des utilisateurs:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Recherche d'utilisateurs par type et/ou nom
router.get('/search', verifyToken, async (req, res) => {
  const { type, query } = req.query;
  let sql = 'SELECT id, name, email, profile_type, created_at FROM users WHERE 1=1';
  const params = [];

  if (type) {
    sql += ' AND profile_type = ?';
    params.push(type);
  }
  if (query) {
    sql += ' AND name LIKE ?';
    params.push(`%${query}%`);
  }

  try {
    const [users] = await db.query(sql, params);
    res.json(users);
  } catch (error) {
    console.error('Erreur lors de la recherche des utilisateurs:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router; 