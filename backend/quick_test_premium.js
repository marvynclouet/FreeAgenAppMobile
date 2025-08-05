const axios = require('axios');

async function quickTestPremium() {
  try {
    console.log('🧪 Test rapide du système premium...\n');
    
    const baseURL = 'https://freeagenappmobile-production.up.railway.app';
    
    // Test avec un utilisateur existant
    console.log('1. Test de login avec utilisateur existant...');
    const loginResponse = await axios.post(`${baseURL}/api/auth/login`, {
      email: 'test-premium@freeagent.com',
      password: 'Test123!'
    });
    
    console.log('✅ Login réussi!');
    console.log(`   User ID: ${loginResponse.data.user.id}`);
    console.log(`   Subscription: ${loginResponse.data.user.subscription_type || 'undefined'}`);
    console.log(`   Premium: ${loginResponse.data.user.is_premium || 'undefined'}`);
    console.log(`   Token: ${loginResponse.data.token.substring(0, 20)}...`);
    
    const token = loginResponse.data.token;
    const userId = loginResponse.data.user.id;
    
    // Test d'envoi de message
    console.log('\n2. Test d\'envoi de message...');
    try {
      const messageResponse = await axios.post(`${baseURL}/api/messages/conversations`, {
        receiverId: 1,
        content: 'Test message',
        subject: 'Test'
      }, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      console.log(`✅ Message envoyé: ${messageResponse.status}`);
      
    } catch (error) {
      console.log(`❌ Erreur 403: ${error.response?.status}`);
      if (error.response?.data) {
        console.log(`   Message: ${error.response.data.message}`);
      }
    }
    
    // Test de validation du token
    console.log('\n3. Test de validation du token...');
    try {
      const validateResponse = await axios.get(`${baseURL}/api/auth/validate`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      console.log('✅ Token valide!');
      console.log(`   User: ${JSON.stringify(validateResponse.data.user)}`);
      
    } catch (error) {
      console.log(`❌ Erreur de validation: ${error.response?.status}`);
    }
    
    console.log('\n📱 INFORMATIONS DE TEST:');
    console.log(`   Email: test-premium@freeagent.com`);
    console.log(`   Mot de passe: Test123!`);
    
  } catch (error) {
    console.error('❌ Erreur:', error.message);
    if (error.response?.data) {
      console.error('   Détails:', JSON.stringify(error.response.data));
    }
  }
}

quickTestPremium(); 