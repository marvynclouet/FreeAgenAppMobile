const axios = require('axios');

const API_BASE_URL = 'https://freeagenappmobile-production.up.railway.app/api';

// Fonction pour tester l'inscription handibasket
async function testHandibasketRegistration() {
  console.log('🧪 Test d\'inscription handibasket...');
  
  const testEmail = `test.handibasket.${Date.now()}@test.com`;
  const registrationData = {
    name: 'Test Handibasket Deployed',
    email: testEmail,
    password: 'test123',
    profile_type: 'handibasket',
    birth_date: '1990-01-01',
    handicap_type: 'Physique',
    cat: 'Sport',
    residence: 'Paris',
    profession: 'Étudiant'
  };

  try {
    const response = await axios.post(`${API_BASE_URL}/auth/register`, registrationData);
    console.log('✅ Inscription réussie:', {
      status: response.status,
      message: response.data.message,
      userId: response.data.user?.id,
      email: response.data.user?.email
    });
    return { success: true, email: testEmail, token: response.data.token };
  } catch (error) {
    console.log('❌ Erreur d\'inscription:', {
      status: error.response?.status,
      message: error.response?.data?.message || error.message,
      details: error.response?.data?.details
    });
    return { success: false, error: error.response?.data || error.message };
  }
}

// Fonction pour tester la connexion handibasket
async function testHandibasketLogin(email, password = 'test123') {
  console.log('🔐 Test de connexion handibasket...');
  
  try {
    const response = await axios.post(`${API_BASE_URL}/auth/login`, {
      email,
      password
    });
    
    console.log('✅ Connexion réussie:', {
      status: response.status,
      message: response.data.message,
      userId: response.data.user?.id,
      profileType: response.data.user?.profile_type,
      subscriptionType: response.data.user?.subscription_type,
      isPremium: response.data.user?.is_premium
    });
    return { success: true, token: response.data.token, user: response.data.user };
  } catch (error) {
    console.log('❌ Erreur de connexion:', {
      status: error.response?.status,
      message: error.response?.data?.message || error.message
    });
    return { success: false, error: error.response?.data || error.message };
  }
}

// Fonction pour tester la validation du token
async function testTokenValidation(token) {
  console.log('🔍 Test de validation du token...');
  
  try {
    const response = await axios.get(`${API_BASE_URL}/auth/validate`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    console.log('✅ Token valide:', {
      status: response.status,
      valid: response.data.valid,
      userId: response.data.user?.id,
      profileType: response.data.user?.profile_type
    });
    return { success: true, user: response.data.user };
  } catch (error) {
    console.log('❌ Token invalide:', {
      status: error.response?.status,
      message: error.response?.data?.message || error.message
    });
    return { success: false, error: error.response?.data || error.message };
  }
}

// Test avec un compte existant
async function testExistingHandibasketAccount() {
  console.log('\n📋 Test avec un compte handibasket existant...');
  
  const existingEmail = 'test.handibasket4@test.com';
  const loginResult = await testHandibasketLogin(existingEmail);
  
  if (loginResult.success) {
    await testTokenValidation(loginResult.token);
  }
}

// Test complet
async function runCompleteTest() {
  console.log('🚀 Début des tests handibasket sur l\'API déployée\n');
  
  // Test 1: Inscription d'un nouveau compte
  const registrationResult = await testHandibasketRegistration();
  
  if (registrationResult.success) {
    // Test 2: Connexion avec le compte créé
    await testHandibasketLogin(registrationResult.email);
    
    // Test 3: Validation du token
    await testTokenValidation(registrationResult.token);
  }
  
  // Test 4: Compte existant
  await testExistingHandibasketAccount();
  
  console.log('\n🏁 Tests terminés');
}

// Exécuter les tests
runCompleteTest().catch(console.error); 