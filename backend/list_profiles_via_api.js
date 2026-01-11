const axios = require('axios');

// Configuration de l'API backend
const API_BASE_URL = 'https://backend-hmnlcriwn-marvynshes-projects.vercel.app';

async function listAllProfiles() {
  try {
    console.log('📋 Liste de tous les profils via l\'API backend...');
    console.log('================================================\n');

    // 1. Lister les équipes
    console.log('🏀 ÉQUIPES:');
    console.log('===========');
    try {
      const teamsResponse = await axios.get(`${API_BASE_URL}/api/teams`);
      const teams = teamsResponse.data;
      
      console.log(`Total: ${teams.length} équipes\n`);
      teams.forEach((team, index) => {
        console.log(`${index + 1}. ID: ${team.id}`);
        console.log(`   Nom: ${team.name}`);
        console.log(`   Ville: ${team.city}`);
        console.log(`   Description: ${team.description ? team.description.substring(0, 100) + '...' : 'Aucune'}`);
        console.log(`   Niveau: ${team.level || 'Non spécifié'}`);
        console.log(`   Division: ${team.division || 'Non spécifiée'}`);
        console.log(`   Année: ${team.founded_year || 'Non spécifiée'}`);
        console.log('   ---');
      });
    } catch (error) {
      console.log('❌ Erreur lors de la récupération des équipes:', error.message);
    }

    // 2. Lister les joueurs
    console.log('\n🏃 JOUEURS:');
    console.log('===========');
    try {
      const playersResponse = await axios.get(`${API_BASE_URL}/api/players`);
      const players = playersResponse.data;
      
      console.log(`Total: ${players.length} joueurs\n`);
      players.forEach((player, index) => {
        console.log(`${index + 1}. ID: ${player.id}`);
        console.log(`   Nom: ${player.name || 'Non spécifié'}`);
        console.log(`   Email: ${player.email || 'Non spécifié'}`);
        console.log(`   Âge: ${player.age || 'Non spécifié'}`);
        console.log(`   Poste: ${player.position || 'Non spécifié'}`);
        console.log(`   Taille: ${player.height || 'Non spécifiée'}`);
        console.log(`   Poids: ${player.weight || 'Non spécifié'}`);
        console.log(`   Niveau: ${player.level || 'Non spécifié'}`);
        console.log('   ---');
      });
    } catch (error) {
      console.log('❌ Erreur lors de la récupération des joueurs:', error.message);
    }

    // 3. Lister les clubs
    console.log('\n🏢 CLUBS:');
    console.log('=========');
    try {
      const clubsResponse = await axios.get(`${API_BASE_URL}/api/clubs`);
      const clubs = clubsResponse.data;
      
      console.log(`Total: ${clubs.length} clubs\n`);
      clubs.forEach((club, index) => {
        console.log(`${index + 1}. ID: ${club.id}`);
        console.log(`   Nom: ${club.name || 'Non spécifié'}`);
        console.log(`   Email: ${club.email || 'Non spécifié'}`);
        console.log(`   Ville: ${club.city || 'Non spécifiée'}`);
        console.log(`   Niveau: ${club.level || 'Non spécifié'}`);
        console.log(`   Division: ${club.division || 'Non spécifiée'}`);
        console.log('   ---');
      });
    } catch (error) {
      console.log('❌ Erreur lors de la récupération des clubs:', error.message);
    }

    // 4. Lister les entraîneurs
    console.log('\n👨‍🏫 ENTRAÎNEURS:');
    console.log('=================');
    try {
      const coachesResponse = await axios.get(`${API_BASE_URL}/api/coaches`);
      const coaches = coachesResponse.data;
      
      console.log(`Total: ${coaches.length} entraîneurs\n`);
      coaches.forEach((coach, index) => {
        console.log(`${index + 1}. ID: ${coach.id}`);
        console.log(`   Nom: ${coach.name || 'Non spécifié'}`);
        console.log(`   Email: ${coach.email || 'Non spécifié'}`);
        console.log(`   Expérience: ${coach.experience_years || 'Non spécifiée'} ans`);
        console.log(`   Niveau: ${coach.level || 'Non spécifié'}`);
        console.log(`   Spécialisation: ${coach.specialization || 'Non spécifiée'}`);
        console.log('   ---');
      });
    } catch (error) {
      console.log('❌ Erreur lors de la récupération des entraîneurs:', error.message);
    }

    // 5. Lister les profils handibasket
    console.log('\n♿ PROFILS HANDIBASKET:');
    console.log('======================');
    try {
      const handibasketResponse = await axios.get(`${API_BASE_URL}/api/handibasket`);
      const handibasket = handibasketResponse.data;
      
      console.log(`Total: ${handibasket.length} profils handibasket\n`);
      handibasket.forEach((profile, index) => {
        console.log(`${index + 1}. ID: ${profile.id}`);
        console.log(`   Nom: ${profile.name || 'Non spécifié'}`);
        console.log(`   Email: ${profile.email || 'Non spécifié'}`);
        console.log(`   Âge: ${profile.age || 'Non spécifié'}`);
        console.log(`   Poste: ${profile.position || 'Non spécifié'}`);
        console.log(`   Type handicap: ${profile.handicap_type || 'Non spécifié'}`);
        console.log(`   Niveau: ${profile.level || 'Non spécifié'}`);
        console.log('   ---');
      });
    } catch (error) {
      console.log('❌ Erreur lors de la récupération des profils handibasket:', error.message);
    }

    // 6. Vérifier la santé de l'API
    console.log('\n🔍 VÉRIFICATION DE L\'API:');
    console.log('==========================');
    try {
      const healthResponse = await axios.get(`${API_BASE_URL}/api/health`);
      console.log('✅ API Backend:', healthResponse.data);
    } catch (error) {
      console.log('❌ Erreur API Backend:', error.message);
    }

    console.log('\n✅ Liste terminée!');

  } catch (error) {
    console.error('❌ Erreur générale:', error.message);
  }
}

// Exécuter le script
listAllProfiles();

