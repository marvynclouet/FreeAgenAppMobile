const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../database/db');

// Route de healthcheck publique
router.get('/health', async (req, res) => {
  try {
    // Test simple de connexion à la base de données
    await db.execute('SELECT 1');
    res.json({ 
      status: 'OK', 
      message: 'Backend is running',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Health check failed:', error);
    res.status(500).json({ 
      status: 'ERROR', 
      message: 'Database connection failed',
      timestamp: new Date().toISOString()
    });
  }
});

// Route d'inscription
router.post('/register', async (req, res) => {
  try {
    const { 
      name, 
      email, 
      password, 
      profile_type
    } = req.body;

    // Vérifier si l'email existe déjà
    const [existingUsers] = await db.execute(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );

    if (existingUsers.length > 0) {
      return res.status(400).json({ message: 'Cet email est déjà utilisé' });
    }

    // Hasher le mot de passe
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Insérer l'utilisateur
    const [result] = await db.execute(
      'INSERT INTO users (name, email, password, profile_type) VALUES (?, ?, ?, ?)',
      [name, email, hashedPassword, profile_type]
    );

    const userId = result.insertId;

    // Créer le profil spécifique selon le type
    switch (profile_type) {
      case 'handibasket':
        await db.execute(
          'INSERT INTO handibasket_profiles (user_id) VALUES (?)',
          [userId]
        );
        break;
      case 'coach_pro':
        await db.execute(
          'INSERT INTO coach_pro_profiles (user_id) VALUES (?)',
          [userId]
        );
        break;
      case 'coach_basket':
        await db.execute(
          'INSERT INTO coach_basket_profiles (user_id) VALUES (?)',
          [userId]
        );
        break;
      case 'juriste':
        await db.execute(
          'INSERT INTO juriste_profiles (user_id) VALUES (?)',
          [userId]
        );
        break;
      case 'dieteticienne':
        await db.execute(
          'INSERT INTO dieteticienne_profiles (user_id) VALUES (?)',
          [userId]
        );
        break;
      case 'club':
        await db.execute(
          'INSERT INTO club_profiles (user_id) VALUES (?)',
          [userId]
        );
        break;
    }

    // Générer le token JWT
    const token = jwt.sign(
      { id: userId, email, profile_type },
      process.env.JWT_SECRET,
      { expiresIn: '24h' } // Valeur par défaut fixe
    );

    // Retourner les informations de l'utilisateur
    res.status(201).json({
      message: 'Inscription réussie',
      token,
      user: {
        id: userId,
        name,
        email,
        profile_type,
        is_admin: false
      }
    });

  } catch (error) {
    console.error('Erreur lors de l\'inscription:', error);
    res.status(500).json({ message: 'Erreur serveur lors de l\'inscription' });
  }
});

// Route de connexion
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Vérifier si l'utilisateur existe
    const [users] = await db.execute(
      'SELECT id, name, email, password, profile_type, is_admin FROM users WHERE email = ?',
      [email]
    );

    if (users.length === 0) {
      return res.status(401).json({ message: 'Email ou mot de passe incorrect' });
    }

    const user = users[0];

    // Vérifier le mot de passe
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ message: 'Email ou mot de passe incorrect' });
    }

    // Générer le token JWT
    const token = jwt.sign(
      { id: user.id, email: user.email, profile_type: user.profile_type },
      process.env.JWT_SECRET,
      { expiresIn: '24h' } // Valeur par défaut fixe
    );

    // Retourner les informations de l'utilisateur
    res.json({
      message: 'Connexion réussie',
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        profile_type: user.profile_type,
        is_admin: user.is_admin || false
      }
    });
  } catch (error) {
    console.error('Erreur lors de la connexion:', error);
    res.status(500).json({ message: 'Erreur lors de la connexion' });
  }
});

// Route de validation du token
router.get('/validate', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ message: 'Token manquant' });
    }

    // Vérifier le token JWT
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Vérifier si l'utilisateur existe toujours
    const [users] = await db.execute(
      'SELECT id, name, email, profile_type, is_admin FROM users WHERE id = ?',
      [decoded.id]
    );

    if (users.length === 0) {
      return res.status(401).json({ message: 'Utilisateur non trouvé' });
    }

    res.json({ 
      valid: true, 
      user: users[0],
      message: 'Token valide' 
    });
  } catch (error) {
    console.error('Erreur lors de la validation du token:', error);
    res.status(401).json({ message: 'Token invalide' });
  }
});

module.exports = router; 