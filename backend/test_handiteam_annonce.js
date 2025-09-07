const axios = require('axios');

const BASE_URL = 'https://freeagenappmobile-production.up.railway.app';

async function testHanditeamAnnonce() {
  try {
    console.log('🔧 Test de création d\'annonce handiteam...');
    
    // 1. Se connecter en tant que handiteam
    console.log('📝 Connexion handiteam...');
    const login = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'handiteam@gmail.com',
      password: 'Test123'
    });
    
    const token = login.data.token;
    const userId = login.data.user.id;
    console.log('✅ Connecté:', userId, login.data.user.name);
    
    // 2. Créer une annonce avec un type valide
    console.log('📝 Création d\'une annonce...');
    const teamAnnouncement = {
      title: 'Recherche joueurs handibasket niveau national',
      description: 'Équipe de handibasket de Paris recherche des joueurs talentueux pour la saison 2024-2025. Niveau national requis, toutes positions acceptées.',
      type: 'recrutement', // Type valide
      requirements: 'Niveau national, expérience handibasket, motivation',
      salary_range: '5000-10000€',
      location: 'Paris, Île-de-France'
    };
    
    try {
      const announcementResponse = await axios.post(`${BASE_URL}/api/annonces`, teamAnnouncement, {
        headers: { Authorization: `Bearer ${token}` }
      });
      console.log('✅ Annonce créée:', announcementResponse.data);
    } catch (error) {
      console.log('❌ Erreur annonce:', error.response?.data || error.message);
    }
    
    // 3. Tester la récupération des annonces
    console.log('🔍 Test de récupération des annonces...');
    try {
      const annoncesResponse = await axios.get(`${BASE_URL}/api/annonces`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      console.log('✅ Annonces récupérées:', annoncesResponse.data.length);
      
      // Afficher les annonces handibasket
      const handibasketAnnonces = annoncesResponse.data.filter(annonce => 
        annonce.title.toLowerCase().includes('handibasket') || 
        annonce.description.toLowerCase().includes('handibasket')
      );
      console.log('✅ Annonces handibasket:', handibasketAnnonces.length);
      handibasketAnnonces.forEach((annonce, index) => {
        console.log(`  ${index + 1}. ${annonce.title} (${annonce.type})`);
      });
    } catch (error) {
      console.log('❌ Erreur récupération annonces:', error.response?.data || error.message);
    }
    
    console.log('🎉 Test terminé !');
    
  } catch (error) {
    console.error('❌ Erreur générale:', error.response?.data || error.message);
  }
}

testHanditeamAnnonce();

