#!/usr/bin/env node

const axios = require('axios');
const colors = require('colors');

// Configuration
const BASE_URL = 'https://freeagenappmobile-production.up.railway.app';
const TEST_TOKEN = 'test_token_for_testing'; // Token factice pour les tests

// Couleurs pour les logs
colors.enable();

// Fonction pour tester une route
async function testRoute(method, endpoint, description, expectedStatus = 200, data = null, headers = {}) {
  try {
    console.log(`\n🔍 Testing: ${description}`.cyan);
    console.log(`   ${method.toUpperCase()} ${endpoint}`.gray);
    
    const config = {
      method,
      url: `${BASE_URL}${endpoint}`,
      headers: {
        'Content-Type': 'application/json',
        ...headers
      },
      timeout: 10000
    };

    if (data) {
      config.data = data;
    }

    const response = await axios(config);
    
    if (response.status === expectedStatus) {
      console.log(`   ✅ SUCCESS (${response.status})`.green);
      if (response.data && typeof response.data === 'object') {
        console.log(`   📄 Response: ${JSON.stringify(response.data, null, 2).substring(0, 200)}...`.gray);
      }
    } else {
      console.log(`   ⚠️  UNEXPECTED STATUS (${response.status}, expected ${expectedStatus})`.yellow);
    }
    
    return { success: true, status: response.status, data: response.data };
  } catch (error) {
    if (error.response) {
      const status = error.response.status;
      if (status === expectedStatus) {
        console.log(`   ✅ SUCCESS (${status} - Expected error)`.green);
        return { success: true, status, data: error.response.data };
      } else {
        console.log(`   ❌ FAILED (${status}, expected ${expectedStatus})`.red);
        console.log(`   📄 Error: ${JSON.stringify(error.response.data, null, 2).substring(0, 200)}...`.gray);
      }
    } else {
      console.log(`   ❌ FAILED (Network error: ${error.message})`.red);
    }
    return { success: false, error: error.message };
  }
}

// Routes à tester
const routes = [
  // Routes publiques (sans authentification)
  {
    method: 'GET',
    endpoint: '/api/auth/health',
    description: 'Health Check - Route publique',
    expectedStatus: 200
  },
  
  // Routes d'authentification
  {
    method: 'POST',
    endpoint: '/api/auth/register',
    description: 'Register - Création de compte',
    expectedStatus: 400, // Devrait échouer sans données
    data: { name: 'Test User', email: 'test@example.com', password: 'password123', profile_type: 'player' }
  },
  {
    method: 'POST',
    endpoint: '/api/auth/login',
    description: 'Login - Connexion',
    expectedStatus: 401, // Devrait échouer avec des données invalides
    data: { email: 'invalid@example.com', password: 'wrongpassword' }
  },
  {
    method: 'GET',
    endpoint: '/api/auth/validate',
    description: 'Validate Token - Validation de token',
    expectedStatus: 401, // Devrait échouer sans token valide
    headers: { 'Authorization': `Bearer ${TEST_TOKEN}` }
  },
  
  // Routes protégées (avec authentification)
  {
    method: 'GET',
    endpoint: '/api/users',
    description: 'Users - Liste des utilisateurs',
    expectedStatus: 401, // Devrait échouer sans token
    headers: { 'Authorization': `Bearer ${TEST_TOKEN}` }
  },
  {
    method: 'GET',
    endpoint: '/api/profiles',
    description: 'Profiles - Liste des profils',
    expectedStatus: 401,
    headers: { 'Authorization': `Bearer ${TEST_TOKEN}` }
  },
  {
    method: 'GET',
    endpoint: '/api/teams',
    description: 'Teams - Liste des équipes',
    expectedStatus: 401,
    headers: { 'Authorization': `Bearer ${TEST_TOKEN}` }
  },
  {
    method: 'GET',
    endpoint: '/api/players',
    description: 'Players - Liste des joueurs',
    expectedStatus: 401,
    headers: { 'Authorization': `Bearer ${TEST_TOKEN}` }
  },
  {
    method: 'GET',
    endpoint: '/api/clubs',
    description: 'Clubs - Liste des clubs',
    expectedStatus: 401,
    headers: { 'Authorization': `Bearer ${TEST_TOKEN}` }
  },
  {
    method: 'GET',
    endpoint: '/api/coaches',
    description: 'Coaches - Liste des coachs',
    expectedStatus: 401,
    headers: { 'Authorization': `Bearer ${TEST_TOKEN}` }
  },
  {
    method: 'GET',
    endpoint: '/api/annonces',
    description: 'Annonces - Liste des annonces',
    expectedStatus: 401,
    headers: { 'Authorization': `Bearer ${TEST_TOKEN}` }
  },
  {
    method: 'GET',
    endpoint: '/api/opportunities',
    description: 'Opportunities - Liste des opportunités',
    expectedStatus: 401,
    headers: { 'Authorization': `Bearer ${TEST_TOKEN}` }
  },
  {
    method: 'GET',
    endpoint: '/api/messages',
    description: 'Messages - API des messages',
    expectedStatus: 200 // Route racine publique
  },
  {
    method: 'GET',
    endpoint: '/api/messages/conversations',
    description: 'Messages - Conversations',
    expectedStatus: 401,
    headers: { 'Authorization': `Bearer ${TEST_TOKEN}` }
  },
  {
    method: 'GET',
    endpoint: '/api/handibasket',
    description: 'Handibasket - API handibasket',
    expectedStatus: 401,
    headers: { 'Authorization': `Bearer ${TEST_TOKEN}` }
  },
  {
    method: 'GET',
    endpoint: '/api/subscriptions',
    description: 'Subscriptions - API abonnements',
    expectedStatus: 401,
    headers: { 'Authorization': `Bearer ${TEST_TOKEN}` }
  },
  {
    method: 'GET',
    endpoint: '/api/store',
    description: 'Store - API boutique',
    expectedStatus: 401,
    headers: { 'Authorization': `Bearer ${TEST_TOKEN}` }
  },
  {
    method: 'GET',
    endpoint: '/api/upload',
    description: 'Upload - API upload',
    expectedStatus: 401,
    headers: { 'Authorization': `Bearer ${TEST_TOKEN}` }
  },
  {
    method: 'GET',
    endpoint: '/api/matching',
    description: 'Matching - API matching',
    expectedStatus: 401,
    headers: { 'Authorization': `Bearer ${TEST_TOKEN}` }
  },
  {
    method: 'GET',
    endpoint: '/api',
    description: 'Content - API contenu',
    expectedStatus: 200 // Route racine publique
  },
  
  // Tests de routes inexistantes
  {
    method: 'GET',
    endpoint: '/api/nonexistent',
    description: 'Route inexistante',
    expectedStatus: 404
  },
  {
    method: 'GET',
    endpoint: '/api/users/nonexistent',
    description: 'Route utilisateur inexistante',
    expectedStatus: 404
  }
];

