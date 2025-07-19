const express = require('express');
const router = express.Router();
const db = require('../database/db');
const authMiddleware = require('../middleware/auth.middleware');

// Récupérer tous les joueurs handibasket
router.get('/', authMiddleware, async (req, res) => {
  try {
    const [rows] = await db.execute(`
      SELECT 
        u.id,
        u.name,
        u.email,
        u.profile_type,
        u.profile_image_url,
        h.birth_date,
        h.handicap_type,
        h.cat,
        h.residence,
        h.club,
        h.coach,
        h.profession,
        h.created_at
      FROM users u
      LEFT JOIN handibasket_profiles h ON u.id = h.user_id
      WHERE u.profile_type = 'handibasket'
      ORDER BY u.created_at DESC
    `);

    res.json(rows);
  } catch (error) {
    console.error('Erreur lors de la récupération des joueurs handibasket:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Récupérer un profil handibasket spécifique
router.get('/profile', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    
    const [rows] = await db.execute(`
      SELECT * FROM handibasket_profiles WHERE user_id = ?
    `, [userId]);

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Profil non trouvé' });
    }

    res.json(rows[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération du profil handibasket:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Créer ou mettre à jour un profil handibasket
router.put('/profile', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const {
      birth_date,
      handicap_type,
      cat,
      residence,
      club,
      coach,
      profession
    } = req.body;

    // Vérifier si le profil existe déjà
    const [existingProfile] = await db.execute(
      'SELECT * FROM handibasket_profiles WHERE user_id = ?',
      [userId]
    );

    if (existingProfile.length > 0) {
      // Mettre à jour le profil existant
      await db.execute(`
        UPDATE handibasket_profiles 
        SET birth_date = ?, handicap_type = ?, cat = ?, residence = ?, 
            club = ?, coach = ?, profession = ?, updated_at = CURRENT_TIMESTAMP
        WHERE user_id = ?
      `, [birth_date, handicap_type, cat, residence, club, coach, profession, userId]);
    } else {
      // Créer un nouveau profil
      await db.execute(`
        INSERT INTO handibasket_profiles 
        (user_id, birth_date, handicap_type, cat, residence, club, coach, profession) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      `, [userId, birth_date, handicap_type, cat, residence, club, coach, profession]);
    }

    res.json({ message: 'Profil mis à jour avec succès' });
  } catch (error) {
    console.error('Erreur lors de la mise à jour du profil handibasket:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Rechercher des joueurs handibasket par critères
router.get('/search', authMiddleware, async (req, res) => {
  try {
    const { cat, residence, club } = req.query;
    let query = `
      SELECT 
        u.id,
        u.name,
        u.email,
        u.profile_image_url,
        h.birth_date,
        h.handicap_type,
        h.cat,
        h.residence,
        h.club,
        h.coach,
        h.profession,
        h.created_at
      FROM users u
      JOIN handibasket_profiles h ON u.id = h.user_id
      WHERE u.profile_type = 'handibasket'
    `;
    
    const params = [];
    
    if (cat) {
      query += ' AND h.cat = ?';
      params.push(cat);
    }
    
    if (residence) {
      query += ' AND h.residence LIKE ?';
      params.push(`%${residence}%`);
    }
    
    if (club) {
      query += ' AND h.club LIKE ?';
      params.push(`%${club}%`);
    }
    
    query += ' ORDER BY u.created_at DESC';
    
    const [rows] = await db.execute(query, params);
    res.json(rows);
  } catch (error) {
    console.error('Erreur lors de la recherche des joueurs handibasket:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Récupérer les annonces spécifiques handibasket
router.get('/annonces', authMiddleware, async (req, res) => {
  try {
    console.log('Récupération des annonces handibasket...');
    
    const [annonces] = await db.execute(`
      SELECT a.*, u.name as user_name, u.profile_type
      FROM annonces a
      JOIN users u ON a.user_id = u.id
      WHERE a.status = 'open' 
        AND a.target_profile = 'handibasket'
      ORDER BY a.created_at DESC
    `);
    
    console.log(`${annonces.length} annonces handibasket trouvées`);
    res.json(annonces);
  } catch (error) {
    console.error('Erreur lors de la récupération des annonces handibasket:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Créer une annonce handibasket
router.post('/annonces', authMiddleware, async (req, res) => {
  try {
    console.log('Création d\'une annonce handibasket:', req.body);
    const { title, description, type, requirements, salary_range, location } = req.body;
    const userId = req.user.id;

    // Vérifier que le type est valide
    const validTypes = ['recrutement', 'coaching', 'consultation'];
    if (!validTypes.includes(type)) {
      return res.status(400).json({ 
        message: 'Type d\'annonce invalide. Les types valides sont: ' + validTypes.join(', ')
      });
    }

    const [result] = await db.execute(
      `INSERT INTO annonces (user_id, title, description, type, requirements, salary_range, location, target_profile)
       VALUES (?, ?, ?, ?, ?, ?, ?, 'handibasket')`,
      [userId, title, description, type, requirements, salary_range, location]
    );

    const [newAnnonce] = await db.execute(
      `SELECT a.*, u.name as user_name, u.profile_type
       FROM annonces a
       JOIN users u ON a.user_id = u.id
       WHERE a.id = ?`,
      [result.insertId]
    );

    console.log('Nouvelle annonce handibasket créée:', newAnnonce[0]);
    res.status(201).json(newAnnonce[0]);
  } catch (error) {
    console.error('Erreur lors de la création de l\'annonce handibasket:', error);
    res.status(500).json({ 
      message: 'Erreur serveur',
      details: error.message
    });
  }
});

module.exports = router; 