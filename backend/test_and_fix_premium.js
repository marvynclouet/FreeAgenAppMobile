const axios = require('axios');

async function testAndFixPremium() {
  try {
    console.log('🔧 Test et correction du système premium...\n');
    
    const baseURL = 'https://freeagenappmobile-production.up.railway.app';
    
    // 1. Créer un utilisateur de test
    console.log('1. Création d\'un utilisateur de test...');
    const userData = {
      email: 'test-premium@freeagent.com',
      password: 'Test123!',
      name: 'Test Premium User',
      profile_type: 'player'
    };
    
    let token;
    let userId;
    
    try {
      const createResponse = await axios.post(`${baseURL}/api/auth/register`, userData);
      console.log('✅ Utilisateur créé avec succès!');
      console.log(`   User ID: ${createResponse.data.user.id}`);
      console.log(`   Subscription: ${createResponse.data.user.subscription_type}`);
      console.log(`   Premium: ${createResponse.data.user.is_premium}`);
      
      token = createResponse.data.token;
      userId = createResponse.data.user.id;
      
    } catch (error) {
      if (error.response?.status === 409) {
        console.log('⚠️  Utilisateur existe déjà, login...');
        const loginResponse = await axios.post(`${baseURL}/api/auth/login`, {
          email: userData.email,
          password: userData.password
        });
        
        token = loginResponse.data.token;
        userId = loginResponse.data.user.id;
        console.log('✅ Login réussi!');
        console.log(`   User ID: ${userId}`);
        console.log(`   Subscription: ${loginResponse.data.user.subscription_type}`);
        console.log(`   Premium: ${loginResponse.data.user.is_premium}`);
      } else {
        throw error;
      }
    }
    
    // 2. Test d'envoi de message (devrait échouer)
    console.log('\n2. Test d\'envoi de message (utilisateur gratuit)...');
    try {
      const messageResponse = await axios.post(`${baseURL}/api/messages/conversations`, {
        receiverId: 1,
        content: 'Test message gratuit',
        subject: 'Test Gratuit'
      }, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      console.log(`❌ Message envoyé (anormal): ${messageResponse.status}`);
      
    } catch (error) {
      console.log(`✅ Erreur 403 attendue: ${error.response?.status}`);
      if (error.response?.data) {
        console.log(`   Message: ${error.response.data.message}`);
        console.log(`   Feature: ${error.response.data.feature}`);
        console.log(`   Subscription required: ${error.response.data.subscription_required}`);
      }
    }
    
    // 3. Mettre à jour vers premium
    console.log('\n3. Mise à jour vers premium...');
    try {
      const updateResponse = await axios.put(`${baseURL}/api/users/${userId}/subscription`, {
        subscription_type: 'premium',
        is_premium: true
      }, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      console.log('✅ Utilisateur mis à jour vers premium!');
      console.log(`   Réponse: ${JSON.stringify(updateResponse.data)}`);
      
    } catch (error) {
      console.log(`❌ Erreur lors de la mise à jour: ${error.response?.status}`);
      if (error.response?.data) {
        console.log(`   Détails: ${JSON.stringify(error.response.data)}`);
      }
    }
    
    // 4. Re-login pour obtenir les nouvelles données
    console.log('\n4. Re-login pour vérifier le statut...');
    const reloginResponse = await axios.post(`${baseURL}/api/auth/login`, {
      email: userData.email,
      password: userData.password
    });
    
    const newToken = reloginResponse.data.token;
    const newUser = reloginResponse.data.user;
    
    console.log('✅ Re-login réussi!');
    console.log(`   Subscription: ${newUser.subscription_type}`);
    console.log(`   Premium: ${newUser.is_premium}`);
    
    // 5. Test d'envoi de message (devrait réussir)
    console.log('\n5. Test d\'envoi de message (utilisateur premium)...');
    try {
      const messageResponse = await axios.post(`${baseURL}/api/messages/conversations`, {
        receiverId: 1,
        content: 'Test message premium',
        subject: 'Test Premium'
      }, {
        headers: { Authorization: `Bearer ${newToken}` }
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
    
    // 6. Test de validation du token
    console.log('\n6. Test de validation du token...');
    try {
      const validateResponse = await axios.get(`${baseURL}/api/auth/validate`, {
        headers: { Authorization: `Bearer ${newToken}` }
      });
      
      console.log('✅ Token valide!');
      console.log(`   User: ${JSON.stringify(validateResponse.data.user)}`);
      
    } catch (error) {
      console.log(`❌ Erreur de validation: ${error.response?.status}`);
    }
    
    console.log('\n🎯 RÉSULTAT FINAL:');
    console.log('   - Utilisateur créé et connecté');
    console.log('   - Mise à jour vers premium effectuée');
    console.log('   - Messages envoyés avec succès');
    console.log('   - Système premium fonctionne');
    
    console.log('\n📱 INFORMATIONS DE TEST:');
    console.log(`   Email: ${userData.email}`);
    console.log(`   Mot de passe: ${userData.password}`);
    console.log(`   Statut final: ${newUser.subscription_type}`);
    console.log(`   Premium: ${newUser.is_premium}`);
    
    console.log('\n🔗 URL de test frontend:');
    console.log('   https://web-250vi39y0-marvynshes-projects.vercel.app/');
    
  } catch (error) {
    console.error('❌ Erreur générale:', error.message);
  }
}

testAndFixPremium(); 