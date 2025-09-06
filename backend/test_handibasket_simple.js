const axios = require('axios');

const BASE_URL = 'https://freeagenappmobile-production.up.railway.app';

async function testHandibasketSimple() {
  try {
    console.log('🏀 Test simple du système handibasket...');
    
    // 1. Se connecter en tant qu'équipe
    console.log('📝 Connexion équipe...');
    const teamLogin = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'equipe.handibasket.paris@gmail.com',
      password: 'Test123'
    });
    
    const teamToken = teamLogin.data.token;
    const teamId = teamLogin.data.user.id;
    console.log('✅ Équipe connectée:', teamId, teamLogin.data.user.name);
    
    // 2. Se connecter en tant que joueur
    console.log('📝 Connexion joueur...');
    const playerLogin = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'joueur.handibasket.test@gmail.com',
      password: 'Test123'
    });
    
    const playerToken = playerLogin.data.token;
    const playerId = playerLogin.data.user.id;
    console.log('✅ Joueur connecté:', playerId, playerLogin.data.user.name);
    
    // 3. Tester la route de profil équipe avec la nouvelle route
    console.log('🔍 Test profil équipe...');
    try {
      const teamProfile = await axios.get(`${BASE_URL}/api/handibasket-teams/my-profile`, {
        headers: { Authorization: `Bearer ${teamToken}` }
      });
      console.log('✅ Profil équipe:', teamProfile.data);
    } catch (error) {
      console.log('❌ Erreur profil équipe:', error.response?.data || error.message);
    }
    
    // 4. Tester la route de profil joueur
    console.log('🔍 Test profil joueur...');
    try {
      const playerProfile = await axios.get(`${BASE_URL}/api/handibasket/profile`, {
        headers: { Authorization: `Bearer ${playerToken}` }
      });
      console.log('✅ Profil joueur:', playerProfile.data);
    } catch (error) {
      console.log('❌ Erreur profil joueur:', error.response?.data || error.message);
    }
    
    // 5. Tester la route de liste des équipes
    console.log('🔍 Test liste équipes...');
    try {
      const teamsList = await axios.get(`${BASE_URL}/api/handibasket-teams/all-teams`);
      console.log('✅ Liste équipes:', teamsList.data);
    } catch (error) {
      console.log('❌ Erreur liste équipes:', error.response?.data || error.message);
    }
    
    // 6. Tester la route de recherche d'équipes
    console.log('🔍 Test recherche équipes...');
    try {
      const teamsSearch = await axios.get(`${BASE_URL}/api/handibasket-teams/find-teams`);
      console.log('✅ Recherche équipes:', teamsSearch.data);
    } catch (error) {
      console.log('❌ Erreur recherche équipes:', error.response?.data || error.message);
    }
    
    // 7. Tester la route de récupération d'équipe par ID
    console.log('🔍 Test équipe par ID...');
    try {
      const teamById = await axios.get(`${BASE_URL}/api/handibasket-teams/get-team/${teamId}`);
      console.log('✅ Équipe par ID:', teamById.data);
    } catch (error) {
      console.log('❌ Erreur équipe par ID:', error.response?.data || error.message);
    }
    
    console.log('🎉 Test terminé !');
    
  } catch (error) {
    console.error('❌ Erreur générale:', error.response?.data || error.message);
  }
}

testHandibasketSimple();
