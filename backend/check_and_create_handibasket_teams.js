const axios = require('axios');

const BASE_URL = 'https://freeagenappmobile-production.up.railway.app';

async function checkDatabase() {
  try {
    console.log('🔍 Vérification de la base de données...');
    
    // 1. Vérifier les utilisateurs handibasket_team
    const usersResponse = await axios.get(`${BASE_URL}/api/admin/users`);
    console.log('👥 Utilisateurs handibasket_team:', usersResponse.data.filter(u => u.profile_type === 'handibasket_team'));
    
    // 2. Vérifier les profils handibasket_team
    const teamsResponse = await axios.get(`${BASE_URL}/api/admin/handibasket-teams`);
    console.log('🏀 Équipes handibasket:', teamsResponse.data);
    
    // 3. Créer une équipe handibasket de test si elle n'existe pas
    const testTeam = {
      name: 'Équipe Handibasket Test',
      email: 'handiteam.test@gmail.com',
      password: 'Test123',
      profile_type: 'handibasket_team'
    };
    
    try {
      // Essayer de se connecter d'abord
      const loginResponse = await axios.post(`${BASE_URL}/api/auth/login`, {
        email: testTeam.email,
        password: testTeam.password
      });
      console.log('✅ Équipe de test existe déjà:', loginResponse.data.user);
    } catch (error) {
      if (error.response?.status === 401) {
        console.log('❌ Équipe de test n\'existe pas, création...');
        
        // Créer l'équipe
        const registerResponse = await axios.post(`${BASE_URL}/api/auth/register`, testTeam);
        console.log('✅ Équipe créée:', registerResponse.data);
        
        // Mettre à jour le profil
        const token = registerResponse.data.token;
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
      }
    }
    
    // 4. Vérifier à nouveau après création
    const finalCheck = await axios.get(`${BASE_URL}/api/handibasket-teams/all-teams`);
    console.log('🏀 Équipes handibasket après création:', finalCheck.data);
    
  } catch (error) {
    console.error('❌ Erreur:', error.response?.data || error.message);
  }
}

checkDatabase();
