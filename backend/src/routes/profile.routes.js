const express = require('express');
const router = express.Router();
const db = require('../config/db.config');
const verifyToken = require('../middleware/auth.middleware');

// Middleware pour vérifier le type de profil
const checkProfileType = (profileType) => {
  return (req, res, next) => {
    if (req.user.profile_type !== profileType) {
      return res.status(403).json({ 
        message: 'Accès non autorisé pour ce type de profil'
      });
    }
    next();
  };
};

// Route pour récupérer le profil d'un joueur
router.get('/player/profile', verifyToken, checkProfileType('player'), async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT p.*, u.name, u.email, u.gender, u.nationality, u.profile_image_url 
       FROM player_profiles p 
       JOIN users u ON p.user_id = u.id 
       WHERE p.user_id = ?`,
      [req.user.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Profil non trouvé' });
    }

    res.json(rows[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération du profil joueur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route pour mettre à jour le profil d'un joueur
router.put('/player/profile', verifyToken, checkProfileType('player'), async (req, res) => {
  const connection = await db.getConnection();
  
  try {
    const {
      age,
      height,
      weight,
      position,
      experience_years,
      level,
      achievements,
      stats,
      video_url,
      bio,
      gender,
      nationality,
      championship_level,
      passport_type
    } = req.body;

    await connection.beginTransaction();

    // Mettre à jour les champs dans la table users (gender, nationality)
    if (gender || nationality) {
      await connection.query(
        `UPDATE users SET 
          gender = COALESCE(?, gender),
          nationality = COALESCE(?, nationality)
        WHERE id = ?`,
        [gender, nationality, req.user.id]
      );
    }

    // Vérifier si le profil existe déjà
    const [existingProfile] = await connection.query(
      'SELECT id FROM player_profiles WHERE user_id = ?',
      [req.user.id]
    );

    if (existingProfile.length === 0) {
      // Créer un nouveau profil
      await connection.query(
        `INSERT INTO player_profiles (
          user_id, age, height, weight, position, experience_years,
          level, achievements, stats, video_url, bio, championship_level, passport_type
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          req.user.id,
          age,
          height,
          weight,
          position,
          experience_years,
          level,
          achievements,
          JSON.stringify(stats),
          video_url,
          bio,
          championship_level,
          passport_type
        ]
      );
    } else {
      // Mettre à jour le profil existant
      await connection.query(
        `UPDATE player_profiles SET
          age = ?,
          height = ?,
          weight = ?,
          position = ?,
          experience_years = ?,
          level = ?,
          achievements = ?,
          stats = ?,
          video_url = ?,
          bio = ?,
          championship_level = ?,
          passport_type = ?
        WHERE user_id = ?`,
        [
          age,
          height,
          weight,
          position,
          experience_years,
          level,
          achievements,
          JSON.stringify(stats),
          video_url,
          bio,
          championship_level,
          passport_type,
          req.user.id
        ]
      );
    }

    await connection.commit();
    res.json({ message: 'Profil mis à jour avec succès' });
  } catch (error) {
    await connection.rollback();
    console.error('Erreur lors de la mise à jour du profil joueur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  } finally {
    connection.release();
  }
});

// Route pour récupérer le profil d'un joueur handibasket
router.get('/handibasket/profile', verifyToken, checkProfileType('handibasket'), async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT p.*, u.name, u.email, u.gender, u.nationality 
       FROM handibasket_profiles p 
       JOIN users u ON p.user_id = u.id 
       WHERE p.user_id = ?`,
      [req.user.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Profil non trouvé' });
    }

    res.json(rows[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération du profil handibasket:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route pour mettre à jour le profil d'un joueur handibasket
router.put('/handibasket/profile', verifyToken, checkProfileType('handibasket'), async (req, res) => {
  const connection = await db.getConnection();
  
  try {
    const {
      age,
      height,
      weight,
      position,
      experience_years,
      level,
      achievements,
      stats,
      video_url,
      bio,
      gender,
      nationality,
      championship_level,
      passport_type,
      classification
    } = req.body;

    await connection.beginTransaction();

    // Mettre à jour les champs dans la table users (gender, nationality)
    if (gender || nationality) {
      await connection.query(
        `UPDATE users SET 
          gender = COALESCE(?, gender),
          nationality = COALESCE(?, nationality)
        WHERE id = ?`,
        [gender, nationality, req.user.id]
      );
    }

    // Vérifier si le profil existe déjà
    const [existingProfile] = await connection.query(
      'SELECT id FROM handibasket_profiles WHERE user_id = ?',
      [req.user.id]
    );

    if (existingProfile.length === 0) {
      // Créer un nouveau profil
      await connection.query(
        `INSERT INTO handibasket_profiles (
          user_id, age, height, weight, position, experience_years,
          level, achievements, stats, video_url, bio, championship_level, passport_type, classification
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          req.user.id,
          age,
          height,
          weight,
          position,
          experience_years,
          level,
          achievements,
          JSON.stringify(stats),
          video_url,
          bio,
          championship_level,
          passport_type,
          classification
        ]
      );
    } else {
      // Mettre à jour le profil existant
      await connection.query(
        `UPDATE handibasket_profiles SET
          age = ?,
          height = ?,
          weight = ?,
          position = ?,
          experience_years = ?,
          level = ?,
          achievements = ?,
          stats = ?,
          video_url = ?,
          bio = ?,
          championship_level = ?,
          passport_type = ?,
          classification = ?
        WHERE user_id = ?`,
        [
          age,
          height,
          weight,
          position,
          experience_years,
          level,
          achievements,
          JSON.stringify(stats),
          video_url,
          bio,
          championship_level,
          passport_type,
          classification,
          req.user.id
        ]
      );
    }

    await connection.commit();
    res.json({ message: 'Profil mis à jour avec succès' });
  } catch (error) {
    await connection.rollback();
    console.error('Erreur lors de la mise à jour du profil handibasket:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  } finally {
    connection.release();
  }
});

