const axios = require('axios');

async function createPremiumViaApi() {
  try {
    console.log('🔧 Création d\'un utilisateur premium via API...\n');
    
    const baseURL = 'https://freeagenappmobile-production.up.railway.app';
    
    // Données de l'utilisateur premium
    const userData = {
      email: 'premium2@freeagent.com',
      password: 'Premium123!',
      name: 'Premium User 2',
      profile_type: 'player'
    };
    
    console.log('📝 Tentative de création de l\'utilisateur premium...');
    console.log(`   Email: ${userData.email}`);
    console.log(`   Mot de passe: ${userData.password}`);
    
    try {
      const response = await axios.post(`${baseURL}/api/auth/register`, userData);
      
      console.log('✅ Utilisateur créé avec succès!');
      console.log(`   Statut: ${response.status}`);
      console.log(`   User ID: ${response.data.user?.id || 'N/A'}`);
      
      // Login pour obtenir le token
      console.log('\n🔐 Test de login...');
      const loginResponse = await axios.post(`${baseURL}/api/auth/login`, {
        email: userData.email,
        password: userData.password
      });
      
      console.log('✅ Login réussi!');
      const token = loginResponse.data.token;
      console.log(`   Token: ${token.substring(0, 20)}...`);
      console.log(`   Subscription: ${loginResponse.data.user.subscription_type || 'free'}`);
      console.log(`   Premium: ${loginResponse.data.user.is_premium || false}`);
      
      // Test d'envoi de message
      console.log('\n📨 Test d\'envoi de message...');
      try {
        const messageResponse = await axios.post(`${baseURL}/api/messages/conversations`, {
          receiverId: 1,
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
      
      console.log('\n📱 INFORMATIONS DE TEST:');
      console.log(`   Email: ${userData.email}`);
      console.log(`   Mot de passe: ${userData.password}`);
      console.log(`   Statut: ${loginResponse.data.user.subscription_type || 'free'}`);
      
      console.log('\n🔧 NOTE:');
      console.log('   - Cet utilisateur est créé en statut gratuit par défaut');
      console.log('   - Pour tester un utilisateur premium, il faut le mettre à jour manuellement');
      console.log('   - Ou créer un endpoint d\'administration pour changer le statut');
      
    } catch (error) {
      if (error.response?.status === 409) {
        console.log('⚠️  Utilisateur existe déjà, test de login...');
        
        const loginResponse = await axios.post(`${baseURL}/api/auth/login`, {
          email: userData.email,
          password: userData.password
        });
        
        console.log('✅ Login réussi!');
        const token = loginResponse.data.token;
        
        // Test d'envoi de message
        console.log('\n📨 Test d\'envoi de message...');
        try {
          const messageResponse = await axios.post(`${baseURL}/api/messages/conversations`, {
            receiverId: 1,
            content: 'Test message',
            subject: 'Test'
          }, {
            headers: { Authorization: `Bearer ${token}` }
          });
          
          console.log(`✅ Message envoyé avec succès: ${messageResponse.status}`);
          
        } catch (error) {
          console.log(`❌ Erreur lors de l'envoi: ${error.response?.status}`);
          if (error.response?.data) {
            console.log(`   Message: ${error.response.data.message}`);
          }
        }
        
      } else {
        console.log(`❌ Erreur lors de la création: ${error.response?.status || error.message}`);
        if (error.response?.data) {
          console.log(`   Détails: ${JSON.stringify(error.response.data)}`);
        }
      }
    }
    
  } catch (error) {
    console.error('❌ Erreur générale:', error.message);
  }
}

createPremiumViaApi(); 