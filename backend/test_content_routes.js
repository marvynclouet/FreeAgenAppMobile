const axios = require('axios');

// Configuration
const BASE_URL = 'https://freeagenappmobile-production.up.railway.app/api';
const TEST_EMAIL = 'sarah@gmail.com';
const TEST_PASSWORD = 'test123';

// Couleurs pour les logs
const colors = {
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  reset: '\x1b[0m',
  bold: '\x1b[1m'
};

let authToken = null;

// Fonction pour logger avec couleurs
function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

// Fonction pour tester un endpoint
async function testEndpoint(name, method, url, data = null, headers = {}) {
  try {
    log(`\n${colors.bold}🧪 Test: ${name}${colors.reset}`, 'blue');
    log(`📍 URL: ${method} ${url}`, 'yellow');
    
    if (data) {
      log(`📦 Data: ${JSON.stringify(data, null, 2)}`, 'yellow');
    }

    const config = {
      method,
      url,
      headers: {
        'Content-Type': 'application/json',
        ...headers
      }
    };

    if (data) {
      config.data = data;
    }

    const response = await axios(config);
    
    log(`✅ Status: ${response.status}`, 'green');
    log(`📄 Response: ${JSON.stringify(response.data, null, 2)}`, 'green');
    
    return { success: true, data: response.data };
  } catch (error) {
    log(`❌ Error: ${error.response?.status || error.code}`, 'red');
    log(`📄 Error Response: ${JSON.stringify(error.response?.data || error.message, null, 2)}`, 'red');
    return { success: false, error: error.response?.data || error.message };
  }
}

// Authentification
async function authenticate() {
  log('\n🔐 ===== AUTHENTIFICATION =====', 'bold');
  
  // Test avec l'utilisateur fourni
  const loginResult = await testEndpoint('Login User', 'POST', `${BASE_URL}/auth/login`, {
    email: TEST_EMAIL,
    password: TEST_PASSWORD
  });
  
  if (loginResult.success) {
    authToken = loginResult.data.token;
    log(`✅ Token obtenu: ${authToken.substring(0, 20)}...`, 'green');
  } else {
    log('❌ Impossible d\'obtenir un token d\'authentification', 'red');
  }
}

// Tests des routes de contenu
async function testContentRoutes() {
  log('\n📝 ===== TESTS ROUTES CONTENU =====', 'bold');
  
  if (!authToken) {
    log('❌ Pas de token d\'authentification disponible', 'red');
    return;
  }
  
  const headers = { 'Authorization': `Bearer ${authToken}` };
  
  // Test récupération feed
  await testEndpoint('Get Feed', 'GET', `${BASE_URL}/content/feed`, null, headers);
  
  // Test création post
  const createResult = await testEndpoint('Create Post', 'POST', `${BASE_URL}/content/posts`, {
    content: 'Ceci est un test de création de post via l\'API ! 🏀',
    imageUrls: [],
    eventDate: null,
    eventLocation: null
  }, headers);
  
  let postId = null;
  if (createResult.success) {
    postId = createResult.data.postId;
  }
  
  // Test récupération post par ID (si la route existe)
  if (postId) {
    await testEndpoint('Get Post by ID', 'GET', `${BASE_URL}/content/posts/${postId}`, null, headers);
  }
  
  // Test like/unlike post
  if (postId) {
    await testEndpoint('Like Post', 'POST', `${BASE_URL}/content/posts/${postId}/like`, null, headers);
    await testEndpoint('Unlike Post', 'DELETE', `${BASE_URL}/content/posts/${postId}/like`, null, headers);
  }
  
  // Test commenter un post
  if (postId) {
    await testEndpoint('Comment Post', 'POST', `${BASE_URL}/content/posts/${postId}/comments`, {
      content: 'Super post ! 👍'
    }, headers);
  }
}

// Fonction principale
async function runContentTests() {
  log('\n🚀 ===== TESTS SPÉCIFIQUES ROUTES CONTENU =====', 'bold');
  log(`📍 URL de base: ${BASE_URL}`, 'blue');
  log(`⏰ Timestamp: ${new Date().toISOString()}`, 'blue');
  
  try {
    await authenticate();
    await testContentRoutes();
    
    log('\n🎉 ===== TESTS CONTENU TERMINÉS =====', 'bold');
    log('✅ Les tests ont été exécutés avec succès', 'green');
    
  } catch (error) {
    log('\n💥 ===== ERREUR LORS DES TESTS =====', 'bold');
    log(`❌ Erreur: ${error.message}`, 'red');
  }
}

// Exécution des tests
runContentTests(); 