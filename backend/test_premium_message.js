const axios = require('axios');

async function testPremiumMessage() {
  try {
    console.log('🧪 Test d\'envoi de message premium...\n');
    
    const baseURL = 'https://freeagenappmobile-production.up.railway.app';
    
    // 1. Login avec l'utilisateur premium
    console.log('1. Login avec l\'utilisateur premium...');
    const loginResponse = await axios.post(`${baseURL}/api/auth/login`, {
      email: 'premium@freeagent.com',
      password: 'Premium123!'
    });
    
    const token = loginResponse.data.token;
    const userId = loginResponse.data.user.id;
    console.log('✅ Login réussi!');
    console.log(`   User ID: ${userId}`);
    console.log(`   Token: ${token.substring(0, 20)}...`);
    console.log(`   Subscription: ${loginResponse.data.user.subscription_type || 'free'}`);
    console.log(`   Premium: ${loginResponse.data.user.is_premium || false}\n`);
    
    // 2. Test d'envoi de message
    console.log('2. Test d\'envoi de message...');
    try {
      const messageResponse = await axios.post(`${baseURL}/api/messages/conversations`, {
        receiverId: 1, // ID fictif
        content: 'Test message premium',
        subject: 'Test Premium'
      }, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      console.log(`✅ Message envoyé avec succès: ${messageResponse.status}`);
      console.log(`   Réponse: ${JSON.stringify(messageResponse.data)}`);
      
    } catch (error) {
      console.log(`❌ Erreur lors de l'envoi: ${error.response?.status}`);
      if (error.response?.data) {
        console.log(`   Message: ${error.response.data.message}`);
        console.log(`   Feature: ${error.response.data.feature}`);
        console.log(`   Subscription required: ${error.response.data.subscription_required}`);
      }
    }
    
    // 3. Test de récupération des conversations
    console.log('\n3. Test de récupération des conversations...');
    try {
      const convResponse = await axios.get(`${baseURL}/api/messages/conversations`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      console.log(`✅ Conversations récupérées: ${convResponse.status}`);
      console.log(`   Nombre de conversations: ${convResponse.data.conversations?.length || 0}`);
      
    } catch (error) {
      console.log(`❌ Erreur conversations: ${error.response?.status || error.message}`);
    }
    
    // 4. Test avec un autre utilisateur (gratuit)
    console.log('\n4. Test avec utilisateur gratuit (contrôle)...');
    try {
      const loginResponse2 = await axios.post(`${baseURL}/api/auth/login`, {
        email: 'frontend-test@freeagent.com',
        password: 'Test123!'
      });
      
      const token2 = loginResponse2.data.token;
      console.log('✅ Login gratuit réussi!');
      
      const messageResponse2 = await axios.post(`${baseURL}/api/messages/conversations`, {
        receiverId: 1,
        content: 'Test message gratuit',
        subject: 'Test Gratuit'
      }, {
        headers: { Authorization: `Bearer ${token2}` }
      });
      
      console.log(`❌ Message envoyé (anormal): ${messageResponse2.status}`);
      
    } catch (error) {
      console.log(`✅ Erreur 403 attendue pour utilisateur gratuit: ${error.response?.status}`);
      if (error.response?.data) {
        console.log(`   Message: ${error.response.data.message}`);
      }
    }
    
    console.log('\n🎯 DIAGNOSTIC:');
    console.log('   - Si le message premium est envoyé: ✅ Système fonctionne');
    console.log('   - Si le message premium échoue: ❌ Problème de configuration');
    console.log('   - Si le message gratuit échoue: ✅ Restrictions actives');
    
    console.log('\n📱 INFORMATIONS DE TEST:');
    console.log('   Premium: premium@freeagent.com / Premium123!');
    console.log('   Gratuit: frontend-test@freeagent.com / Test123!');
    
  } catch (error) {
    console.error('❌ Erreur générale:', error.message);
  }
}

testPremiumMessage(); 