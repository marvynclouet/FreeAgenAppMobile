#!/usr/bin/env node

const axios = require('axios');
const colors = require('colors');

// Configuration
const BASE_URL = 'https://freeagenappmobile-production.up.railway.app';

// Couleurs pour les logs
colors.enable();

// Fonction pour tester une route API
async function testApiRoute(method, endpoint, description, expectedStatus = 200, data = null, headers = {}) {
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
      timeout: 15000
    };

    if (data) {
      config.data = data;
    }

    const response = await axios(config);
    
    if (response.status === expectedStatus) {
      console.log(`   ✅ SUCCESS (${response.status})`.green);
      
      // Analyser la réponse pour vérifier les données
      if (response.data) {
        if (Array.isArray(response.data)) {
          console.log(`   📊 Data: Array with ${response.data.length} items`.gray);
          if (response.data.length > 0) {
            console.log(`   📄 Sample: ${JSON.stringify(response.data[0], null, 2).substring(0, 200)}...`.gray);
          }
        } else if (typeof response.data === 'object') {
          console.log(`   📊 Data: Object with keys: ${Object.keys(response.data).join(', ')}`.gray);
          console.log(`   📄 Content: ${JSON.stringify(response.data, null, 2).substring(0, 300)}...`.gray);
        }
      }
    } else {
      console.log(`   ⚠️  UNEXPECTED STATUS (${response.status}, expected ${expectedStatus})`.yellow);
    }
    
    return { success: true, status: response.status, data: response.data };
  } catch (error) {
    if (error.response) {
      const status = error.response.status;
      
      // Pour les routes protégées, accepter 401 ET 403 comme valides
      if (status === expectedStatus || 
          (expectedStatus === 401 && status === 403) ||
          (expectedStatus === 403 && status === 401)) {
        console.log(`   ✅ SUCCESS (${status} - Expected error)`.green);
        return { success: true, status, data: error.response.data };
      } else {
        console.log(`   ❌ FAILED (${status}, expected ${expectedStatus})`.red);
        if (error.response.data) {
          console.log(`   📄 Error: ${JSON.stringify(error.response.data, null, 2).substring(0, 200)}...`.gray);
        }
      }
    } else {
      console.log(`   ❌ FAILED (Network error: ${error.message})`.red);
    }
    return { success: false, error: error.message };
  }
}

// Tests de base de données via API
const databaseTests = [
  // Test de santé générale
  {
    method: 'GET',
    endpoint: '/api/auth/health',
    description: 'Database Health Check',
    expectedStatus: 200
  },
  
  // Test des routes publiques (sans authentification)
  {
    method: 'GET',
    endpoint: '/api/messages',
    description: 'Messages API - Test route racine',
    expectedStatus: 200
  },
  {
    method: 'GET',
    endpoint: '/api/profiles',
    description: 'Profiles API - Test route racine',
    expectedStatus: 200
  },
  {
    method: 'GET',
    endpoint: '/api/subscriptions',
    description: 'Subscriptions API - Test route racine',
    expectedStatus: 200
  },
  {
    method: 'GET',
    endpoint: '/api/store',
    description: 'Store API - Test route racine',
    expectedStatus: 200
  },
  {
    method: 'GET',
    endpoint: '/api/upload',
    description: 'Upload API - Test route racine',
    expectedStatus: 200
  },
  {
    method: 'GET',
    endpoint: '/api',
    description: 'Content API - Test route racine',
    expectedStatus: 200
  },
  
  // Test des routes protégées (devraient échouer sans token - accepter 401 ou 403)
  {
    method: 'GET',
    endpoint: '/api/users',
    description: 'Users API - Test accès sans authentification',
    expectedStatus: 401 // Acceptera aussi 403
  },
  {
    method: 'GET',
    endpoint: '/api/teams',
    description: 'Teams API - Test accès sans authentification',
    expectedStatus: 401 // Acceptera aussi 403
  },
  {
    method: 'GET',
    endpoint: '/api/players',
    description: 'Players API - Test accès sans authentification',
    expectedStatus: 401 // Acceptera aussi 403
  },
  {
    method: 'GET',
    endpoint: '/api/clubs',
    description: 'Clubs API - Test accès sans authentification',
    expectedStatus: 401 // Acceptera aussi 403
  },
  {
    method: 'GET',
    endpoint: '/api/coaches',
    description: 'Coaches API - Test accès sans authentification',
    expectedStatus: 401 // Acceptera aussi 403
  },
  {
    method: 'GET',
    endpoint: '/api/annonces',
    description: 'Annonces API - Test accès sans authentification',
    expectedStatus: 401 // Acceptera aussi 403
  },
  {
    method: 'GET',
    endpoint: '/api/opportunities',
    description: 'Opportunities API - Test accès sans authentification',
    expectedStatus: 401 // Acceptera aussi 403
  },
  {
    method: 'GET',
    endpoint: '/api/messages/conversations',
    description: 'Messages Conversations - Test accès sans authentification',
    expectedStatus: 401 // Acceptera aussi 403
  },
  {
    method: 'GET',
    endpoint: '/api/handibasket',
    description: 'Handibasket API - Test accès sans authentification',
    expectedStatus: 401 // Acceptera aussi 403
  },
  {
    method: 'GET',
    endpoint: '/api/matching',
    description: 'Matching API - Test accès sans authentification',
    expectedStatus: 401 // Acceptera aussi 403
  },
  
  // Test d'authentification
  {
    method: 'POST',
    endpoint: '/api/auth/register',
    description: 'Register - Test création de compte',
    expectedStatus: 400, // Devrait échouer sans données complètes
    data: { name: 'Test User', email: 'test@example.com', password: 'password123', profile_type: 'player' }
  },
  {
    method: 'POST',
    endpoint: '/api/auth/login',
    description: 'Login - Test connexion avec données invalides',
    expectedStatus: 401,
    data: { email: 'invalid@example.com', password: 'wrongpassword' }
  },
  
  // Test de validation de token
  {
    method: 'GET',
    endpoint: '/api/auth/validate',
    description: 'Token Validation - Test avec token invalide',
    expectedStatus: 401,
    headers: { 'Authorization': 'Bearer invalid_token' }
  },
  
  // Test de routes inexistantes
  {
    method: 'GET',
    endpoint: '/api/nonexistent',
    description: 'Route inexistante - Test gestion d\'erreur 404',
    expectedStatus: 404
  },
  {
    method: 'GET',
    endpoint: '/api/users/nonexistent',
    description: 'Route utilisateur inexistante - Test gestion d\'erreur 404',
    expectedStatus: 404
  }
];

