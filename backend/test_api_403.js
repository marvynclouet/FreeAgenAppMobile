const axios = require('axios');

async function testApi403() {
  try {
    console.log('🔍 Test de l\'API - Erreur 403\n');
    
    const baseURL = 'https://freeagenappmobile-production.up.railway.app';
    
    // 1. Test de connectivité
    console.log('1. Test de connectivité...');
    try {
      const response = await axios.get(`${baseURL}/api/messages`);
      console.log(`✅ API accessible: ${response.status}`);
      console.log(`✅ Message: ${response.data.message}\n`);
    } catch (error) {
      console.log(`❌ API inaccessible: ${error.response?.status || error.message}`);
      console.log(`   URL testée: ${baseURL}/api/messages`);
      console.log();
      return;
    }
    
    // 2. Test de login pour obtenir un token
    console.log('2. Test de login...');
    let token;
    try {
      const loginResponse = await axios.post(`${baseURL}/api/auth/login`, {
        email: 'marvyn@gmail.com',
        password: 'Marvyn2024!'
      });
      
      token = loginResponse.data.token;
      console.log('✅ Login réussi');
      console.log(`✅ Token obtenu: ${token.substring(0, 20)}...\n`);
    } catch (error) {
      console.log(`❌ Login échoué: ${error.response?.status || error.message}`);
      if (error.response?.data) {
        console.log(`   Détails: ${JSON.stringify(error.response.data)}`);
      }
      console.log();
      
      // Essayer avec un autre utilisateur
      console.log('🔄 Tentative avec un autre utilisateur...');
      try {
        const loginResponse2 = await axios.post(`${baseURL}/api/auth/login`, {
          email: 'test@freeagent.com',
          password: 'Test123!'
        });
        
        token = loginResponse2.data.token;
        console.log('✅ Login réussi avec test@freeagent.com');
        console.log(`✅ Token obtenu: ${token.substring(0, 20)}...\n`);
      } catch (error2) {
        console.log(`❌ Login échoué aussi: ${error2.response?.status || error2.message}`);
        console.log('   Impossible de se connecter, arrêt du test');
        return;
      }
    }
    
    // 3. Test de récupération des conversations
    console.log('3. Test de récupération des conversations...');
    try {
      const convResponse = await axios.get(`${baseURL}/api/messages/conversations`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      console.log(`✅ Conversations récupérées: ${convResponse.status}`);
      console.log(`✅ Nombre de conversations: ${convResponse.data.conversations?.length || 0}\n`);
      
      // Afficher les conversations
      if (convResponse.data.conversations && convResponse.data.conversations.length > 0) {
        console.log('📨 Conversations disponibles:');
        convResponse.data.conversations.forEach((conv, index) => {
          console.log(`   ${index + 1}. ID: ${conv.id}, Sujet: ${conv.subject}`);
        });
        console.log();
      }
      
    } catch (error) {
      console.log(`❌ Erreur conversations: ${error.response?.status || error.message}`);
      if (error.response?.data) {
        console.log(`   Détails: ${JSON.stringify(error.response.data)}`);
      }
      console.log();
    }
    
    // 4. Test d'envoi de message (devrait donner 403)
    console.log('4. Test d\'envoi de message (devrait donner 403)...');
    try {
      const messageResponse = await axios.post(`${baseURL}/api/messages/conversations`, {
        receiverId: 1, // ID fictif
        content: 'Test message',
        subject: 'Test'
      }, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      console.log(`❌ Message envoyé (anormal): ${messageResponse.status}`);
      console.log(`   Réponse: ${JSON.stringify(messageResponse.data)}`);
      
    } catch (error) {
      console.log(`✅ Erreur 403 attendue: ${error.response?.status}`);
      if (error.response?.data) {
        console.log(`   Message: ${error.response.data.message}`);
        console.log(`   Feature: ${error.response.data.feature}`);
        console.log(`   Subscription required: ${error.response.data.subscription_required}`);
      }
    }
    
    // 5. Test de vérification du statut utilisateur
    console.log('\n5. Test de vérification du statut utilisateur...');
    try {
      const profileResponse = await axios.get(`${baseURL}/api/profile`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      console.log(`✅ Profil récupéré: ${profileResponse.status}`);
      const user = profileResponse.data.user;
      console.log(`   Email: ${user.email}`);
      console.log(`   Type d'abonnement: ${user.subscription_type}`);
      console.log(`   Premium: ${user.is_premium}`);
      console.log(`   Expiration: ${user.subscription_expiry}`);
      
    } catch (error) {
      console.log(`❌ Erreur profil: ${error.response?.status || error.message}`);
    }
    
    console.log('\n🔧 DIAGNOSTIC:');
    console.log('   - Si l\'erreur 403 apparaît lors de l\'envoi de message, c\'est NORMAL');
    console.log('   - Le backend bloque correctement les utilisateurs gratuits');
    console.log('   - Le frontend devrait afficher un pop-up premium');
    console.log('   - Vérifiez que le pop-up s\'affiche dans l\'interface');
    
    console.log('\n📱 URL de test frontend:');
    console.log('   https://web-250vi39y0-marvynshes-projects.vercel.app/');
    
  } catch (error) {
    console.error('❌ Erreur générale:', error.message);
  }
}

testApi403(); 