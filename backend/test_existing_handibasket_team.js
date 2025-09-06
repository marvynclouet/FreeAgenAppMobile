const axios = require('axios');

const BASE_URL = 'https://freeagenappmobile-production.up.railway.app';

async function testExistingHandibasketTeam() {
  try {
    console.log('🧪 Test avec l\'équipe handibasket existante...\n');

    // 1. Se connecter avec l'équipe existante
    console.log('1. Connexion de l\'équipe handibasket...');
    const teamLogin = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'handiteam@gmail.com',
      password: 'Test123'
    });
    
    const teamToken = teamLogin.data.token;
    const teamUser = teamLogin.data.user;
    console.log('✅ Équipe connectée:', teamUser.name, '- Type:', teamUser.profile_type);

    // 2. Vérifier le profil de l'équipe
    console.log('\n2. Vérification du profil équipe...');
    try {
      const teamProfile = await axios.get(`${BASE_URL}/api/handibasket-teams/profile`, {
        headers: { Authorization: `Bearer ${teamToken}` }
      });
      console.log('✅ Profil équipe:', teamProfile.data);
    } catch (error) {
      console.log('⚠️ Profil équipe non trouvé, création...');
      await axios.put(`${BASE_URL}/api/handibasket-teams/profile`, {
        team_name: 'Lions Handibasket Paris',
        city: 'Paris',
        region: 'Île-de-France',
        level: 'National',
        division: 'Division 1',
        description: 'Équipe de handibasket de haut niveau recherchant des joueurs talentueux',
        website: 'https://lions-handibasket.fr',
        contact_phone: '01 23 45 67 89'
      }, {
        headers: { Authorization: `Bearer ${teamToken}` }
      });
      console.log('✅ Profil équipe créé');
    }

    // 3. Créer une annonce de recrutement
    console.log('\n3. Création d\'une annonce de recrutement...');
    const announcement = await axios.post(`${BASE_URL}/api/annonces`, {
      title: 'Recrutement joueur handibasket - Poste meneur',
      description: 'Notre équipe de handibasket de niveau national recherche un meneur expérimenté pour la saison 2024-2025. Nous cherchons un joueur motivé, avec de l\'expérience en handibasket et capable de diriger l\'équipe.',
      type: 'recrutement',
      requirements: 'Joueur handibasket de niveau régional minimum, poste meneur, expérience de 3 ans minimum, classification 1-2',
      salary_range: 'Selon expérience',
      location: 'Paris, Île-de-France'
    }, {
      headers: { Authorization: `Bearer ${teamToken}` }
    });
    console.log('✅ Annonce créée:', announcement.data.title);

    // 4. Se connecter avec un joueur handibasket existant
    console.log('\n4. Connexion d\'un joueur handibasket...');
    const playerLogin = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'joueur.test.handibasket@gmail.com',
      password: 'Test123'
    });
    
    const playerToken = playerLogin.data.token;
    const playerUser = playerLogin.data.user;
    console.log('✅ Joueur connecté:', playerUser.name, '- Type:', playerUser.profile_type);

    // 5. Tester le matching pour le joueur
    console.log('\n5. Test du matching pour le joueur...');
    const playerMatches = await axios.get(`${BASE_URL}/api/matching/top-matches?limit=5`, {
      headers: { Authorization: `Bearer ${playerToken}` }
    });
    
    console.log('Réponse du matching:', JSON.stringify(playerMatches.data, null, 2));
    
    if (Array.isArray(playerMatches.data)) {
      console.log(`✅ ${playerMatches.data.length} matches trouvés pour le joueur:`);
      playerMatches.data.forEach((match, index) => {
        console.log(`   ${index + 1}. ${match.name} (${match.type}) - Score: ${match.compatibilityScore}%`);
        console.log(`      Annonce: ${match.advertisement.title}`);
        console.log(`      Raisons: ${match.reasons.join(', ')}`);
      });
    } else {
      console.log('❌ Réponse du matching invalide:', playerMatches.data);
    }

    // 6. Tester le matching pour l'équipe
    console.log('\n6. Test du matching pour l\'équipe...');
    const teamMatches = await axios.get(`${BASE_URL}/api/matching/top-matches?limit=5`, {
      headers: { Authorization: `Bearer ${teamToken}` }
    });
    
    console.log(`✅ ${teamMatches.data.length} matches trouvés pour l'équipe:`);
    teamMatches.data.forEach((match, index) => {
      console.log(`   ${index + 1}. ${match.name} (${match.type}) - Score: ${match.compatibilityScore}%`);
      if (match.position) console.log(`      Poste: ${match.position}, Niveau: ${match.level}`);
      console.log(`      Raisons: ${match.reasons.join(', ')}`);
    });

    console.log('\n🎉 Test du matching handibasket terminé avec succès !');

  } catch (error) {
    console.error('❌ Erreur lors du test:', error.response?.data || error.message);
  }
}

testExistingHandibasketTeam();
