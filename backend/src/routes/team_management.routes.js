const express = require('express');
const router = express.Router();
const pool = require('../config/db.config');
const verifyToken = require('../middleware/auth.middleware');

// Récupérer le profil de l'équipe connectée
router.get('/get-profile', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    console.log('🔍 Recherche du profil équipe pour userId:', userId);
    
    const [rows] = await pool.execute(`
      SELECT 
        u.id, u.name, u.email, u.gender, u.nationality,
        htp.*
      FROM users u
      JOIN handibasket_team_profiles htp ON u.id = htp.user_id
      WHERE u.id = ? AND u.profile_type = 'handibasket_team'
    `, [userId]);

    console.log('🔍 Résultat de la requête:', rows.length, 'lignes trouvées');
    console.log('🔍 Données:', rows);

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
router.put('/update-profile', verifyToken, async (req, res) => {
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

module.exports = router;
