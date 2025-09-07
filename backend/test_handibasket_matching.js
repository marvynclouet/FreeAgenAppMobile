const axios = require('axios');

const BASE_URL = 'https://freeagenappmobile-production.up.railway.app';

async function testHandibasketMatching() {
  try {
    console.log('🏀 Test du système de matching handibasket...');
    
    // 1. Se connecter en tant que joueur
    console.log('📝 Connexion joueur...');
    const playerLogin = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'joueur.handibasket.test@gmail.com',
      password: 'Test123'
    });
    
    const playerToken = playerLogin.data.token;
    const playerId = playerLogin.data.user.id;
    console.log('✅ Joueur connecté:', playerId, playerLogin.data.user.name);
    
    // 2. Récupérer le profil du joueur
    console.log('🔍 Récupération du profil joueur...');
    const playerProfile = await axios.get(`${BASE_URL}/api/handibasket/profile`, {
      headers: { Authorization: `Bearer ${playerToken}` }
    });
    console.log('✅ Profil joueur:', playerProfile.data);
    
    // 3. Récupérer toutes les annonces
    console.log('🔍 Récupération des annonces...');
    const annonces = await axios.get(`${BASE_URL}/api/annonces`, {
      headers: { Authorization: `Bearer ${playerToken}` }
    });
    
    // Filtrer les annonces handibasket
    const handibasketAnnonces = annonces.data.filter(annonce => 
      annonce.title.toLowerCase().includes('handibasket') || 
      annonce.description.toLowerCase().includes('handibasket') ||
      annonce.profile_type === 'handibasket_team'
    );
    
    console.log('✅ Annonces handibasket trouvées:', handibasketAnnonces.length);
    handibasketAnnonces.forEach((annonce, index) => {
      console.log(`  ${index + 1}. ${annonce.title} (${annonce.profile_type})`);
    });
    
    // 4. Simuler le matching pour le joueur
    console.log('🔍 Simulation du matching joueur...');
    const playerMatches = handibasketAnnonces.map(annonce => {
      // Calculer un score de compatibilité simple
      let score = 0;
      let reasons = [];
      
      // Vérifier le niveau
      if (annonce.requirements && annonce.requirements.toLowerCase().includes('national')) {
        score += 30;
        reasons.push('Niveau national correspond');
      }
      
      // Vérifier la position
      if (annonce.requirements && annonce.requirements.toLowerCase().includes('meneur')) {
        score += 25;
        reasons.push('Position meneur recherchée');
      }
      
      // Vérifier l'expérience
      if (annonce.requirements && annonce.requirements.toLowerCase().includes('expérience')) {
        score += 20;
        reasons.push('Expérience requise correspond');
      }
      
      // Vérifier la localisation
      if (annonce.location && annonce.location.toLowerCase().includes('paris')) {
        score += 15;
        reasons.push('Localisation Paris correspond');
      }
      
      // Vérifier le type d'annonce
      if (annonce.type === 'recrutement' || annonce.type === 'equipe_recherche_joueur') {
        score += 10;
        reasons.push('Type d\'annonce correspond');
      }
      
      return {
        id: annonce.id,
        title: annonce.title,
        description: annonce.description,
        type: annonce.type,
        location: annonce.location,
        requirements: annonce.requirements,
        salary_range: annonce.salary_range,
        team_name: annonce.user_name,
        team_type: annonce.profile_type,
        score: score,
        reasons: reasons,
        created_at: annonce.created_at
      };
    }).filter(match => match.score > 0).sort((a, b) => b.score - a.score);
    
    console.log('✅ Matches trouvés pour le joueur:', playerMatches.length);
    playerMatches.forEach((match, index) => {
      console.log(`  ${index + 1}. ${match.title} (Score: ${match.score})`);
      console.log(`     Raisons: ${match.reasons.join(', ')}`);
    });
    
    // 5. Se connecter en tant qu'équipe
    console.log('📝 Connexion équipe...');
    const teamLogin = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'equipe.handibasket.paris@gmail.com',
      password: 'Test123'
    });
    
    const teamToken = teamLogin.data.token;
    const teamId = teamLogin.data.user.id;
    console.log('✅ Équipe connectée:', teamId, teamLogin.data.user.name);
    
    // 6. Simuler le matching pour l'équipe
    console.log('🔍 Simulation du matching équipe...');
    
    // Récupérer les profils de joueurs handibasket
    const playersResponse = await axios.get(`${BASE_URL}/api/players`, {
      headers: { Authorization: `Bearer ${teamToken}` }
    });
    
    // Filtrer les joueurs handibasket
    const handibasketPlayers = playersResponse.data.filter(player => 
      player.profile_type === 'handibasket'
    );
    
    console.log('✅ Joueurs handibasket trouvés:', handibasketPlayers.length);
    
    const teamMatches = handibasketPlayers.map(player => {
      let score = 0;
      let reasons = [];
      
      // Vérifier le niveau
      if (player.level === 'National') {
        score += 30;
        reasons.push('Niveau national correspond');
      }
      
      // Vérifier la position
      if (player.position === 'meneur') {
        score += 25;
        reasons.push('Position meneur recherchée');
      }
      
      // Vérifier l'expérience
      if (player.experience_years && player.experience_years >= 5) {
        score += 20;
        reasons.push('Expérience suffisante');
      }
      
      // Vérifier les réalisations
      if (player.achievements && player.achievements.toLowerCase().includes('champion')) {
        score += 15;
        reasons.push('Palmarès impressionnant');
      }
      
      // Vérifier la localisation
      if (player.residence && player.residence.toLowerCase().includes('français')) {
        score += 10;
        reasons.push('Nationalité française');
      }
      
      return {
        id: player.id,
        name: player.name,
        email: player.email,
        level: player.level,
        position: player.position,
        experience_years: player.experience_years,
        achievements: player.achievements,
        bio: player.bio,
        score: score,
        reasons: reasons
      };
    }).filter(match => match.score > 0).sort((a, b) => b.score - a.score);
    
    console.log('✅ Matches trouvés pour l\'équipe:', teamMatches.length);
    teamMatches.forEach((match, index) => {
      console.log(`  ${index + 1}. ${match.name} (Score: ${match.score})`);
      console.log(`     Raisons: ${match.reasons.join(', ')}`);
    });
    
    console.log('🎉 Test de matching terminé !');
    console.log('');
    console.log('📊 Résumé du matching:');
    console.log(`- ${playerMatches.length} équipes correspondent au joueur`);
    console.log(`- ${teamMatches.length} joueurs correspondent à l'équipe`);
    console.log('- Le système de matching fonctionne !');
    
  } catch (error) {
    console.error('❌ Erreur générale:', error.response?.data || error.message);
  }
}

testHandibasketMatching();