// Route pour récupérer le profil d'un club
router.get('/club/profile', verifyToken, checkProfileType('club'), async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT c.*, u.name, u.email FROM club_profiles c JOIN users u ON c.user_id = u.id WHERE c.user_id = ?',
      [req.user.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Profil non trouvé' });
    }

    res.json(rows[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération du profil club:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route pour mettre à jour le profil d'un club
router.put('/club/profile', verifyToken, checkProfileType('club'), async (req, res) => {
  try {
    const {
      club_name,
      address,
      city,
      level,
      description,
      phone,
      website,
      social_media
    } = req.body;

    const [existingProfile] = await db.query(
      'SELECT id FROM club_profiles WHERE user_id = ?',
      [req.user.id]
    );

    if (existingProfile.length === 0) {
      await db.query(
        `INSERT INTO club_profiles (
          user_id, club_name, address, city, level,
          description, phone, website, social_media
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          req.user.id,
          club_name,
          address,
          city,
          level,
          description,
          phone,
          website,
          social_media
        ]
      );
    } else {
      await db.query(
        `UPDATE club_profiles SET
          club_name = ?,
          address = ?,
          city = ?,
          level = ?,
          description = ?,
          phone = ?,
          website = ?,
          social_media = ?
        WHERE user_id = ?`,
        [
          club_name,
          address,
          city,
          level,
          description,
          phone,
          website,
          social_media,
          req.user.id
        ]
      );
    }

    res.json({ message: 'Profil mis à jour avec succès' });
  } catch (error) {
    console.error('Erreur lors de la mise à jour du profil club:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route pour récupérer le profil d'un coach pro
router.get('/coach_pro/profile', verifyToken, checkProfileType('coach_pro'), async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT c.*, u.name, u.email FROM coach_pro_profiles c JOIN users u ON c.user_id = u.id WHERE c.user_id = ?',
      [req.user.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Profil non trouvé' });
    }

    res.json(rows[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération du profil coach pro:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route pour mettre à jour le profil d'un coach pro
router.put('/coach_pro/profile', verifyToken, checkProfileType('coach_pro'), async (req, res) => {
  try {
    const {
      speciality,
      experience_years,
      certifications,
      hourly_rate,
      services,
      availability
    } = req.body;

    const [existingProfile] = await db.query(
      'SELECT id FROM coach_pro_profiles WHERE user_id = ?',
      [req.user.id]
    );

    if (existingProfile.length === 0) {
      await db.query(
        `INSERT INTO coach_pro_profiles (
          user_id, speciality, experience_years, certifications,
          hourly_rate, services, availability
        ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          req.user.id,
          speciality,
          experience_years,
          certifications,
          hourly_rate,
          services,
          availability
        ]
      );
    } else {
      await db.query(
        `UPDATE coach_pro_profiles SET
          speciality = ?,
          experience_years = ?,
          certifications = ?,
          hourly_rate = ?,
          services = ?,
          availability = ?
        WHERE user_id = ?`,
        [
          speciality,
          experience_years,
          certifications,
          hourly_rate,
          services,
          availability,
          req.user.id
        ]
      );
    }

    res.json({ message: 'Profil mis à jour avec succès' });
  } catch (error) {
    console.error('Erreur lors de la mise à jour du profil coach pro:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route pour récupérer le profil d'un juriste
router.get('/juriste/profile', verifyToken, checkProfileType('juriste'), async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT j.*, u.name, u.email, u.profile_image_url FROM juriste_profiles j JOIN users u ON j.user_id = u.id WHERE j.user_id = ?',
      [req.user.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Profil non trouvé' });
    }

    res.json(rows[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération du profil juriste:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route pour mettre à jour le profil d'un juriste
router.put('/juriste/profile', verifyToken, checkProfileType('juriste'), async (req, res) => {
  try {
    const {
      speciality,
      bar_number,
      experience_years,
      hourly_rate,
      services,
      availability
    } = req.body;

    const [existingProfile] = await db.query(
      'SELECT id FROM juriste_profiles WHERE user_id = ?',
      [req.user.id]
    );

    if (existingProfile.length === 0) {
      await db.query(
        `INSERT INTO juriste_profiles (
          user_id, speciality, bar_number, experience_years,
          hourly_rate, services, availability
        ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          req.user.id,
          speciality,
          bar_number,
          experience_years,
          hourly_rate,
          services,
          availability
        ]
      );
    } else {
      await db.query(
        `UPDATE juriste_profiles SET
          speciality = ?,
          bar_number = ?,
          experience_years = ?,
          hourly_rate = ?,
          services = ?,
          availability = ?
        WHERE user_id = ?`,
        [
          speciality,
          bar_number,
          experience_years,
          hourly_rate,
          services,
          availability,
          req.user.id
        ]
      );
    }

    res.json({ message: 'Profil mis à jour avec succès' });
  } catch (error) {
    console.error('Erreur lors de la mise à jour du profil juriste:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route pour récupérer le profil d'une diététicienne
router.get('/dieteticienne/profile', verifyToken, checkProfileType('dieteticienne'), async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT d.*, u.name, u.email, u.profile_image_url FROM dieteticienne_profiles d JOIN users u ON d.user_id = u.id WHERE d.user_id = ?',
      [req.user.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Profil non trouvé' });
    }

    res.json(rows[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération du profil diététicienne:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route pour mettre à jour le profil d'une diététicienne
router.put('/dieteticienne/profile', verifyToken, checkProfileType('dieteticienne'), async (req, res) => {
  try {
    const {
      speciality,
      experience_years,
      certifications,
      hourly_rate,
      services,
      availability
    } = req.body;

    // Vérifier si le profil existe déjà ET s'il a des données valides
    const [existingProfile] = await db.query(
      'SELECT id, speciality FROM dieteticienne_profiles WHERE user_id = ?',
      [req.user.id]
    );

    if (existingProfile.length === 0) {
      // Créer un nouveau profil
      await db.query(
        `INSERT INTO dieteticienne_profiles (
          user_id, speciality, experience_years, certifications,
          hourly_rate, services, availability
        ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          req.user.id,
          speciality,
          experience_years,
          certifications,
          hourly_rate,
          services,
          availability
        ]
      );
    } else {
      // Mettre à jour le profil existant
      await db.query(
        `UPDATE dieteticienne_profiles SET
          speciality = ?,
          experience_years = ?,
          certifications = ?,
          hourly_rate = ?,
          services = ?,
          availability = ?
        WHERE user_id = ?`,
        [
          speciality,
          experience_years,
          certifications,
          hourly_rate,
          services,
          availability,
          req.user.id
        ]
      );
    }

    res.json({ message: 'Profil mis à jour avec succès' });
  } catch (error) {
    console.error('Erreur lors de la mise à jour du profil diététicienne:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route pour récupérer le profil d'un joueur handibasket
router.get('/handibasket/profile', verifyToken, checkProfileType('handibasket'), async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT h.*, u.name, u.email, u.profile_image_url FROM handibasket_profiles h JOIN users u ON h.user_id = u.id WHERE h.user_id = ?',
      [req.user.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Profil non trouvé' });
    }

    res.json(rows[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération du profil handibasket:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route pour mettre à jour le profil d'un joueur handibasket
router.put('/handibasket/profile', verifyToken, checkProfileType('handibasket'), async (req, res) => {
  try {
    const {
      birth_date,
      handicap_type,
      cat,
      residence,
      club,
      coach,
      profession
    } = req.body;

    const [existingProfile] = await db.query(
      'SELECT id FROM handibasket_profiles WHERE user_id = ?',
      [req.user.id]
    );

    if (existingProfile.length === 0) {
      // Créer un nouveau profil
      await db.query(
        `INSERT INTO handibasket_profiles (
          user_id, birth_date, handicap_type, cat, residence,
          club, coach, profession
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          req.user.id,
          birth_date,
          handicap_type,
          cat,
          residence,
          club,
          coach,
          profession
        ]
      );
    } else {
      // Mettre à jour le profil existant
      await db.query(
        `UPDATE handibasket_profiles SET
          birth_date = ?,
          handicap_type = ?,
          cat = ?,
          residence = ?,
          club = ?,
          coach = ?,
          profession = ?
        WHERE user_id = ?`,
        [
          birth_date,
          handicap_type,
          cat,
          residence,
          club,
          coach,
          profession,
          req.user.id
        ]
      );
    }

    res.json({ message: 'Profil mis à jour avec succès' });
  } catch (error) {
    console.error('Erreur lors de la mise à jour du profil handibasket:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});


// Route racine pour tester
router.get('/', (req, res) => {
  res.json({ message: 'profile API is working' });
});


module.exports = router; 