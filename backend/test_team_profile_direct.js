const axios = require('axios');

const BASE_URL = 'https://freeagenappmobile-production.up.railway.app';

async function testTeamProfile() {
  try {
    console.log('🔍 Test direct du profil d\'équipe...');
    
    // 1. Se connecter
    const loginResponse = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'handiteam.test@gmail.com',
      password: 'Test123'
    });
    
    const token = loginResponse.data.token;
    const userId = loginResponse.data.user.id;
    console.log('✅ Connecté avec userId:', userId);
    
    // 2. Tester la route de recherche qui fonctionne
    console.log('🔍 Test de la route de recherche...');
    const searchResponse = await axios.get(`${BASE_URL}/api/handibasket-teams/find-teams`);
    console.log('✅ Route de recherche:', searchResponse.data);
    
    // 3. Tester la route de liste
    console.log('🔍 Test de la route de liste...');
    const listResponse = await axios.get(`${BASE_URL}/api/handibasket-teams/all-teams`);
    console.log('✅ Route de liste:', listResponse.data);
    
    // 4. Tester la route de profil
    console.log('🔍 Test de la route de profil...');
    const profileResponse = await axios.get(`${BASE_URL}/api/handibasket-teams/my-profile`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Route de profil:', profileResponse.data);
    
  } catch (error) {
    console.error('❌ Erreur:', error.response?.data || error.message);
  }
}

testTeamProfile();
