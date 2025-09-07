const axios = require('axios');

const BASE_URL = 'https://freeagenappmobile-production.up.railway.app';

async function createTeamProfileViaAPI() {
  try {
    console.log('🏀 Création du profil équipe via API...');
    
    // 1. Se connecter en tant qu'équipe
    console.log('📝 Connexion équipe...');
    const teamLogin = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'equipe.handibasket.paris@gmail.com',
      password: 'Test123'
    });
    
    const teamToken = teamLogin.data.token;
    const teamId = teamLogin.data.user.id;
    console.log('✅ Équipe connectée:', teamId, teamLogin.data.user.name);
    
    // 2. Créer le profil équipe via l'API handibasket (en utilisant la route qui fonctionne)
    console.log('📝 Création du profil équipe...');
    const teamProfileData = {
      team_name: 'Équipe Handibasket Paris',
      city: 'Paris',
      region: 'Île-de-France',
      level: 'National',
      division: 'Division 1',
      founded_year: 2020,
      description: 'Équipe de handibasket de haut niveau recherchant des joueurs talentueux',
      achievements: 'Champion de France 2023, Vice-champion 2022',
      contact_person: 'Jean Dupont',
      phone: '0123456789',
      email_contact: 'contact@handibasket-paris.fr',
      website: 'https://handibasket-paris.fr',
      facilities: 'Gymnase moderne avec équipements adaptés, vestiaires accessibles',
      training_schedule: 'Mardi et Jeudi 19h-21h, Samedi 10h-12h',
      recruitment_needs: 'Recherche joueurs de niveau national, toutes positions',
      budget_range: '5000-10000€',
      accommodation_offered: true,
      transport_offered: true,
      medical_support: true,
      player_requirements: 'Niveau national minimum, expérience handibasket requise, motivation et engagement'
    };
    
    try {
      // Essayer d'abord avec la route handibasket-team-management
      const teamProfileResponse = await axios.put(`${BASE_URL}/api/handibasket-team-management/profile`, teamProfileData, {
        headers: { Authorization: `Bearer ${teamToken}` }
      });
      console.log('✅ Profil équipe créé via handibasket-team-management:', teamProfileResponse.data);
    } catch (error) {
      console.log('❌ Erreur handibasket-team-management:', error.response?.data || error.message);
      
      // Essayer avec la route handibasket-teams
      try {
        const teamProfileResponse2 = await axios.put(`${BASE_URL}/api/handibasket-teams/my-profile`, teamProfileData, {
          headers: { Authorization: `Bearer ${teamToken}` }
        });
        console.log('✅ Profil équipe créé via handibasket-teams:', teamProfileResponse2.data);
      } catch (error2) {
        console.log('❌ Erreur handibasket-teams:', error2.response?.data || error2.message);
        
        // Essayer avec la route team-management
        try {
          const teamProfileResponse3 = await axios.put(`${BASE_URL}/api/team-management/my-profile`, teamProfileData, {
            headers: { Authorization: `Bearer ${teamToken}` }
          });
          console.log('✅ Profil équipe créé via team-management:', teamProfileResponse3.data);
        } catch (error3) {
          console.log('❌ Erreur team-management:', error3.response?.data || error3.message);
        }
      }
    }
    
    // 3. Tester la récupération du profil
    console.log('🔍 Test de récupération du profil...');
    try {
      const getProfileResponse = await axios.get(`${BASE_URL}/api/handibasket-team-management/profile`, {
        headers: { Authorization: `Bearer ${teamToken}` }
      });
      console.log('✅ Profil récupéré via handibasket-team-management:', getProfileResponse.data);
    } catch (error) {
      console.log('❌ Erreur récupération handibasket-team-management:', error.response?.data || error.message);
      
      try {
        const getProfileResponse2 = await axios.get(`${BASE_URL}/api/handibasket-teams/my-profile`, {
          headers: { Authorization: `Bearer ${teamToken}` }
        });
        console.log('✅ Profil récupéré via handibasket-teams:', getProfileResponse2.data);
      } catch (error2) {
        console.log('❌ Erreur récupération handibasket-teams:', error2.response?.data || error2.message);
      }
    }
    
    // 4. Tester la liste des équipes
    console.log('🔍 Test de la liste des équipes...');
    try {
      const teamsListResponse = await axios.get(`${BASE_URL}/api/handibasket-team-management/all`);
      console.log('✅ Liste des équipes via handibasket-team-management:', teamsListResponse.data);
    } catch (error) {
      console.log('❌ Erreur liste handibasket-team-management:', error.response?.data || error.message);
      
      try {
        const teamsListResponse2 = await axios.get(`${BASE_URL}/api/handibasket-teams/all-teams`);
        console.log('✅ Liste des équipes via handibasket-teams:', teamsListResponse2.data);
      } catch (error2) {
        console.log('❌ Erreur liste handibasket-teams:', error2.response?.data || error2.message);
      }
    }
    
    console.log('🎉 Test terminé !');
    
  } catch (error) {
    console.error('❌ Erreur générale:', error.response?.data || error.message);
  }
}

createTeamProfileViaAPI();