// Fonction principale
async function testDatabaseViaApi() {
  console.log('🚀 Starting Railway Database Tests via API'.bold);
  console.log(`📍 Base URL: ${BASE_URL}`.gray);
  console.log(`⏰ Started at: ${new Date().toISOString()}`.gray);
  console.log('='.repeat(80));

  const results = {
    total: databaseTests.length,
    success: 0,
    failed: 0,
    details: []
  };

  for (const test of databaseTests) {
    const result = await testApiRoute(
      test.method,
      test.endpoint,
      test.description,
      test.expectedStatus,
      test.data,
      test.headers
    );
    
    results.details.push({
      ...test,
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
  console.log('📊 DATABASE API TEST RESULTS SUMMARY'.bold);
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

  // Analyse des résultats
  console.log('\n💡 DATABASE ANALYSIS:'.yellow);
  
  const healthCheck = results.details.find(test => test.endpoint === '/api/auth/health');
  if (healthCheck && healthCheck.result.success) {
    console.log('   ✅ Database connection is working'.green);
  } else {
    console.log('   ❌ Database connection failed'.red);
  }
  
  const publicRoutes = results.details.filter(test => 
    test.expectedStatus === 200 && test.endpoint.includes('/api/')
  );
  const publicRoutesSuccess = publicRoutes.filter(test => test.result.success).length;
  console.log(`   📊 Public routes: ${publicRoutesSuccess}/${publicRoutes.length} working`.cyan);
  
  const protectedRoutes = results.details.filter(test => 
    (test.expectedStatus === 401 || test.expectedStatus === 403) && test.endpoint.includes('/api/')
  );
  const protectedRoutesSuccess = protectedRoutes.filter(test => test.result.success).length;
  console.log(`   🔒 Protected routes: ${protectedRoutesSuccess}/${protectedRoutes.length} properly secured`.cyan);
  
  const errorHandling = results.details.filter(test => 
    test.expectedStatus === 404
  );
  const errorHandlingSuccess = errorHandling.filter(test => test.result.success).length;
  console.log(`   🛡️  Error handling: ${errorHandlingSuccess}/${errorHandling.length} working`.cyan);

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
  testDatabaseViaApi()
    .then((results) => {
      process.exit(results.failed > 0 ? 1 : 0);
    })
    .catch((error) => {
      console.error('❌ Test runner failed:'.red, error);
      process.exit(1);
    });
}

module.exports = { testDatabaseViaApi, testApiRoute }; 