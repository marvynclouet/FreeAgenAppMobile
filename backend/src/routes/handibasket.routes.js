const express = require('express');
const router = express.Router();
const pool = require('../config/db.config');
const authMiddleware = require('../middleware/auth.middleware');

// Récupérer tous les joueurs handibasket
router.get('/', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT 
        u.id,
        u.name,
        u.email,
        u.profile_type,
        u.profile_image_url,
        u.gender,
        u.nationality,
        h.birth_date,
        h.handicap_type,
        h.cat,
        h.residence,
        h.club,
        h.coach,
        h.profession,
        h.position,
        h.championship_level,
        h.height,
        h.weight,
        h.passport_type,
        h.experience_years,
        h.level,
        h.stats,
        h.achievements,
        h.video_url,
        h.bio,
        h.created_at
      FROM users u
      LEFT JOIN handibasket_profiles h ON u.id = h.user_id
      WHERE u.profile_type = 'handibasket'
      ORDER BY u.created_at DESC
    `);

    // Mapper les données pour Flutter
    const mappedRows = rows.map(row => {
      // Calculer l'âge si birth_date existe
      let age = null;
      if (row.birth_date) {
        const birth = new Date(row.birth_date);
        const now = new Date();
        age = now.getFullYear() - birth.getFullYear();
      }

      return {
        ...row,
        // Champs mappés pour Flutter
        age: age,
        classification: row.cat,
        nationality: row.residence,
        // Garder les champs originaux aussi
        cat: row.cat,
        residence: row.residence,
        handicap_type: row.handicap_type,
        position: row.position,
        championship_level: row.championship_level
      };
    });

    res.json(mappedRows);
  } catch (error) {
    console.error('Erreur lors de la récupération des joueurs handibasket:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Récupérer un profil handibasket spécifique
router.get('/profile', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    
    const [rows] = await pool.query(`
      SELECT hp.*, u.name, u.email, u.gender, u.nationality 
      FROM handibasket_profiles hp 
      JOIN users u ON hp.user_id = u.id 
      WHERE hp.user_id = ?
    `, [userId]);

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Profil non trouvé' });
    }

    const profile = rows[0];
    
    // Calculer l'âge à partir de birth_date
    let age = null;
    if (profile.birth_date) {
      const birth = new Date(profile.birth_date);
      const now = new Date();
      age = now.getFullYear() - birth.getFullYear();
    }

    // Mapper les données vers le format attendu par Flutter
    const mappedProfile = {
      ...profile,
      // Champs mappés pour Flutter
      age: age,
      classification: profile.cat,
      nationality: profile.residence,
      gender: profile.gender || 'non_specifie',
      // Garder les champs originaux aussi
      cat: profile.cat,
      residence: profile.residence,
      handicap_type: profile.handicap_type,
      position: profile.position,
      championship_level: profile.championship_level,
      height: profile.height,
      weight: profile.weight,
      passport_type: profile.passport_type,
      experience_years: profile.experience_years,
      level: profile.level,
      stats: profile.stats,
      achievements: profile.achievements,
      video_url: profile.video_url,
      bio: profile.bio,
      club: profile.club,
      coach: profile.coach
    };

    res.json(mappedProfile);
  } catch (error) {
    console.error('Erreur lors de la récupération du profil handibasket:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route de test pour debug
router.get('/debug', authMiddleware, async (req, res) => {
  res.json({
    message: 'Route handibasket debug OK',
    user: req.user,
    timestamp: new Date().toISOString(),
    version: 'v2-flutter-data-support'
  });
});

// Créer ou mettre à jour un profil handibasket
router.put('/profile', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    console.log('🔧 Mise à jour profil handibasket pour user_id:', userId);
    console.log('📝 Données reçues:', JSON.stringify(req.body, null, 2));
    
    const {
      birth_date,
      handicap_type,
      cat,
      residence,
      club,
      coach,
      profession,
      // Nouveaux champs envoyés par Flutter
      age,
      gender,
      nationality,
      height,
      weight,
      position,
      championship_level,
      passport_type,
      experience_years,
      level,
      classification,
      stats,
      achievements,
      video_url,
      bio
    } = req.body;

    // Vérifier si le profil existe déjà
    const [existingProfile] = await pool.query(
      'SELECT * FROM handibasket_profiles WHERE user_id = ?',
      [userId]
    );

    if (existingProfile.length > 0) {
      console.log('📝 Profil existant trouvé, mise à jour...');
      // Mettre à jour le profil existant
      await pool.query(`
        UPDATE handibasket_profiles 
        SET birth_date = ?, handicap_type = ?, cat = ?, residence = ?, 
            club = ?, coach = ?, profession = ?, position = ?, championship_level = ?,
            height = ?, weight = ?, passport_type = ?, experience_years = ?, 
            level = ?, stats = ?, achievements = ?, video_url = ?, bio = ?,
            updated_at = CURRENT_TIMESTAMP
        WHERE user_id = ?
      `, [
        birth_date || (age ? `1990-01-01` : '1990-01-01'), 
        handicap_type || 'non_specifie', 
        cat || classification || 'a_definir', 
        residence || nationality || 'a_definir', 
        club, 
        coach, 
        profession || 'a_definir',
        position || 'polyvalent',
        championship_level || 'non_specifie',
        height ? parseInt(height) : null,
        weight ? parseInt(weight) : null,
        passport_type,
        experience_years ? parseInt(experience_years) : null,
        level,
        stats ? JSON.stringify(stats) : null,
        achievements,
        video_url,
        bio,
        userId
      ]);
      console.log('✅ Profil mis à jour avec succès');
    } else {
      console.log('📝 Aucun profil existant, création...');
      // Créer un nouveau profil
      await pool.query(`
        INSERT INTO handibasket_profiles 
        (user_id, birth_date, handicap_type, cat, residence, club, coach, profession, position, championship_level,
         height, weight, passport_type, experience_years, level, stats, achievements, video_url, bio) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `, [
        userId, 
        birth_date || (age ? `1990-01-01` : '1990-01-01'), 
        handicap_type || 'non_specifie', 
        cat || classification || 'a_definir', 
        residence || nationality || 'a_definir', 
        club, 
        coach, 
        profession || 'a_definir',
        position || 'polyvalent',
        championship_level || 'non_specifie',
        height ? parseInt(height) : null,
        weight ? parseInt(weight) : null,
        passport_type,
        experience_years ? parseInt(experience_years) : null,
        level,
        stats ? JSON.stringify(stats) : null,
        achievements,
        video_url,
        bio
      ]);
    }

    res.json({ message: 'Profil mis à jour avec succès' });
  } catch (error) {
    console.error('❌ Erreur lors de la mise à jour du profil handibasket:', error);
    console.error('❌ Stack trace:', error.stack);
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
        u.gender,
        u.nationality,
        h.birth_date,
        h.handicap_type,
        h.cat,
        h.residence,
        h.club,
        h.coach,
        h.profession,
        h.position,
        h.championship_level,
        h.height,
        h.weight,
        h.passport_type,
        h.experience_years,
        h.level,
        h.stats,
        h.achievements,
        h.video_url,
        h.bio,
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
    
    const [rows] = await pool.query(query, params);
    
    // Mapper les données pour Flutter
    const mappedRows = rows.map(row => {
      // Calculer l'âge si birth_date existe
      let age = null;
      if (row.birth_date) {
        const birth = new Date(row.birth_date);
        const now = new Date();
        age = now.getFullYear() - birth.getFullYear();
      }

      return {
        ...row,
        // Champs mappés pour Flutter
        age: age,
        classification: row.cat,
        nationality: row.residence,
        // Garder les champs originaux aussi
        cat: row.cat,
        residence: row.residence,
        handicap_type: row.handicap_type,
        position: row.position,
        championship_level: row.championship_level
      };
    });
    
    res.json(mappedRows);
  } catch (error) {
    console.error('Erreur lors de la recherche des joueurs handibasket:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Récupérer les annonces spécifiques handibasket
router.get('/annonces', authMiddleware, async (req, res) => {
  try {
    console.log('Récupération des annonces handibasket...');
    
    const [annonces] = await pool.query(`
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

    const [result] = await pool.query(
      `INSERT INTO annonces (user_id, title, description, type, requirements, salary_range, location, target_profile)
       VALUES (?, ?, ?, ?, ?, ?, ?, 'handibasket')`,
      [userId, title, description, type, requirements, salary_range, location]
    );

    const [newAnnonce] = await pool.query(
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

module.exports = router; // Force redeploy Sun Aug 31 17:22:38 CEST 2025
// Force redeploy Wed Sep  3 18:26:56 CEST 2025
// Force redeploy mapping fix Wed Sep  3 18:50:00 CEST 2025
