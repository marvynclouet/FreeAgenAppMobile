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

  const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTc1LCJlbWFpbCI6Im1hcmllLmR1Ym9pc0BoYW5kaWJhc2tldC5jb20iLCJwcm9maWxlX3R5cGUiOiJoYW5kaWJhc2tldCIsImlhdCI6MTc1NzE0NDI5NSwiZXhwIjoxNzU3MjMwNjk1fQ.wC0XBB37X0NC8rEGG7UYc8MEcNFvkAgyLH8XgcQjNvo';

  // Test 1: Mise à jour simple avec seulement quelques champs
  console.log('📝 Test 1: Mise à jour simple...');
  try {
    const response1 = await makePutRequest('/api/handibasket/profile', {
      height: 165,
      weight: 60
    }, token);
    
    console.log(`   Status: ${response1.status}`);
    console.log(`   Response: ${JSON.stringify(response1.data, null, 2)}`);
  } catch (error) {
    console.log(`   Erreur: ${error.message}`);
  }

  console.log('');

  // Test 2: Mise à jour avec plus de champs
  console.log('📝 Test 2: Mise à jour complète...');
  try {
    const response2 = await makePutRequest('/api/handibasket/profile', {
      height: 165,
      weight: 60,
      passport_type: 'france',
      experience_years: 5,
      level: 'Semi-pro',
      achievements: 'Championne de France 2023',
      video_url: 'https://youtube.com/watch?v=test',
      bio: 'Joueuse handibasket passionnée',
      club: 'Paris Handibasket',
      coach: 'Jean Dupont'
    }, token);
    
    console.log(`   Status: ${response2.status}`);
    console.log(`   Response: ${JSON.stringify(response2.data, null, 2)}`);
  } catch (error) {
    console.log(`   Erreur: ${error.message}`);
  }

  console.log('');

  // Test 3: Vérifier le profil après mise à jour
  console.log('📖 Test 3: Vérification du profil...');
  try {
    const response3 = await makePutRequest('/api/handibasket/profile', {}, token);
    
    console.log(`   Status: ${response3.status}`);
    console.log(`   Response: ${JSON.stringify(response3.data, null, 2)}`);
  } catch (error) {
    console.log(`   Erreur: ${error.message}`);
  }
}

// Exécuter le test
testHandibasketUpdate();
