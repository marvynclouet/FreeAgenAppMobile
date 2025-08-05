const axios = require('axios');

// Configuration
const BASE_URL = 'https://freeagenappmobile-production.up.railway.app/api';
const TEST_EMAIL = 'test@test.com';
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
let testUserId = null;

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

// Tests d'authentification
async function testAuthServices() {
  log('\n🔐 ===== TESTS AUTHENTIFICATION =====', 'bold');
  
  // Test health check
  await testEndpoint('Health Check', 'GET', `${BASE_URL}/auth/health`);
  
  // Test inscription
  const registerResult = await testEndpoint('Register User', 'POST', `${BASE_URL}/auth/register`, {
    name: 'Test User API',
    email: 'testapi@test.com',
    password: 'test123',
    profile_type: 'player'
  });
  
  if (registerResult.success) {
    authToken = registerResult.data.token;
    testUserId = registerResult.data.user.id;
  }
  
  // Test connexion
  const loginResult = await testEndpoint('Login User', 'POST', `${BASE_URL}/auth/login`, {
    email: TEST_EMAIL,
    password: TEST_PASSWORD
  });
  
  if (loginResult.success) {
    authToken = loginResult.data.token;
  }
  
  // Test validation token
  if (authToken) {
    await testEndpoint('Validate Token', 'GET', `${BASE_URL}/auth/validate`, null, {
      'Authorization': `Bearer ${authToken}`
    });
  }
}

// Tests des profils utilisateurs
async function testProfileServices() {
  log('\n👤 ===== TESTS PROFILS UTILISATEURS =====', 'bold');
  
  if (!authToken) {
    log('❌ Pas de token d\'authentification disponible', 'red');
    return;
  }
  
  const headers = { 'Authorization': `Bearer ${authToken}` };
  
  // Test récupération profil
  await testEndpoint('Get Profile', 'GET', `${BASE_URL}/users/profile`, null, headers);
  
  // Test mise à jour profil
  await testEndpoint('Update Profile', 'PUT', `${BASE_URL}/users/profile`, {
    name: 'Test User Updated',
    email: 'testupdated@test.com'
  }, headers);
  
  // Test recherche utilisateurs
  await testEndpoint('Search Users', 'GET', `${BASE_URL}/users/search?type=player&query=test`, null, headers);
  
  // Test liste utilisateurs
  await testEndpoint('List Users', 'GET', `${BASE_URL}/users`, null, headers);
}

// Tests des joueurs
async function testPlayerServices() {
  log('\n🏀 ===== TESTS SERVICES JOUEURS =====', 'bold');
  
  if (!authToken) {
    log('❌ Pas de token d\'authentification disponible', 'red');
    return;
  }
  
  const headers = { 'Authorization': `Bearer ${authToken}` };
  
  // Test récupération joueurs
  await testEndpoint('Get Players', 'GET', `${BASE_URL}/players`, null, headers);
  
  // Test récupération joueur par ID
  if (testUserId) {
    await testEndpoint('Get Player by ID', 'GET', `${BASE_URL}/players/${testUserId}`, null, headers);
  }
  
  // Test mise à jour profil joueur
  await testEndpoint('Update Player Profile', 'PUT', `${BASE_URL}/players/profile`, {
    age: 25,
    height: 185,
    weight: 80,
    position: 'guard',
    experience_years: 5
  }, headers);
}

// Tests des coaches
async function testCoachServices() {
  log('\n👨‍💼 ===== TESTS SERVICES COACHES =====', 'bold');
  
  if (!authToken) {
    log('❌ Pas de token d\'authentification disponible', 'red');
    return;
  }
  
  const headers = { 'Authorization': `Bearer ${authToken}` };
  
  // Test récupération coaches
  await testEndpoint('Get Coaches', 'GET', `${BASE_URL}/coaches`, null, headers);
  
  // Test récupération coach par ID
  await testEndpoint('Get Coach by ID', 'GET', `${BASE_URL}/coaches/1`, null, headers);
}

