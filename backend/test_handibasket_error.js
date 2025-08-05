const axios = require('axios');

async function testHandibasketRegistration() {
  console.log('🔍 Test d\'inscription handibasket...');
  
  const testData = {
    name: "Test Handibasket Diagnostic",
    email: "testhandidiag@test.com",
    password: "test123",
    profile_type: "handibasket",
    birth_date: "1990-01-01",
    handicap_type: "moteur",
    cat: "SportAdpt",
    residence: "Paris",
    profession: "Sportif"
  };

  try {
    console.log('📤 Envoi de la requête...');
    console.log('📋 Données:', JSON.stringify(testData, null, 2));
    
    const response = await axios.post(
      'https://freeagenappmobile-production.up.railway.app/api/auth/register',
      testData,
      {
        headers: {
          'Content-Type': 'application/json'
        },
        timeout: 10000
      }
    );
    
    console.log('✅ Succès!');
    console.log('📊 Status:', response.status);
    console.log('📄 Réponse:', response.data);
    
  } catch (error) {
    console.log('❌ Erreur détectée:');
    console.log('📊 Status:', error.response?.status);
    console.log('📄 Message:', error.response?.data);
    console.log('🔍 Détails:', error.message);
    
    if (error.response?.data?.error) {
      console.log('🐛 Erreur serveur:', error.response.data.error);
    }
  }
}

async function testDatabaseConnection() {
  console.log('\n🔌 Test de connexion à la base de données...');
  
  try {
    const response = await axios.get(
      'https://freeagenappmobile-production.up.railway.app/api/auth/login',
      {
        headers: {
          'Content-Type': 'application/json'
        },
        timeout: 5000
      }
    );
    
    console.log('✅ Connexion API OK');
    
  } catch (error) {
    console.log('❌ Problème de connexion API:', error.message);
  }
}

async function main() {
  console.log('🚀 Diagnostic du problème handibasket\n');
  
  await testDatabaseConnection();
  await testHandibasketRegistration();
  
  console.log('\n🏁 Diagnostic terminé');
}

main().catch(console.error); 