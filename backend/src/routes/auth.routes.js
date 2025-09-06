const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../config/db.config');

// Route d'inscription
router.post('/register', async (req, res) => {
  try {
    const { 
      name, 
      email, 
      password, 
      profile_type,
      // Champs spécifiques pour handibasket
      birth_date,
      handicap_type,
      cat,
      residence,
      profession,
      club,
      coach,
      position,
      championship_level
    } = req.body;

    // Vérifier si l'email existe déjà
    const [existingUsers] = await pool.query(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );

    if (existingUsers.length > 0) {
      return res.status(400).json({ message: 'Cet email est déjà utilisé' });
    }

    // Valider le mot de passe (au moins 1 majuscule et 1 chiffre)
    const passwordRegex = /^(?=.*[A-Z])(?=.*\d).{6,}$/;
    if (!passwordRegex.test(password)) {
      return res.status(400).json({ 
        message: 'Le mot de passe doit contenir au moins 6 caractères, une majuscule et un chiffre' 
      });
    }

    // Hasher le mot de passe
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Insérer l'utilisateur
    const [result] = await pool.query(
      'INSERT INTO users (name, email, password, profile_type, subscription_type, is_premium) VALUES (?, ?, ?, ?, "free", FALSE)',
      [name, email, hashedPassword, profile_type]
    );

    const userId = result.insertId;

    // Créer le profil spécifique selon le type
    switch (profile_type) {
      case 'handibasket':
        // Inscription handibasket avec valeurs par défaut (profil à compléter plus tard)
        await pool.query(
          `INSERT INTO handibasket_profiles (
            user_id, birth_date, handicap_type, cat, residence, profession, 
            club, coach, position, championship_level
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            userId, 
            birth_date || '1990-01-01', // Valeur par défaut
            handicap_type || 'non_specifie', // Valeur par défaut
            cat || 'a_definir', // Valeur par défaut plus courte
            residence || 'a_definir', // Valeur par défaut
            profession || 'a_definir', // Valeur par défaut
            club || null,
            coach || null,
            position || 'polyvalent',
            championship_level || 'non_specifie'
          ]
        );
        break;
        
      case 'handibasket_team':
        // Inscription équipe handibasket avec valeurs par défaut
        await pool.query(
          `INSERT INTO handibasket_team_profiles (
            user_id, team_name, city, level
          ) VALUES (?, ?, ?, ?)`,
          [
            userId,
            name || 'Nom de l\'équipe',
            'Ville',
            'Regional'
          ]
        );
        break;
        
      case 'coach_pro':
        await pool.query(
          'INSERT INTO coach_pro_profiles (user_id) VALUES (?)',
          [userId]
        );
        break;
        
      case 'coach_basket':
        await pool.query(
          'INSERT INTO coach_basket_profiles (user_id) VALUES (?)',
          [userId]
        );
        break;
        
      case 'juriste':
        await pool.query(
          'INSERT INTO juriste_profiles (user_id) VALUES (?)',
          [userId]
        );
        break;
        
      case 'dieteticienne':
        await pool.query(
          'INSERT INTO dieteticienne_profiles (user_id) VALUES (?)',
          [userId]
        );
        break;
        
      case 'club':
        await pool.query(
          'INSERT INTO club_profiles (user_id) VALUES (?)',
          [userId]
        );
        break;
        
      default:
        // Pour les autres types de profil, pas de table spécifique nécessaire
        console.log(`Profil ${profile_type} créé sans table spécifique`);
        break;
    }

    // Créer une entrée dans user_limits pour le nouvel utilisateur
    try {
      await pool.query(
        'INSERT INTO user_limits (user_id, messages_sent, opportunities_posted, emails_viewed) VALUES (?, 0, 0, 0)',
        [userId]
      );
    } catch (limitError) {
      console.log('Table user_limits non disponible, ignoré');
    }

    // Générer le token JWT
    const token = jwt.sign(
      { id: userId, email, profile_type },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '24h' }
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
        subscription_type: 'free',
        is_premium: false
      }
    });

  } catch (error) {
    console.error('Erreur lors de l\'inscription:', error);
    res.status(500).json({ 
      message: 'Erreur serveur lors de l\'inscription',
      details: error.message 
    });
  }
});

// Route de connexion
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Vérifier si l'utilisateur existe
    const [users] = await pool.query(
      'SELECT * FROM users WHERE email = ?',
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

    // Vérifier et mettre à jour le statut premium si nécessaire
    let subscriptionType = user.subscription_type || 'free';
    let isPremium = user.is_premium || false;
    
    if (user.subscription_expiry && new Date(user.subscription_expiry) < new Date()) {
      subscriptionType = 'free';
      isPremium = false;
      // Mettre à jour en base
      await pool.query(
        'UPDATE users SET subscription_type = ?, is_premium = ? WHERE id = ?',
        ['free', false, user.id]
      );
    }

    // Générer le token JWT
    const token = jwt.sign(
      { id: user.id, email: user.email, profile_type: user.profile_type },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '24h' }
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
        subscription_type: subscriptionType,
        is_premium: isPremium,
        subscription_expiry: user.subscription_expiry
      }
    });
  } catch (error) {
    console.error('Erreur lors de la connexion:', error);
    res.status(500).json({ message: 'Erreur lors de la connexion' });
  }
});

// Route de diagnostic - version du code
router.get('/version', (req, res) => {
  res.json({ 
    version: '2.0-handibasket-fix',
    timestamp: new Date().toISOString(),
    handibasket_fix: true
  });
});

// Route de validation du token
router.get('/validate', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ message: 'Token manquant' });
    }

    // Vérifier le token JWT
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
    
    // Vérifier si l'utilisateur existe toujours
    const [users] = await pool.query(
      'SELECT id, name, email, profile_type, subscription_type, is_premium, subscription_expiry FROM users WHERE id = ?',
      [decoded.id]
    );

    if (users.length === 0) {
      return res.status(401).json({ message: 'Utilisateur non trouvé' });
    }

    const user = users[0];

    // Vérifier et mettre à jour le statut premium si nécessaire
    let subscriptionType = user.subscription_type || 'free';
    let isPremium = user.is_premium || false;
    
    if (user.subscription_expiry && new Date(user.subscription_expiry) < new Date()) {
      subscriptionType = 'free';
      isPremium = false;
      // Mettre à jour en base
      await pool.query(
        'UPDATE users SET subscription_type = ?, is_premium = ? WHERE id = ?',
        ['free', false, user.id]
      );
    }

    res.json({ 
      valid: true, 
      user: {
        ...user,
        subscription_type: subscriptionType,
        is_premium: isPremium
      },
      message: 'Token valide' 
    });
  } catch (error) {
    console.error('Erreur lors de la validation du token:', error);
    res.status(401).json({ message: 'Token invalide' });
  }
});

module.exports = router; 