// Tests des équipes/clubs
async function testTeamServices() {
  log('\n🏆 ===== TESTS SERVICES ÉQUIPES =====', 'bold');
  
  if (!authToken) {
    log('❌ Pas de token d\'authentification disponible', 'red');
    return;
  }
  
  const headers = { 'Authorization': `Bearer ${authToken}` };
  
  // Test récupération équipes
  await testEndpoint('Get Teams', 'GET', `${BASE_URL}/teams`, null, headers);
  
  // Test récupération équipe par ID
  await testEndpoint('Get Team by ID', 'GET', `${BASE_URL}/teams/1`, null, headers);
  
  // Test récupération clubs
  await testEndpoint('Get Clubs', 'GET', `${BASE_URL}/clubs`, null, headers);
}

// Tests des opportunités
async function testOpportunityServices() {
  log('\n💼 ===== TESTS SERVICES OPPORTUNITÉS =====', 'bold');
  
  if (!authToken) {
    log('❌ Pas de token d\'authentification disponible', 'red');
    return;
  }
  
  const headers = { 'Authorization': `Bearer ${authToken}` };
  
  // Test récupération opportunités
  await testEndpoint('Get Opportunities', 'GET', `${BASE_URL}/opportunities`, null, headers);
  
  // Test création opportunité
  const createResult = await testEndpoint('Create Opportunity', 'POST', `${BASE_URL}/opportunities`, {
    title: 'Test Opportunity',
    description: 'This is a test opportunity',
    type: 'equipe_recherche_joueur',
    location: 'Paris',
    requirements: 'Test requirements',
    salary_range: '2000-3000',
    duration: '6 months'
  }, headers);
  
  let opportunityId = null;
  if (createResult.success) {
    opportunityId = createResult.data.id;
  }
  
  // Test récupération opportunité par ID
  if (opportunityId) {
    await testEndpoint('Get Opportunity by ID', 'GET', `${BASE_URL}/opportunities/${opportunityId}`, null, headers);
  }
  
  // Test candidature à une opportunité
  if (opportunityId) {
    await testEndpoint('Apply to Opportunity', 'POST', `${BASE_URL}/opportunities/${opportunityId}/apply`, {
      message: 'I am interested in this opportunity'
    }, headers);
  }
}

// Tests des messages
async function testMessageServices() {
  log('\n💬 ===== TESTS SERVICES MESSAGES =====', 'bold');
  
  if (!authToken) {
    log('❌ Pas de token d\'authentification disponible', 'red');
    return;
  }
  
  const headers = { 'Authorization': `Bearer ${authToken}` };
  
  // Test récupération conversations
  await testEndpoint('Get Conversations', 'GET', `${BASE_URL}/messages/conversations`, null, headers);
  
  // Test création conversation
  const createResult = await testEndpoint('Create Conversation', 'POST', `${BASE_URL}/messages/conversations`, {
    receiverId: 1,
    content: 'Hello, this is a test message',
    subject: 'Test conversation'
  }, headers);
  
  let conversationId = null;
  if (createResult.success) {
    conversationId = createResult.data.conversationId;
  }
  
  // Test récupération messages d'une conversation
  if (conversationId) {
    await testEndpoint('Get Messages', 'GET', `${BASE_URL}/messages/conversations/${conversationId}`, null, headers);
    
    // Test envoi message
    await testEndpoint('Send Message', 'POST', `${BASE_URL}/messages/conversations/${conversationId}/messages`, {
      content: 'This is a reply to the test message'
    }, headers);
  }
  
  // Test messages non lus
  await testEndpoint('Get Unread Count', 'GET', `${BASE_URL}/messages/unread-count`, null, headers);
}

