// Script simple pour vérifier les profils via l'API
const https = require('https');

console.log('📋 Vérification des profils via l\'API...');

// Fonction pour faire une requête HTTPS
function makeRequest(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const jsonData = JSON.parse(data);
          resolve(jsonData);
        } catch (e) {
          resolve({ error: 'Invalid JSON', raw: data.substring(0, 200) });
        }
      });
    }).on('error', (err) => {
      reject(err);
    });
  });
}

async function checkProfiles() {
  try {
    console.log('🔍 Tentative de récupération des données...');
    
    // Essayer différentes routes
    const routes = [
      'https://backend-hmnlcriwn-marvynshes-projects.vercel.app/api/health',
      'https://backend-hmnlcriwn-marvynshes-projects.vercel.app/api/opportunities',
      'https://backend-hmnlcriwn-marvynshes-projects.vercel.app/api/teams'
    ];
    
    for (const route of routes) {
      try {
        console.log(`\n🌐 Test de: ${route}`);
        const result = await makeRequest(route);
        console.log('✅ Réponse reçue:');
        console.log(JSON.stringify(result, null, 2).substring(0, 500) + '...');
      } catch (error) {
        console.log(`❌ Erreur pour ${route}:`, error.message);
      }
    }
    
    console.log('\n📊 Résumé:');
    console.log('- Si vous voyez des données JSON, l\'API fonctionne');
    console.log('- Si vous voyez des erreurs d\'authentification, l\'API est protégée');
    console.log('- Pour voir les profils, vous devrez vous connecter via l\'interface web');
    
  } catch (error) {
    console.error('❌ Erreur générale:', error);
  }
}

checkProfiles();

