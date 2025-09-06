const https = require('https');

// Fonction pour faire une requête PUT
function makePutRequest(url, data, token) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(data);
    
    const options = {
      hostname: 'freeagenappmobile-production.up.railway.app',
      port: 443,
      path: url,
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
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

// Test simple de mise à jour
async function testHandibasketUpdate() {
  console.log('🧪 Test de mise à jour du profil handibasket...\n');

  const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgxLCJlbWFpbCI6InpnZXpnemdAemdlaGFhaGguY29tIiwicHJvZmlsZV90eXBlIjoiaGFuZGliYXNrZXQiLCJpYXQiOjE3NTcxNDY5MDIsImV4cCI6MTc1NzIzMzMwMn0.rQT1VnsKg-OZY-wuII6zYtQLJ0M5YJR-nFjno67Y5zQ';

  // Test 1: Mise à jour avec seulement des champs texte
  console.log('📝 Test 1: Mise à jour avec champs texte...');
  try {
    const response1 = await makePutRequest('/api/handibasket/profile', {
      achievements: 'Champion régional 2023',
      bio: 'Joueur handibasket passionné',
      video_url: 'https://youtube.com/watch?v=test'
    }, token);
    
    console.log(`   Status: ${response1.status}`);
    console.log(`   Response: ${JSON.stringify(response1.data, null, 2)}`);
  } catch (error) {
    console.log(`   Erreur: ${error.message}`);
  }

  console.log('');

  // Test 2: Mise à jour avec des champs numériques
  console.log('📝 Test 2: Mise à jour avec champs numériques...');
  try {
    const response2 = await makePutRequest('/api/handibasket/profile', {
      height: 170,
      weight: 65,
      experience_years: 3
    }, token);
    
    console.log(`   Status: ${response2.status}`);
    console.log(`   Response: ${JSON.stringify(response2.data, null, 2)}`);
  } catch (error) {
    console.log(`   Erreur: ${error.message}`);
  }

  console.log('');

  // Test 3: Mise à jour avec un seul champ
  console.log('📝 Test 3: Mise à jour avec un seul champ...');
  try {
    const response3 = await makePutRequest('/api/handibasket/profile', {
      passport_type: 'france'
    }, token);
    
    console.log(`   Status: ${response3.status}`);
    console.log(`   Response: ${JSON.stringify(response3.data, null, 2)}`);
  } catch (error) {
    console.log(`   Erreur: ${error.message}`);
  }
}

// Exécuter le test
testHandibasketUpdate();
