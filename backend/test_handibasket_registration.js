const https = require('https');

// Fonction pour faire une requête POST
function makeRequest(url, data) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(data);
    
    const options = {
      hostname: 'freeagenappmobile-production.up.railway.app',
      port: 443,
      path: url,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    const req = https.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        try {
          const jsonData = JSON.parse(responseData);
          resolve({ status: res.statusCode, data: jsonData });
        } catch (e) {
          resolve({ status: res.statusCode, data: responseData });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.write(postData);
    req.end();
  });
}

// Fonction pour tester l'inscription handibasket
async function testHandibasketRegistration() {
  console.log('🧪 Test d\'inscription handibasket...\n');

  const testUsers = [
    {
      name: 'Marie Dubois',
      email: 'handibasket1@freeagent.com',
      password: 'Test123!',
      profileType: 'handibasket',
      gender: 'F',
      nationality: 'Française',
      handibasketData: {
        age: 29,
        handicap_type: 'Moteur',
        classification: 'I',
        nationality: 'Paris',
        profession: 'Éducatrice spécialisée',
        position: 'Pivot',
        championship_level: 'Nationale 1',
        height: 175,
        weight: 68,
        passport_type: 'Français',
        experience_years: 8,
        level: 'Élite',
        stats: {
          points: 12.5,
          rebounds: 8.2,
          assists: 2.1,
          steals: 1.8,
          blocks: 1.2
        },
        achievements: 'Championne de France 2023, Vice-championne d\'Europe 2022',
        video_url: 'https://youtube.com/watch?v=marie_handibasket',
        bio: 'Passionnée de handibasket depuis l\'âge de 12 ans, je recherche une équipe compétitive.',
        club: 'Paris Handibasket Club',
        coach: 'Jean-Pierre Durand'
      }
    },
    {
      name: 'Thomas Martin',
      email: 'handibasket2@freeagent.com',
      password: 'Test123!',
      profileType: 'handibasket',
      gender: 'M',
      nationality: 'Français',
      handibasketData: {
        age: 32,
        handicap_type: 'Moteur',
        classification: 'II',
        nationality: 'Lyon',
        profession: 'Ingénieur informatique',
        position: 'Meneur',
        championship_level: 'Nationale 2',
        height: 168,
        weight: 65,
        passport_type: 'Français',
        experience_years: 10,
        level: 'Élite',
        stats: {
          points: 8.3,
          rebounds: 3.1,
          assists: 6.8,
          steals: 2.5,
          blocks: 0.3
        },
        achievements: 'Meilleur passeur du championnat 2023',
        video_url: 'https://youtube.com/watch?v=thomas_handibasket',
        bio: 'Meneur de jeu expérimenté, je privilégie le collectif et la tactique.',
        club: 'Lyon Handibasket',
        coach: 'Marie-Claire Bernard'
      }
    }
  ];

  for (const user of testUsers) {
    console.log(`📝 Inscription de ${user.name}...`);
    
    try {
      const response = await makeRequest('/api/auth/register', user);
      
      if (response.status === 201) {
        console.log(`✅ ${user.name} inscrit avec succès`);
        console.log(`   Email: ${user.email}`);
        console.log(`   ID: ${response.data.user?.id || 'N/A'}`);
      } else {
        console.log(`❌ Erreur pour ${user.name}:`);
        console.log(`   Status: ${response.status}`);
        console.log(`   Message: ${response.data.message || response.data}`);
      }
    } catch (error) {
      console.log(`❌ Erreur de connexion pour ${user.name}: ${error.message}`);
    }
    
    console.log('');
  }

  console.log('🎯 Test terminé !');
}

// Exécuter le test
testHandibasketRegistration();