// Tests des abonnements
async function testSubscriptionServices() {
  log('\n💎 ===== TESTS SERVICES ABONNEMENTS =====', 'bold');
  
  if (!authToken) {
    log('❌ Pas de token d\'authentification disponible', 'red');
    return;
  }
  
  const headers = { 'Authorization': `Bearer ${authToken}` };
  
  // Test récupération plans d'abonnement
  await testEndpoint('Get Subscription Plans', 'GET', `${BASE_URL}/subscriptions/plans`);
  
  // Test récupération statut abonnement
  await testEndpoint('Get Subscription Status', 'GET', `${BASE_URL}/subscriptions/status`, null, headers);
  
  // Test limites d'utilisation
  await testEndpoint('Get Usage Limits', 'GET', `${BASE_URL}/subscriptions/limits`, null, headers);
}

// Tests des contenus
async function testContentServices() {
  log('\n📝 ===== TESTS SERVICES CONTENUS =====', 'bold');
  
  if (!authToken) {
    log('❌ Pas de token d\'authentification disponible', 'red');
    return;
  }
  
  const headers = { 'Authorization': `Bearer ${authToken}` };
  
  // Test récupération feed
  await testEndpoint('Get Feed', 'GET', `${BASE_URL}/content/feed`, null, headers);
  
  // Test création post
  const createResult = await testEndpoint('Create Post', 'POST', `${BASE_URL}/content/posts`, {
    content: 'This is a test post',
    type: 'post'
  }, headers);
  
  let postId = null;
  if (createResult.success) {
    postId = createResult.data.id;
  }
  
  // Test récupération post par ID
  if (postId) {
    await testEndpoint('Get Post by ID', 'GET', `${BASE_URL}/content/posts/${postId}`, null, headers);
  }
  
  // Test like/unlike post
  if (postId) {
    await testEndpoint('Like Post', 'POST', `${BASE_URL}/content/posts/${postId}/like`, null, headers);
    await testEndpoint('Unlike Post', 'DELETE', `${BASE_URL}/content/posts/${postId}/like`, null, headers);
  }
}

// Tests des uploads
async function testUploadServices() {
  log('\n📤 ===== TESTS SERVICES UPLOAD =====', 'bold');
  
  if (!authToken) {
    log('❌ Pas de token d\'authentification disponible', 'red');
    return;
  }
  
  const headers = { 'Authorization': `Bearer ${authToken}` };
  
  // Test récupération photo de profil
  await testEndpoint('Get Profile Photo', 'GET', `${BASE_URL}/upload/profile-image`, null, headers);
  
  // Test suppression photo de profil
  await testEndpoint('Delete Profile Photo', 'DELETE', `${BASE_URL}/upload/profile-image`, null, headers);
}

// Tests des paiements
async function testPaymentServices() {
  log('\n💳 ===== TESTS SERVICES PAIEMENTS =====', 'bold');
  
  if (!authToken) {
    log('❌ Pas de token d\'authentification disponible', 'red');
    return;
  }
  
  const headers = { 'Authorization': `Bearer ${authToken}` };
  
  // Test récupération méthodes de paiement
  await testEndpoint('Get Payment Methods', 'GET', `${BASE_URL}/payments/methods`, null, headers);
  
  // Test création session de paiement
  await testEndpoint('Create Payment Session', 'POST', `${BASE_URL}/payments/create-session`, {
    planId: 1,
    successUrl: 'https://example.com/success',
    cancelUrl: 'https://example.com/cancel'
  }, headers);
}

// Tests du store
async function testStoreServices() {
  log('\n🛒 ===== TESTS SERVICES STORE =====', 'bold');
  
  if (!authToken) {
    log('❌ Pas de token d\'authentification disponible', 'red');
    return;
  }
  
  const headers = { 'Authorization': `Bearer ${authToken}` };
  
  // Test récupération produits
  await testEndpoint('Get Store Products', 'GET', `${BASE_URL}/store/products`, null, headers);
  
  // Test récupération statut abonnement store
  await testEndpoint('Get Store Subscription Status', 'GET', `${BASE_URL}/store/subscription-status`, null, headers);
}