// Fonction principale
async function runTests() {
  console.log('🚀 Starting Backend API Tests'.bold);
  console.log(`📍 Base URL: ${BASE_URL}`.gray);
  console.log(`⏰ Started at: ${new Date().toISOString()}`.gray);
  console.log('='.repeat(80));

  const results = {
    total: routes.length,
    success: 0,
    failed: 0,
    details: []
  };

  for (const route of routes) {
    const result = await testRoute(
      route.method,
      route.endpoint,
      route.description,
      route.expectedStatus,
      route.data,
      route.headers
    );
    
    results.details.push({
      ...route,
      result
    });
    
    if (result.success) {
      results.success++;
    } else {
      results.failed++;
    }
  }

  // Résumé
  console.log('\n' + '='.repeat(80));
  console.log('📊 TEST RESULTS SUMMARY'.bold);
  console.log(`✅ Successful: ${results.success}/${results.total}`.green);
  console.log(`❌ Failed: ${results.failed}/${results.total}`.red);
  console.log(`📈 Success Rate: ${((results.success / results.total) * 100).toFixed(1)}%`.cyan);
  
  if (results.failed > 0) {
    console.log('\n❌ FAILED TESTS:'.red);
    results.details.forEach((test, index) => {
      if (!test.result.success) {
        console.log(`   ${index + 1}. ${test.description} (${test.method} ${test.endpoint})`.red);
      }
    });
  }

  console.log(`\n⏰ Finished at: ${new Date().toISOString()}`.gray);
  
  return results;
}

// Gestion des erreurs
process.on('unhandledRejection', (error) => {
  console.error('❌ Unhandled Promise Rejection:'.red, error);
  process.exit(1);
});

// Exécution
if (require.main === module) {
  runTests()
    .then((results) => {
      process.exit(results.failed > 0 ? 1 : 0);
    })
    .catch((error) => {
      console.error('❌ Test runner failed:'.red, error);
      process.exit(1);
    });
}

module.exports = { runTests, testRoute }; 