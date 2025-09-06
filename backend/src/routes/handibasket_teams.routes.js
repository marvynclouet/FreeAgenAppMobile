const express = require('express');
const router = express.Router();
const pool = require('../config/db.config');
const authMiddleware = require('../middleware/auth.middleware');

// Récupérer toutes les équipes handibasket
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.execute(`
      SELECT 
        u.id, u.name, u.email, u.gender, u.nationality,
        htp.team_name, htp.city, htp.region, htp.level, htp.division,
        htp.founded_year, htp.description, htp.achievements,
        htp.contact_person, htp.phone, htp.email_contact, htp.website,
        htp.facilities, htp.training_schedule, htp.recruitment_needs,
        htp.budget_range, htp.accommodation_offered, htp.transport_offered,
        htp.medical_support, htp.player_requirements,
        htp.created_at, htp.updated_at
      FROM users u
      JOIN handibasket_team_profiles htp ON u.id = htp.user_id
      WHERE u.profile_type = 'handibasket_team'
      ORDER BY htp.level DESC, u.name
    `);

    // Mapper les données pour Flutter
    const mappedRows = rows.map(row => ({
      ...row,
      // Champs mappés pour Flutter
      name: row.team_name,
      // Garder les champs originaux aussi
      team_name: row.team_name,
      city: row.city,
      region: row.region,
      level: row.level,
      division: row.division
    }));

    res.json(mappedRows);
  } catch (error) {
    console.error('Erreur lors de la récupération des équipes handibasket:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Récupérer une équipe handibasket spécifique
router.get('/:id', async (req, res) => {
  try {
    const teamId = req.params.id;
    
    const [rows] = await pool.execute(`
      SELECT 
        u.id, u.name, u.email, u.gender, u.nationality,
        htp.*
      FROM users u
      JOIN handibasket_team_profiles htp ON u.id = htp.user_id
      WHERE u.id = ? AND u.profile_type = 'handibasket_team'
    `, [teamId]);

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Équipe non trouvée' });
    }

    const team = rows[0];
    
    // Mapper les données vers le format attendu par Flutter
    const mappedTeam = {
      ...team,
      // Champs mappés pour Flutter
      name: team.team_name,
      // Garder les champs originaux aussi
      team_name: team.team_name,
      city: team.city,
      region: team.region,
      level: team.level,
      division: team.division
    };

    res.json(mappedTeam);
  } catch (error) {
    console.error('Erreur lors de la récupération de l\'équipe handibasket:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Récupérer le profil de l'équipe connectée
router.get('/profile', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    
    const [rows] = await pool.execute(`
      SELECT 
        u.id, u.name, u.email, u.gender, u.nationality,
        htp.*
      FROM users u
      JOIN handibasket_team_profiles htp ON u.id = htp.user_id
      WHERE u.id = ? AND u.profile_type = 'handibasket_team'
    `, [userId]);

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Profil d\'équipe non trouvé' });
    }

    const team = rows[0];
    
    // Mapper les données vers le format attendu par Flutter
    const mappedTeam = {
      ...team,
      // Champs mappés pour Flutter
      name: team.team_name,
      // Garder les champs originaux aussi
      team_name: team.team_name,
      city: team.city,
      region: team.region,
      level: team.level,
      division: team.division
    };

    res.json(mappedTeam);
  } catch (error) {
    console.error('Erreur lors de la récupération du profil d\'équipe handibasket:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Créer ou mettre à jour le profil d'une équipe handibasket
router.put('/profile', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const {
      team_name,
      city,
      region,
      level,
      division,
      founded_year,
      description,
      achievements,
      contact_person,
      phone,
      email_contact,
      website,
      social_media,
      facilities,
      training_schedule,
      competition_schedule,
      recruitment_needs,
      budget_range,
      accommodation_offered,
      transport_offered,
      medical_support,
      coaching_staff,
      player_requirements
    } = req.body;

    // Vérifier si le profil existe déjà
    const [existingProfile] = await pool.execute(
      'SELECT * FROM handibasket_team_profiles WHERE user_id = ?',
      [userId]
    );

    if (existingProfile.length > 0) {
      // Mettre à jour le profil existant
      await pool.execute(`
        UPDATE handibasket_team_profiles 
        SET team_name = ?, city = ?, region = ?, level = ?, division = ?,
            founded_year = ?, description = ?, achievements = ?, contact_person = ?,
            phone = ?, email_contact = ?, website = ?, social_media = ?,
            facilities = ?, training_schedule = ?, competition_schedule = ?,
            recruitment_needs = ?, budget_range = ?, accommodation_offered = ?,
            transport_offered = ?, medical_support = ?, coaching_staff = ?,
            player_requirements = ?, updated_at = CURRENT_TIMESTAMP
        WHERE user_id = ?
      `, [
        team_name || 'Nom de l\'équipe',
        city || 'Ville',
        region,
        level || 'Regional',
        division,
        founded_year,
        description,
        achievements,
        contact_person,
        phone,
        email_contact,
        website,
        social_media ? JSON.stringify(social_media) : null,
        facilities,
        training_schedule,
        competition_schedule,
        recruitment_needs,
        budget_range,
        accommodation_offered || false,
        transport_offered || false,
        medical_support || false,
        coaching_staff ? JSON.stringify(coaching_staff) : null,
        player_requirements,
        userId
      ]);
    } else {
      // Créer un nouveau profil
      await pool.execute(`
        INSERT INTO handibasket_team_profiles 
        (user_id, team_name, city, region, level, division, founded_year, description,
         achievements, contact_person, phone, email_contact, website, social_media,
         facilities, training_schedule, competition_schedule, recruitment_needs,
         budget_range, accommodation_offered, transport_offered, medical_support,
         coaching_staff, player_requirements) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `, [
        userId,
        team_name || 'Nom de l\'équipe',
        city || 'Ville',
        region,
        level || 'Regional',
        division,
        founded_year,
        description,
        achievements,
        contact_person,
        phone,
        email_contact,
        website,
        social_media ? JSON.stringify(social_media) : null,
        facilities,
        training_schedule,
        competition_schedule,
        recruitment_needs,
        budget_range,
        accommodation_offered || false,
        transport_offered || false,
        medical_support || false,
        coaching_staff ? JSON.stringify(coaching_staff) : null,
        player_requirements
      ]);
    }

    res.json({ message: 'Profil d\'équipe handibasket mis à jour avec succès' });
  } catch (error) {
    console.error('Erreur lors de la mise à jour du profil d\'équipe handibasket:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Rechercher des équipes handibasket
router.get('/search', async (req, res) => {
  try {
    const { city, level, region, keyword } = req.query;
    
    let query = `
      SELECT 
        u.id, u.name, u.email, u.gender, u.nationality,
        htp.team_name, htp.city, htp.region, htp.level, htp.division,
        htp.founded_year, htp.description, htp.achievements,
        htp.contact_person, htp.phone, htp.email_contact, htp.website,
        htp.facilities, htp.training_schedule, htp.recruitment_needs,
        htp.budget_range, htp.accommodation_offered, htp.transport_offered,
        htp.medical_support, htp.player_requirements
      FROM users u
      JOIN handibasket_team_profiles htp ON u.id = htp.user_id
      WHERE u.profile_type = 'handibasket_team'
    `;
    
    const params = [];
    
    if (city) {
      query += ' AND htp.city LIKE ?';
      params.push(`%${city}%`);
    }
    
    if (level) {
      query += ' AND htp.level = ?';
      params.push(level);
    }
    
    if (region) {
      query += ' AND htp.region LIKE ?';
      params.push(`%${region}%`);
    }
    
    if (keyword) {
      query += ' AND (htp.team_name LIKE ? OR htp.description LIKE ? OR htp.recruitment_needs LIKE ?)';
      params.push(`%${keyword}%`, `%${keyword}%`, `%${keyword}%`);
    }
    
    query += ' ORDER BY htp.level DESC, u.name';
    
    const [rows] = await pool.query(query, params);
    
    // Mapper les données pour Flutter
    const mappedRows = rows.map(row => ({
      ...row,
      // Champs mappés pour Flutter
      name: row.team_name,
      // Garder les champs originaux aussi
      team_name: row.team_name,
      city: row.city,
      region: row.region,
      level: row.level,
      division: row.division
    }));

    res.json(mappedRows);
  } catch (error) {
    console.error('Erreur lors de la recherche d\'équipes handibasket:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router;
