const https = require('https');

// Fonction pour exécuter une requête SQL via l'API
function executeSQL(sql) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({ sql });
    
    const options = {
      hostname: 'freeagenappmobile-production.up.railway.app',
      port: 443,
      path: '/api/admin/execute-sql',
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

// Fonction pour mettre à jour le profil handibasket directement
async function updateHandibasketProfile() {
  console.log('🔧 Mise à jour directe du profil handibasket...\n');

  const userId = 181; // zetztzetez

  // 1. Vérifier le profil actuel
  console.log('📖 Vérification du profil actuel...');
  const checkResponse = await executeSQL(`SELECT * FROM handibasket_profiles WHERE user_id = ${userId}`);
  console.log('Profil actuel:', JSON.stringify(checkResponse.data.result[0], null, 2));
  console.log('');

  // 2. Mettre à jour le profil avec des données de test
  console.log('📝 Mise à jour du profil...');
  const updateSQL = `
    UPDATE handibasket_profiles 
    SET 
      height = 170,
      weight = 65,
      passport_type = 'france',
      experience_years = 3,
      level = 'Amateur',
      achievements = 'Champion régional 2023',
      video_url = 'https://youtube.com/watch?v=test',
      bio = 'Joueur handibasket passionné',
      updated_at = CURRENT_TIMESTAMP
    WHERE user_id = ${userId}
  `;

  const updateResponse = await executeSQL(updateSQL);
  console.log('Résultat de la mise à jour:', JSON.stringify(updateResponse.data, null, 2));
  console.log('');

  // 3. Vérifier le profil après mise à jour
  console.log('📖 Vérification du profil après mise à jour...');
  const checkAfterResponse = await executeSQL(`SELECT * FROM handibasket_profiles WHERE user_id = ${userId}`);
  console.log('Profil après mise à jour:', JSON.stringify(checkAfterResponse.data.result[0], null, 2));
  console.log('');

  // 4. Tester la récupération via l'API
  console.log('🌐 Test de récupération via l\'API...');
  const apiResponse = await fetch(`https://freeagenappmobile-production.up.railway.app/api/handibasket/profile`, {
    method: 'GET',
    headers: {
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgxLCJlbWFpbCI6InpnZXpnemdAemdlaGFhaGguY29tIiwicHJvZmlsZV90eXBlIjoiaGFuZGliYXNrZXQiLCJpYXQiOjE3NTcxNDY5MDIsImV4cCI6MTc1NzIzMzMwMn0.rQT1VnsKg-OZY-wuII6zYtQLJ0M5YJR-nFjno67Y5zQ',
      'Content-Type': 'application/json'
    }
  });

  const apiData = await apiResponse.json();
  console.log('Réponse API:', JSON.stringify(apiData, null, 2));
}

// Exécuter le script
updateHandibasketProfile();
