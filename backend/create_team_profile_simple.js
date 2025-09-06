const axios = require('axios');

const BASE_URL = 'https://freeagenappmobile-production.up.railway.app';

async function createTeamProfileSimple() {
  try {
    console.log('🏀 Création simple du profil équipe...');
    
    // 1. Se connecter en tant qu'équipe
    console.log('📝 Connexion équipe...');
    const teamLogin = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'equipe.handibasket.paris@gmail.com',
      password: 'Test123'
    });
    
    const teamToken = teamLogin.data.token;
    const teamId = teamLogin.data.user.id;
    console.log('✅ Équipe connectée:', teamId, teamLogin.data.user.name);
    
    // 2. Utiliser l'API handibasket existante pour créer le profil équipe
    // (en modifiant temporairement le type de profil)
    console.log('📝 Création du profil équipe via API handibasket...');
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
      const teamProfileResponse = await axios.put(`${BASE_URL}/api/handibasket/profile`, teamProfileData, {
        headers: { Authorization: `Bearer ${teamToken}` }
      });
      console.log('✅ Profil équipe créé via API handibasket:', teamProfileResponse.data);
    } catch (error) {
      console.log('❌ Erreur profil équipe:', error.response?.data || error.message);
    }
    
    // 3. Tester la récupération du profil
    console.log('🔍 Test de récupération du profil...');
    try {
      const getProfileResponse = await axios.get(`${BASE_URL}/api/handibasket/profile`, {
        headers: { Authorization: `Bearer ${teamToken}` }
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
      const teamAnnouncementResponse = await axios.post(`${BASE_URL}/api/annonces`, teamAnnouncement, {
        headers: { Authorization: `Bearer ${teamToken}` }
      });
      console.log('✅ Annonce équipe créée:', teamAnnouncementResponse.data);
    } catch (error) {
      console.log('❌ Erreur annonce équipe:', error.response?.data || error.message);
    }
    
    // 5. Se connecter en tant que joueur
    console.log('📝 Connexion joueur...');
    const playerLogin = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'joueur.handibasket.test@gmail.com',
      password: 'Test123'
    });
    
    const playerToken = playerLogin.data.token;
    const playerId = playerLogin.data.user.id;
    console.log('✅ Joueur connecté:', playerId, playerLogin.data.user.name);
    
    // 6. Mettre à jour le profil joueur
    console.log('📝 Mise à jour du profil joueur...');
    const playerProfileData = {
      birth_date: '1995-06-15',
      handicap_type: 'moteur',
      classification: '3',
      nationality: 'Français',
      club: 'Club Handibasket Test',
      coach: 'Coach Test',
      profession: 'Développeur',
      position: 'meneur',
      championship_level: 'National',
      height: 185,
      weight: 80,
      passport_type: 'Français',
      experience_years: 8,
      level: 'National',
      achievements: 'Champion de France 2022, Sélectionné en équipe de France',
      video_url: 'https://youtube.com/watch?v=test',
      bio: 'Joueur passionné de handibasket avec 8 ans d\'expérience au niveau national. Recherche une équipe de haut niveau pour continuer ma progression.'
    };
    
    try {
      const playerProfileResponse = await axios.put(`${BASE_URL}/api/handibasket/profile`, playerProfileData, {
        headers: { Authorization: `Bearer ${playerToken}` }
      });
      console.log('✅ Profil joueur mis à jour:', playerProfileResponse.data);
    } catch (error) {
      console.log('❌ Erreur profil joueur:', error.response?.data || error.message);
    }
    
    // 7. Créer une annonce pour le joueur
    console.log('📝 Création d\'une annonce joueur...');
    const playerAnnouncement = {
      title: 'Joueur handibasket niveau national cherche équipe',
      description: 'Joueur expérimenté de handibasket niveau national recherche une équipe de haut niveau pour la saison 2024-2025. Position meneur, 8 ans d\'expérience.',
      type: 'joueur_recherche_club',
      requirements: 'Équipe de niveau national, entraînements réguliers',
      salary_range: '5000-8000€',
      location: 'Paris, Île-de-France'
    };
    
    try {
      const playerAnnouncementResponse = await axios.post(`${BASE_URL}/api/annonces`, playerAnnouncement, {
        headers: { Authorization: `Bearer ${playerToken}` }
      });
      console.log('✅ Annonce joueur créée:', playerAnnouncementResponse.data);
    } catch (error) {
      console.log('❌ Erreur annonce joueur:', error.response?.data || error.message);
    }
    
    console.log('🎉 Configuration terminée !');
    
  } catch (error) {
    console.error('❌ Erreur générale:', error.response?.data || error.message);
  }
}

createTeamProfileSimple();
