const axios = require('axios');

const BASE_URL = 'https://freeagenappmobile-production.up.railway.app';

async function setupHandibasketSystem() {
  try {
    console.log('🏀 Configuration du système handibasket...');
    
    // 1. Créer une équipe handibasket
    console.log('📝 Création de l\'équipe handibasket...');
    const teamData = {
      name: 'Équipe Handibasket Paris',
      email: 'equipe.handibasket.paris@gmail.com',
      password: 'Test123',
      profile_type: 'handibasket_team'
    };
    
    let teamToken;
    try {
      const teamLogin = await axios.post(`${BASE_URL}/api/auth/login`, {
        email: teamData.email,
        password: teamData.password
      });
      teamToken = teamLogin.data.token;
      console.log('✅ Équipe connectée:', teamLogin.data.user);
    } catch (error) {
      if (error.response?.status === 401) {
        const teamRegister = await axios.post(`${BASE_URL}/api/auth/register`, teamData);
        teamToken = teamRegister.data.token;
        console.log('✅ Équipe créée:', teamRegister.data.user);
      }
    }
    
    // 2. Créer un joueur handibasket
    console.log('📝 Création du joueur handibasket...');
    const playerData = {
      name: 'Joueur Handibasket Test',
      email: 'joueur.handibasket.test@gmail.com',
      password: 'Test123',
      profile_type: 'handibasket'
    };
    
    let playerToken;
    try {
      const playerLogin = await axios.post(`${BASE_URL}/api/auth/login`, {
        email: playerData.email,
        password: playerData.password
      });
      playerToken = playerLogin.data.token;
      console.log('✅ Joueur connecté:', playerLogin.data.user);
    } catch (error) {
      if (error.response?.status === 401) {
        const playerRegister = await axios.post(`${BASE_URL}/api/auth/register`, playerData);
        playerToken = playerRegister.data.token;
        console.log('✅ Joueur créé:', playerRegister.data.user);
      }
    }
    
    // 3. Mettre à jour le profil de l'équipe
    console.log('📝 Mise à jour du profil équipe...');
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
      await axios.put(`${BASE_URL}/api/handibasket-teams/my-profile`, teamProfileData, {
        headers: { Authorization: `Bearer ${teamToken}` }
      });
      console.log('✅ Profil équipe mis à jour');
    } catch (error) {
      console.log('❌ Erreur profil équipe:', error.response?.data || error.message);
    }
    
    // 4. Mettre à jour le profil du joueur
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
      await axios.put(`${BASE_URL}/api/handibasket/profile`, playerProfileData, {
        headers: { Authorization: `Bearer ${playerToken}` }
      });
      console.log('✅ Profil joueur mis à jour');
    } catch (error) {
      console.log('❌ Erreur profil joueur:', error.response?.data || error.message);
    }
    
    // 5. Créer une annonce de l'équipe
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
    
    // 6. Créer une annonce du joueur
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
    
    // 7. Tester le matching
    console.log('🔍 Test du système de matching...');
    
    // Matching pour l'équipe (doit trouver des joueurs)
    try {
      const teamMatching = await axios.get(`${BASE_URL}/api/matching/team-matches`, {
        headers: { Authorization: `Bearer ${teamToken}` }
      });
      console.log('✅ Matching équipe:', teamMatching.data);
    } catch (error) {
      console.log('❌ Erreur matching équipe:', error.response?.data || error.message);
    }
    
    // Matching pour le joueur (doit trouver des équipes)
    try {
      const playerMatching = await axios.get(`${BASE_URL}/api/matching/player-matches`, {
        headers: { Authorization: `Bearer ${playerToken}` }
      });
      console.log('✅ Matching joueur:', playerMatching.data);
    } catch (error) {
      console.log('❌ Erreur matching joueur:', error.response?.data || error.message);
    }
    
    console.log('🎉 Configuration terminée !');
    
  } catch (error) {
    console.error('❌ Erreur générale:', error.response?.data || error.message);
  }
}

setupHandibasketSystem();
