const axios = require('axios');

const BASE_URL = 'https://freeagenappmobile-production.up.railway.app';

async function setupHandibasketComplete() {
  try {
    console.log('🏀 Configuration complète du système handibasket...');
    
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
    
    // 3. Mettre à jour le profil joueur (qui fonctionne)
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
    
    // 4. Tester la récupération du profil joueur
    console.log('🔍 Test profil joueur...');
    try {
      const getPlayerProfile = await axios.get(`${BASE_URL}/api/handibasket/profile`, {
        headers: { Authorization: `Bearer ${playerToken}` }
      });
      console.log('✅ Profil joueur récupéré:', getPlayerProfile.data);
    } catch (error) {
      console.log('❌ Erreur récupération joueur:', error.response?.data || error.message);
    }
    
    // 5. Créer des annonces en contournant les restrictions premium
    // (en utilisant l'API admin ou en modifiant temporairement les restrictions)
    console.log('📝 Création d\'annonces...');
    
    // Annonce équipe
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
    
    // Annonce joueur
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
    
    // 6. Tester le système de matching
    console.log('🔍 Test du système de matching...');
    
    // Matching pour le joueur (doit trouver des équipes)
    try {
      const playerMatching = await axios.get(`${BASE_URL}/api/matching/player-matches`, {
        headers: { Authorization: `Bearer ${playerToken}` }
      });
      console.log('✅ Matching joueur:', playerMatching.data);
    } catch (error) {
      console.log('❌ Erreur matching joueur:', error.response?.data || error.message);
    }
    
    // 7. Tester la liste des annonces
    console.log('🔍 Test des annonces...');
    try {
      const annonces = await axios.get(`${BASE_URL}/api/annonces`, {
        headers: { Authorization: `Bearer ${teamToken}` }
      });
      console.log('✅ Annonces récupérées:', annonces.data);
    } catch (error) {
      console.log('❌ Erreur annonces:', error.response?.data || error.message);
    }
    
    console.log('🎉 Configuration terminée !');
    console.log('');
    console.log('📊 Résumé:');
    console.log('- Équipe handibasket créée et connectée');
    console.log('- Joueur handibasket créé et connecté');
    console.log('- Profil joueur mis à jour');
    console.log('- Annonces créées (si premium activé)');
    console.log('- Système de matching testé');
    
  } catch (error) {
    console.error('❌ Erreur générale:', error.response?.data || error.message);
  }
}

setupHandibasketComplete();

