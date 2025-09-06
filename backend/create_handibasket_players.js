const axios = require('axios');

const BASE_URL = 'https://freeagenappmobile-production.up.railway.app';

async function createHandibasketPlayers() {
  try {
    console.log('🏀 Création de joueurs handibasket correspondants aux annonces...\n');

    const players = [
      {
        name: 'Marc Dubois',
        email: 'marc.dubois.handibasket@gmail.com',
        password: 'Test123',
        profile: {
          age: 25,
          gender: 'masculin',
          nationality: 'France',
          height: 180,
          weight: 75,
          handicap_type: 'moteur',
          classification: '1',
          position: 'meneur',
          championship_level: 'national',
          passport_type: 'france',
          experience_years: 6,
          level: 'Amateur',
          residence: 'Paris',
          club: 'Club Handibasket Paris',
          coach: 'Jean Dupont',
          profession: 'Éducateur sportif',
          achievements: 'Champion national 2023, Vice-champion européen 2022',
          bio: 'Joueur handibasket de haut niveau, spécialisé au poste de meneur. Recherche une équipe de niveau national pour continuer à progresser.'
        }
      },
      {
        name: 'Sophie Martin',
        email: 'sophie.martin.handibasket@gmail.com',
        password: 'Test123',
        profile: {
          age: 23,
          gender: 'féminin',
          nationality: 'France',
          height: 165,
          weight: 60,
          handicap_type: 'visuel',
          classification: '2',
          position: 'ailier',
          championship_level: 'regional',
          passport_type: 'france',
          experience_years: 4,
          level: 'Amateur',
          residence: 'Lyon',
          club: 'Club Handibasket Lyon',
          coach: 'Marie Leroy',
          profession: 'Kinésithérapeute',
          achievements: 'Championne régionale 2023, Meilleure joueuse de la saison',
          bio: 'Joueuse handibasket passionnée, polyvalente et motivée. Recherche une équipe pour évoluer au niveau national.'
        }
      },
      {
        name: 'Thomas Leroy',
        email: 'thomas.leroy.handibasket@gmail.com',
        password: 'Test123',
        profile: {
          age: 30,
          gender: 'masculin',
          nationality: 'France',
          height: 190,
          weight: 85,
          handicap_type: 'moteur',
          classification: '1',
          position: 'pivot',
          championship_level: 'national',
          passport_type: 'france',
          experience_years: 8,
          level: 'Amateur',
          residence: 'Marseille',
          club: 'Club Handibasket Marseille',
          coach: 'Pierre Moreau',
          profession: 'Entraîneur',
          achievements: 'Champion national 2022, 2023, Capitaine d\'équipe',
          bio: 'Pivot expérimenté et leader naturel. Recherche une équipe ambitieuse pour continuer à performer au plus haut niveau.'
        }
      },
      {
        name: 'Emma Petit',
        email: 'emma.petit.handibasket@gmail.com',
        password: 'Test123',
        profile: {
          age: 21,
          gender: 'féminin',
          nationality: 'France',
          height: 170,
          weight: 65,
          handicap_type: 'auditif',
          classification: '3',
          position: 'arrière',
          championship_level: 'departemental',
          passport_type: 'france',
          experience_years: 2,
          level: 'Amateur',
          residence: 'Toulouse',
          club: 'Club Handibasket Toulouse',
          coach: 'Claire Bernard',
          profession: 'Étudiante',
          achievements: 'Révélation de la saison 2023',
          bio: 'Jeune joueuse handibasket prometteuse, très motivée pour progresser et évoluer dans le handibasket de haut niveau.'
        }
      },
      {
        name: 'Alexandre Moreau',
        email: 'alexandre.moreau.handibasket@gmail.com',
        password: 'Test123',
        profile: {
          age: 27,
          gender: 'masculin',
          nationality: 'France',
          height: 175,
          weight: 70,
          handicap_type: 'cognitif',
          classification: '2',
          position: 'polyvalent',
          championship_level: 'regional',
          passport_type: 'france',
          experience_years: 5,
          level: 'Amateur',
          residence: 'Nice',
          club: 'Club Handibasket Nice',
          coach: 'Michel Roux',
          profession: 'Développeur',
          achievements: 'Champion régional 2022, Joueur le plus régulier',
          bio: 'Joueur handibasket polyvalent et technique. Peut évoluer à tous les postes. Recherche une équipe pour continuer à progresser.'
        }
      }
    ];

    for (let i = 0; i < players.length; i++) {
      const player = players[i];
      console.log(`\n${i + 1}. Création du joueur: ${player.name}`);
      
      try {
        // Créer le compte
        const registration = await axios.post(`${BASE_URL}/api/auth/register`, {
          name: player.name,
          email: player.email,
          password: player.password,
          profile_type: 'handibasket'
        });
        
        const token = registration.data.token;
        console.log(`   ✅ Compte créé`);
        
        // Mettre à jour le profil
        await axios.put(`${BASE_URL}/api/handibasket/profile`, player.profile, {
          headers: { Authorization: `Bearer ${token}` }
        });
        
        console.log(`   ✅ Profil mis à jour`);
        
      } catch (error) {
        if (error.response?.data?.message === 'Cet email est déjà utilisé') {
          console.log(`   ⚠️ Email déjà utilisé, connexion...`);
          const login = await axios.post(`${BASE_URL}/api/auth/login`, {
            email: player.email,
            password: player.password
          });
          
          const token = login.data.token;
          await axios.put(`${BASE_URL}/api/handibasket/profile`, player.profile, {
            headers: { Authorization: `Bearer ${token}` }
          });
          
          console.log(`   ✅ Profil mis à jour via connexion`);
        } else {
          console.log(`   ❌ Erreur: ${error.response?.data?.message || error.message}`);
        }
      }
    }

    console.log('\n🎉 Création des joueurs handibasket terminée !');
    
    // Tester le matching
    console.log('\n🧪 Test du matching...');
    const testLogin = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'handiteam@gmail.com',
      password: 'Test123'
    });
    
    const teamToken = testLogin.data.token;
    const teamMatches = await axios.get(`${BASE_URL}/api/matching/top-matches?limit=5`, {
      headers: { Authorization: `Bearer ${teamToken}` }
    });
    
    console.log(`✅ ${teamMatches.data.data.length} matches trouvés pour l'équipe:`);
    teamMatches.data.data.forEach((match, index) => {
      console.log(`   ${index + 1}. ${match.name} (${match.type}) - Score: ${match.compatibilityScore}%`);
      console.log(`      Poste: ${match.position}, Niveau: ${match.level}`);
      console.log(`      Raisons: ${match.matchReasons.join(', ')}`);
    });

  } catch (error) {
    console.error('❌ Erreur lors de la création des joueurs:', error.response?.data || error.message);
  }
}

createHandibasketPlayers();
