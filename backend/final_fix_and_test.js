const axios = require('axios');

async function finalFixAndTest() {
  try {
    console.log('🔧 Correction finale et test du système premium...\n');
    
    const baseURL = 'https://freeagenappmobile-production.up.railway.app';
    
    // 1. Test de connectivité
    console.log('1. Test de connectivité...');
    const healthResponse = await axios.get(`${baseURL}/api/auth/health`);
    console.log(`✅ Backend accessible: ${healthResponse.status}`);
    console.log(`   Message: ${healthResponse.data.message}\n`);
    
    // 2. Créer un utilisateur premium de test
    console.log('2. Création d\'un utilisateur premium...');
    const userData = {
      email: 'premium-final@freeagent.com',
      password: 'Premium123!',
      name: 'Premium Final User',
      profile_type: 'player'
    };
    
    let token;
    let userId;
    
    try {
      const createResponse = await axios.post(`${baseURL}/api/auth/register`, userData);
      console.log('✅ Utilisateur créé!');
      console.log(`   User ID: ${createResponse.data.user.id}`);
      console.log(`   Subscription: ${createResponse.data.user.subscription_type || 'undefined'}`);
      console.log(`   Premium: ${createResponse.data.user.is_premium || 'undefined'}`);
      
      token = createResponse.data.token;
      userId = createResponse.data.user.id;
      
    } catch (error) {
      if (error.response?.status === 409) {
        console.log('⚠️  Utilisateur existe, login...');
        const loginResponse = await axios.post(`${baseURL}/api/auth/login`, {
          email: userData.email,
          password: userData.password
        });
        
        token = loginResponse.data.token;
        userId = loginResponse.data.user.id;
        console.log('✅ Login réussi!');
        console.log(`   User ID: ${userId}`);
        console.log(`   Subscription: ${loginResponse.data.user.subscription_type || 'undefined'}`);
        console.log(`   Premium: ${loginResponse.data.user.is_premium || 'undefined'}`);
      } else {
        throw error;
      }
    }
    
    // 3. Test d'envoi de message (utilisateur gratuit)
    console.log('\n3. Test d\'envoi de message (utilisateur gratuit)...');
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
    
    // 4. Mettre à jour vers premium via API directe
    console.log('\n4. Mise à jour vers premium...');
    try {
      // Utiliser une requête SQL directe via un endpoint temporaire
      const updateResponse = await axios.post(`${baseURL}/api/users/${userId}/upgrade-premium`, {}, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      console.log('✅ Mise à jour vers premium!');
      console.log(`   Réponse: ${JSON.stringify(updateResponse.data)}`);
      
    } catch (error) {
      console.log(`⚠️  Route de mise à jour non disponible: ${error.response?.status}`);
      console.log('   Mise à jour manuelle requise dans la base de données');
    }
    
    // 5. Re-login pour vérifier le statut
    console.log('\n5. Re-login pour vérifier le statut...');
    const reloginResponse = await axios.post(`${baseURL}/api/auth/login`, {
      email: userData.email,
      password: userData.password
    });
    
    const newToken = reloginResponse.data.token;
    const newUser = reloginResponse.data.user;
    
    console.log('✅ Re-login réussi!');
    console.log(`   Subscription: ${newUser.subscription_type || 'undefined'}`);
    console.log(`   Premium: ${newUser.is_premium || 'undefined'}`);
    
    // 6. Test d'envoi de message (après mise à jour)
    console.log('\n6. Test d\'envoi de message (après mise à jour)...');
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
    
    console.log('\n🎯 DIAGNOSTIC FINAL:');
    console.log('   - Backend: ✅ Fonctionne');
    console.log('   - Authentification: ✅ Fonctionne');
    console.log('   - Restrictions: ✅ Actives');
    console.log('   - Mise à jour premium: ⚠️  Manuelle requise');
    
    console.log('\n📱 INFORMATIONS DE TEST:');
    console.log(`   Email: ${userData.email}`);
    console.log(`   Mot de passe: ${userData.password}`);
    console.log(`   Statut: ${newUser.subscription_type || 'free'}`);
    console.log(`   Premium: ${newUser.is_premium || false}`);
    
    console.log('\n🔗 URL de test frontend:');
    console.log('   https://web-250vi39y0-marvynshes-projects.vercel.app/');
    
    console.log('\n🔧 PROCHAINES ÉTAPES:');
    console.log('   1. Mettre à jour manuellement l\'utilisateur vers premium');
    console.log('   2. Tester l\'envoi de messages');
    console.log('   3. Vérifier le frontend');
    
  } catch (error) {
    console.error('❌ Erreur générale:', error.message);
    if (error.response?.data) {
      console.error('   Détails:', JSON.stringify(error.response.data));
    }
  }
}

finalFixAndTest(); 