// Tests du matching
async function testMatchingServices() {
  log('\n❤️ ===== TESTS SERVICES MATCHING =====', 'bold');
  
  if (!authToken) {
    log('❌ Pas de token d\'authentification disponible', 'red');
    return;
  }
  
  const headers = { 'Authorization': `Bearer ${authToken}` };
  
  // Test récupération suggestions
  await testEndpoint('Get Matching Suggestions', 'GET', `${BASE_URL}/matching/suggestions`, null, headers);
  
  // Test like/unlike
  await testEndpoint('Like Profile', 'POST', `${BASE_URL}/matching/like/1`, null, headers);
  await testEndpoint('Unlike Profile', 'DELETE', `${BASE_URL}/matching/like/1`, null, headers);
  
  // Test matches
  await testEndpoint('Get Matches', 'GET', `${BASE_URL}/matching/matches`, null, headers);
}

// Tests handibasket
async function testHandibasketServices() {
  log('\n♿ ===== TESTS SERVICES HANDIBASKET =====', 'bold');
  
  if (!authToken) {
    log('❌ Pas de token d\'authentification disponible', 'red');
    return;
  }
  
  const headers = { 'Authorization': `Bearer ${authToken}` };
  
  // Test récupération profils handibasket
  await testEndpoint('Get Handibasket Profiles', 'GET', `${BASE_URL}/handibasket/profiles`, null, headers);
  
  // Test récupération profil handibasket par ID
  await testEndpoint('Get Handibasket Profile by ID', 'GET', `${BASE_URL}/handibasket/profiles/1`, null, headers);
}

// Tests des annonces
async function testAnnonceServices() {
  log('\n📢 ===== TESTS SERVICES ANNONCES =====', 'bold');
  
  if (!authToken) {
    log('❌ Pas de token d\'authentification disponible', 'red');
    return;
  }
  
  const headers = { 'Authorization': `Bearer ${authToken}` };
  
  // Test récupération annonces
  await testEndpoint('Get Annonces', 'GET', `${BASE_URL}/annonces`, null, headers);
  
  // Test création annonce
  const createResult = await testEndpoint('Create Annonce', 'POST', `${BASE_URL}/annonces`, {
    title: 'Test Annonce',
    description: 'This is a test annonce',
    type: 'equipe_recherche_joueur',
    location: 'Paris'
  }, headers);
  
  let annonceId = null;
  if (createResult.success) {
    annonceId = createResult.data.id;
  }
  
  // Test récupération annonce par ID
  if (annonceId) {
    await testEndpoint('Get Annonce by ID', 'GET', `${BASE_URL}/annonces/${annonceId}`, null, headers);
  }
}

// Fonction principale
async function runAllTests() {
  log('\n🚀 ===== DÉBUT DES TESTS COMPLETS DE L\'API =====', 'bold');
  log(`📍 URL de base: ${BASE_URL}`, 'blue');
  log(`⏰ Timestamp: ${new Date().toISOString()}`, 'blue');
  
  try {
    // Tests dans l'ordre logique
    await testAuthServices();
    await testProfileServices();
    await testPlayerServices();
    await testCoachServices();
    await testTeamServices();
    await testOpportunityServices();
    await testMessageServices();
    await testSubscriptionServices();
    await testContentServices();
    await testUploadServices();
    await testPaymentServices();
    await testStoreServices();
    await testMatchingServices();
    await testHandibasketServices();
    await testAnnonceServices();
    
    log('\n🎉 ===== TOUS LES TESTS TERMINÉS =====', 'bold');
    log('✅ Les tests ont été exécutés avec succès', 'green');
    
  } catch (error) {
    log('\n💥 ===== ERREUR LORS DES TESTS =====', 'bold');
    log(`❌ Erreur: ${error.message}`, 'red');
  }
}

// Exécution des tests
runAllTests(); 