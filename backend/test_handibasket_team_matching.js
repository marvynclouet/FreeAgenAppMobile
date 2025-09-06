const axios = require('axios');

const BASE_URL = 'https://freeagenappmobile-production.up.railway.app';

async function testHandibasketTeamMatching() {
  try {
    console.log('🧪 Test du système de matching handibasket...\n');

    // 1. Créer une équipe handibasket
    console.log('1. Création d\'une équipe handibasket...');
    const teamRegistration = await axios.post(`${BASE_URL}/api/auth/register`, {
      name: 'Équipe Handibasket Test',
      email: 'handiteam@gmail.com',
      password: 'Test123',
      profile_type: 'handibasket_team'
    });
    
    const teamToken = teamRegistration.data.token;
    console.log('✅ Équipe créée avec succès');

    // 2. Mettre à jour le profil de l'équipe
    console.log('\n2. Mise à jour du profil équipe...');
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
    console.log('✅ Profil équipe mis à jour');

    // 3. Créer une annonce de recrutement
    console.log('\n3. Création d\'une annonce de recrutement...');
    const announcement = await axios.post(`${BASE_URL}/api/annonces`, {
      title: 'Recrutement joueur handibasket - Poste meneur',
      description: 'Notre équipe de handibasket de niveau national recherche un meneur expérimenté pour la saison 2024-2025. Nous cherchons un joueur motivé, avec de l\'expérience en handibasket et capable de diriger l\'équipe.',
      type: 'equipe_recherche_joueur',
      requirements: 'Joueur handibasket de niveau régional minimum, poste meneur, expérience de 3 ans minimum, classification 1-2',
      salary_range: 'Selon expérience',
      location: 'Paris, Île-de-France'
    }, {
      headers: { Authorization: `Bearer ${teamToken}` }
    });
    console.log('✅ Annonce créée:', announcement.data.title);

    // 4. Créer un joueur handibasket
    console.log('\n4. Création d\'un joueur handibasket...');
    const playerRegistration = await axios.post(`${BASE_URL}/api/auth/register`, {
      name: 'Joueur Test Handibasket',
      email: 'joueur.test.handibasket@gmail.com',
      password: 'Test123',
      profile_type: 'handibasket'
    });
    
    const playerToken = playerRegistration.data.token;
    console.log('✅ Joueur créé avec succès');

    // 5. Mettre à jour le profil du joueur
    console.log('\n5. Mise à jour du profil joueur...');
    await axios.put(`${BASE_URL}/api/handibasket/profile`, {
      age: 28,
      gender: 'masculin',
      nationality: 'France',
      height: 175,
      weight: 70,
      handicap_type: 'moteur',
      classification: '2',
      position: 'meneur',
      championship_level: 'regional',
      passport_type: 'france',
      experience_years: 5,
      level: 'Amateur',
      residence: 'Paris',
      club: 'Club Handibasket Paris',
      coach: 'Jean Dupont',
      profession: 'Éducateur sportif',
      achievements: 'Champion régional 2023, Vice-champion national 2022',
      bio: 'Joueur handibasket passionné avec 5 ans d\'expérience, spécialisé au poste de meneur. Recherche une équipe de niveau national pour progresser.'
    }, {
      headers: { Authorization: `Bearer ${playerToken}` }
    });
    console.log('✅ Profil joueur mis à jour');

    // 6. Tester le matching pour le joueur
    console.log('\n6. Test du matching pour le joueur...');
    const playerMatches = await axios.get(`${BASE_URL}/api/matching/top-matches?limit=5`, {
      headers: { Authorization: `Bearer ${playerToken}` }
    });
    
    console.log(`✅ ${playerMatches.data.length} matches trouvés pour le joueur:`);
    playerMatches.data.forEach((match, index) => {
      console.log(`   ${index + 1}. ${match.name} (${match.type}) - Score: ${match.compatibilityScore}%`);
      console.log(`      Annonce: ${match.advertisement.title}`);
      console.log(`      Raisons: ${match.reasons.join(', ')}`);
    });

    // 7. Tester le matching pour l'équipe
    console.log('\n7. Test du matching pour l\'équipe...');
    const teamMatches = await axios.get(`${BASE_URL}/api/matching/top-matches?limit=5`, {
      headers: { Authorization: `Bearer ${teamToken}` }
    });
    
    console.log(`✅ ${teamMatches.data.length} matches trouvés pour l'équipe:`);
    teamMatches.data.forEach((match, index) => {
      console.log(`   ${index + 1}. ${match.name} (${match.type}) - Score: ${match.compatibilityScore}%`);
      console.log(`      Poste: ${match.position}, Niveau: ${match.level}`);
      console.log(`      Raisons: ${match.reasons.join(', ')}`);
    });

    console.log('\n🎉 Test du matching handibasket terminé avec succès !');

  } catch (error) {
    console.error('❌ Erreur lors du test:', error.response?.data || error.message);
  }
}

testHandibasketTeamMatching();
