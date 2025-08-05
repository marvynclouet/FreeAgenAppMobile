const axios = require('axios');

async function createPremiumUser() {
  try {
    console.log('🔧 Création d\'un utilisateur premium pour test...\n');
    
    const baseURL = 'https://freeagenappmobile-production.up.railway.app';
    
    // Données de l'utilisateur premium
    const userData = {
      email: 'premium@freeagent.com',
      password: 'Premium123!',
      name: 'Premium Test User',
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
      
      // Mettre à jour l'utilisateur en premium
      console.log('\n⭐ Mise à jour vers premium...');
      const updateResponse = await axios.put(`${baseURL}/api/users/${loginResponse.data.user.id}`, {
        subscription_type: 'premium',
        is_premium: true,
        subscription_expiry: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString() // 1 an
      }, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      console.log('✅ Utilisateur mis à jour vers premium!');
      
      // Test d'envoi de message (devrait fonctionner)
      console.log('\n📨 Test d\'envoi de message (devrait fonctionner)...');
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
          console.log(`   Détails: ${JSON.stringify(error.response.data)}`);
        }
      }
      
      console.log('\n🎯 RÉSULTAT:');
      console.log('   - Utilisateur premium créé avec succès');
      console.log('   - Login fonctionne');
      console.log('   - Envoi de messages testé');
      
      console.log('\n📱 INFORMATIONS DE CONNEXION:');
      console.log(`   Email: ${userData.email}`);
      console.log(`   Mot de passe: ${userData.password}`);
      console.log(`   Statut: Premium`);
      
    } catch (error) {
      if (error.response?.status === 409) {
        console.log('⚠️  Utilisateur existe déjà, test de login...');
        
        const loginResponse = await axios.post(`${baseURL}/api/auth/login`, {
          email: userData.email,
          password: userData.password
        });
        
        console.log('✅ Login réussi!');
        const token = loginResponse.data.token;
        
        // Vérifier le statut premium
        const profileResponse = await axios.get(`${baseURL}/api/profile`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        
        const user = profileResponse.data.user;
        console.log(`   Type d'abonnement: ${user.subscription_type}`);
        console.log(`   Premium: ${user.is_premium}`);
        
        if (user.subscription_type === 'free') {
          console.log('⚠️  Utilisateur est gratuit, mise à jour vers premium...');
          
          const updateResponse = await axios.put(`${baseURL}/api/users/${user.id}`, {
            subscription_type: 'premium',
            is_premium: true,
            subscription_expiry: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString()
          }, {
            headers: { Authorization: `Bearer ${token}` }
          });
          
          console.log('✅ Utilisateur mis à jour vers premium!');
        }
        
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
          
        } catch (error) {
          console.log(`❌ Erreur lors de l'envoi: ${error.response?.status}`);
          if (error.response?.data) {
            console.log(`   Détails: ${JSON.stringify(error.response.data)}`);
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

createPremiumUser(); 