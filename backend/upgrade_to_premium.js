const axios = require('axios');

async function upgradeToPremium() {
  try {
    console.log('🔧 Mise à jour vers premium...\n');
    
    const baseURL = 'https://freeagenappmobile-production.up.railway.app';
    
    // Données de l'utilisateur
    const userData = {
      email: 'premium@freeagent.com',
      password: 'Premium123!'
    };
    
    console.log('🔐 Login avec l\'utilisateur...');
    const loginResponse = await axios.post(`${baseURL}/api/auth/login`, userData);
    
    console.log('✅ Login réussi!');
    const token = loginResponse.data.token;
    const userId = loginResponse.data.user.id;
    console.log(`   User ID: ${userId}`);
    console.log(`   Token: ${token.substring(0, 20)}...`);
    
    // Vérifier le statut actuel
    console.log('\n📊 Statut actuel...');
    const profileResponse = await axios.get(`${baseURL}/api/profile`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    const user = profileResponse.data.user;
    console.log(`   Type d'abonnement: ${user.subscription_type}`);
    console.log(`   Premium: ${user.is_premium}`);
    
    if (user.subscription_type === 'premium') {
      console.log('✅ Utilisateur déjà premium!');
    } else {
      console.log('⚠️  Utilisateur gratuit, mise à jour nécessaire...');
      console.log('   (Mise à jour manuelle requise dans la base de données)');
    }
    
    // Test d'envoi de message
    console.log('\n📨 Test d\'envoi de message...');
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
    
    console.log('\n📱 INFORMATIONS DE CONNEXION:');
    console.log(`   Email: ${userData.email}`);
    console.log(`   Mot de passe: ${userData.password}`);
    console.log(`   Statut actuel: ${user.subscription_type}`);
    
    console.log('\n🔧 Si l\'utilisateur est encore gratuit:');
    console.log('   - Connectez-vous à la base de données');
    console.log('   - Mettez à jour: UPDATE users SET subscription_type = "premium", is_premium = TRUE WHERE email = "premium@freeagent.com"');
    
  } catch (error) {
    console.error('❌ Erreur:', error.message);
  }
}

upgradeToPremium(); 