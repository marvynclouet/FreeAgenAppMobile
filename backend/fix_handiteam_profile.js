const axios = require('axios');

const BASE_URL = 'https://freeagenappmobile-production.up.railway.app';

async function fixHanditeamProfile() {
  try {
    console.log('🔧 Correction du profil handiteam...');
    
    // 1. Se connecter en tant que handiteam
    console.log('📝 Connexion handiteam...');
    const login = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'handiteam@gmail.com',
      password: 'Test123'
    });
    
    const token = login.data.token;
    const userId = login.data.user.id;
    console.log('✅ Connecté:', userId, login.data.user.name);
    
    // 2. Créer le profil équipe via l'API handibasket (contournement)
    console.log('📝 Création du profil équipe...');
    const teamProfileData = {
      birth_date: '1990-01-01', // Date fictive pour l'équipe
      handicap_type: 'moteur',
      classification: '3',
      nationality: 'Français',
      club: 'Équipe Handibasket Paris',
      coach: 'Jean Dupont',
      profession: 'Équipe de handibasket',
      position: 'polyvalent',
      championship_level: 'National',
      height: 180,
      weight: 80,
      passport_type: 'Français',
      experience_years: 5,
      level: 'National',
      achievements: 'Champion de France 2023, Vice-champion 2022',
      video_url: 'https://handibasket-paris.fr',
      bio: 'Équipe de handibasket de haut niveau recherchant des joueurs talentueux. Niveau national, toutes positions acceptées.'
    };
    
    try {
      const profileResponse = await axios.put(`${BASE_URL}/api/handibasket/profile`, teamProfileData, {
        headers: { Authorization: `Bearer ${token}` }
      });
      console.log('✅ Profil équipe créé via API handibasket:', profileResponse.data);
    } catch (error) {
      console.log('❌ Erreur profil équipe:', error.response?.data || error.message);
    }
    
    // 3. Tester la récupération du profil
    console.log('🔍 Test de récupération du profil...');
    try {
      const getProfileResponse = await axios.get(`${BASE_URL}/api/handibasket/profile`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      console.log('✅ Profil récupéré:', getProfileResponse.data);
    } catch (error) {
      console.log('❌ Erreur récupération:', error.response?.data || error.message);
    }
    
    // 4. Créer une annonce pour l'équipe
    console.log('📝 Création d\'une annonce équipe...');
    const teamAnnouncement = {
      title: 'Recherche joueurs handibasket niveau national',
      description: 'Équipe de handibasket de Paris recherche des joueurs talentueux pour la saison 2024-2025. Niveau national requis, toutes positions acceptées.',
      type: 'equipe_recherche_joueur',
      requirements: 'Niveau national, expérience handibasket, motivation',
      salary_range: '5000-10000€',
      location: 'Paris, Île-de-France'
    };
    
    try {
      const announcementResponse = await axios.post(`${BASE_URL}/api/annonces`, teamAnnouncement, {
        headers: { Authorization: `Bearer ${token}` }
      });
      console.log('✅ Annonce équipe créée:', announcementResponse.data);
    } catch (error) {
      console.log('❌ Erreur annonce équipe:', error.response?.data || error.message);
    }
    
    console.log('🎉 Profil handiteam corrigé !');
    
  } catch (error) {
    console.error('❌ Erreur générale:', error.response?.data || error.message);
  }
}

fixHanditeamProfile();

