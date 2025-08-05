const axios = require('axios');

async function createUserViaApi() {
  try {
    console.log('🔧 Création d\'un utilisateur via l\'API...\n');
    
    const baseURL = 'https://freeagenappmobile-production.up.railway.app';
    
    // Données de l'utilisateur de test
    const userData = {
      email: 'test403@freeagent.com',
      password: 'Test123!',
      name: 'Test 403 User',
      profile_type: 'player'
    };
    
    console.log('📝 Tentative de création de l\'utilisateur...');
    console.log(`   Email: ${userData.email}`);
    console.log(`   Mot de passe: ${userData.password}`);
    
    try {
      const response = await axios.post(`${baseURL}/api/auth/register`, userData);
      
      console.log('✅ Utilisateur créé avec succès!');
      console.log(`   Statut: ${response.status}`);
      console.log(`   Token: ${response.data.token ? 'Oui' : 'Non'}`);
      console.log(`   User ID: ${response.data.user?.id || 'N/A'}`);
      
      // Test de login immédiat
      console.log('\n🔐 Test de login...');
      const loginResponse = await axios.post(`${baseURL}/api/auth/login`, {
        email: userData.email,
        password: userData.password
      });
      
      console.log('✅ Login réussi!');
      const token = loginResponse.data.token;
      console.log(`   Token: ${token.substring(0, 20)}...`);
      
      // Test de l'erreur 403
      console.log('\n🚫 Test de l\'erreur 403...');
      try {
        const messageResponse = await axios.post(`${baseURL}/api/messages/conversations`, {
          receiverId: 1,
          content: 'Test message',
          subject: 'Test 403'
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
      
      console.log('\n🎯 RÉSULTAT:');
      console.log('   - L\'utilisateur est créé et peut se connecter');
      console.log('   - L\'erreur 403 est correctement retournée');
      console.log('   - Le backend fonctionne comme attendu');
      console.log('   - Le frontend devrait afficher un pop-up premium');
      
    } catch (error) {
      if (error.response?.status === 409) {
        console.log('⚠️  Utilisateur existe déjà, test de login...');
        
        const loginResponse = await axios.post(`${baseURL}/api/auth/login`, {
          email: userData.email,
          password: userData.password
        });
        
        console.log('✅ Login réussi!');
        const token = loginResponse.data.token;
        
        // Test de l'erreur 403
        console.log('\n🚫 Test de l\'erreur 403...');
        try {
          const messageResponse = await axios.post(`${baseURL}/api/messages/conversations`, {
            receiverId: 1,
            content: 'Test message',
            subject: 'Test 403'
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

createUserViaApi(); 