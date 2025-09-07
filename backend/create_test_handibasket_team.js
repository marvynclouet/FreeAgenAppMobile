const axios = require('axios');

const BASE_URL = 'https://freeagenappmobile-production.up.railway.app';

async function createTestTeam() {
  try {
    console.log('🏀 Création d\'une équipe handibasket de test...');
    
    // 1. Créer l'équipe
    const testTeam = {
      name: 'Équipe Handibasket Test',
      email: 'handiteam.test@gmail.com',
      password: 'Test123',
      profile_type: 'handibasket_team'
    };
    
    console.log('📝 Création du compte...');
    const registerResponse = await axios.post(`${BASE_URL}/api/auth/register`, testTeam);
    console.log('✅ Compte créé:', registerResponse.data.user);
    
    // 2. Mettre à jour le profil
    const token = registerResponse.data.token;
    console.log('📝 Mise à jour du profil...');
    
    const profileData = {
      team_name: 'Équipe Handibasket Test',
      city: 'Paris',
      region: 'Île-de-France',
      level: 'National',
      division: 'Division 1',
      founded_year: 2020,
      description: 'Équipe de handibasket de test pour le développement',
      achievements: 'Champion de France 2023',
      contact_person: 'Jean Dupont',
      phone: '0123456789',
      email_contact: 'contact@handiteam.fr',
      website: 'https://handiteam.fr',
      facilities: 'Gymnase moderne avec équipements adaptés',
      training_schedule: 'Mardi et Jeudi 19h-21h',
      recruitment_needs: 'Recherche joueurs de niveau national',
      budget_range: '5000-10000€',
      accommodation_offered: true,
      transport_offered: true,
      medical_support: true,
      player_requirements: 'Niveau national minimum, expérience handibasket requise'
    };
    
    const profileResponse = await axios.put(`${BASE_URL}/api/handibasket-teams/my-profile`, profileData, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Profil mis à jour:', profileResponse.data);
    
    // 3. Tester la récupération du profil
    console.log('🔍 Test de récupération du profil...');
    const getProfileResponse = await axios.get(`${BASE_URL}/api/handibasket-teams/my-profile`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Profil récupéré:', getProfileResponse.data);
    
    // 4. Tester la liste des équipes
    console.log('🔍 Test de la liste des équipes...');
    const teamsResponse = await axios.get(`${BASE_URL}/api/handibasket-teams/all-teams`);
    console.log('✅ Liste des équipes:', teamsResponse.data);
    
  } catch (error) {
    console.error('❌ Erreur:', error.response?.data || error.message);
  }
}

createTestTeam();

