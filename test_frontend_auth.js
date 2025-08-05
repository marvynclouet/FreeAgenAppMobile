// Test de l'état d'authentification du frontend
async function testFrontendAuth() {
  try {
    console.log('🔍 Test de l\'état d\'authentification frontend...\n');
    
    const frontendURL = 'https://web-250vi39y0-marvynshes-projects.vercel.app/';
    const backendURL = 'https://freeagenappmobile-production.up.railway.app';
    
    // 1. Test de connectivité
    console.log('1. Test de connectivité...');
    try {
      const response = await fetch(frontendURL);
      console.log(`✅ Frontend accessible: ${response.status}\n`);
    } catch (error) {
      console.log(`❌ Frontend inaccessible: ${error.message}\n`);
      return;
    }
    
    // 2. Test de l'API backend
    console.log('2. Test de l\'API backend...');
    try {
      const apiResponse = await fetch(`${backendURL}/api/messages`);
      const apiData = await apiResponse.json();
      console.log(`✅ API accessible: ${apiResponse.status}\n`);
    } catch (error) {
      console.log(`❌ API inaccessible: ${error.message}\n`);
      return;
    }
    
    // 3. Test de login et token
    console.log('3. Test de login et token...');
    try {
      const loginResponse = await fetch(`${backendURL}/api/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: 'premium@freeagent.com',
          password: 'Premium123!'
        })
      });
      
      if (loginResponse.status === 200) {
        const loginData = await loginResponse.json();
        console.log('✅ Login réussi!');
        console.log(`   Token: ${loginData.token.substring(0, 20)}...`);
        console.log(`   User ID: ${loginData.user.id}`);
        console.log(`   Subscription: ${loginData.user.subscription_type || 'free'}`);
        console.log(`   Premium: ${loginData.user.is_premium || false}\n`);
        
        // 4. Test d'envoi de message avec token
        console.log('4. Test d\'envoi de message avec token...');
        const messageResponse = await fetch(`${backendURL}/api/messages/conversations`, {
          method: 'POST',
          headers: { 
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${loginData.token}`
          },
          body: JSON.stringify({
            receiverId: 1,
            content: 'Test message avec token',
            subject: 'Test Token'
          })
        });
        
        if (messageResponse.status === 200) {
          const messageData = await messageResponse.json();
          console.log('✅ Message envoyé avec succès!');
          console.log(`   Réponse: ${JSON.stringify(messageData)}`);
        } else {
          const errorData = await messageResponse.json();
          console.log(`❌ Erreur lors de l'envoi: ${messageResponse.status}`);
          console.log(`   Message: ${errorData.message}`);
          console.log(`   Feature: ${errorData.feature}`);
          console.log(`   Subscription required: ${errorData.subscription_required}`);
        }
        
      } else {
        const errorData = await loginResponse.json();
        console.log(`❌ Login échoué: ${loginResponse.status}`);
        console.log(`   Message: ${errorData.message}`);
      }
      
    } catch (error) {
      console.log(`❌ Erreur lors du test: ${error.message}`);
    }
    
    console.log('\n🔧 DIAGNOSTIC:');
    console.log('   - Si le login échoue: Vérifiez les identifiants');
    console.log('   - Si le message échoue avec 403: Utilisateur non premium');
    console.log('   - Si le message réussit: ✅ Système fonctionne');
    
    console.log('\n📱 INSTRUCTIONS DE TEST:');
    console.log('1. Ouvrez: ' + frontendURL);
    console.log('2. Connectez-vous avec: premium@freeagent.com / Premium123!');
    console.log('3. Vérifiez que vous êtes bien connecté');
    console.log('4. Essayez d\'envoyer un message');
    console.log('5. Vérifiez la console pour les erreurs');
    
    console.log('\n🎯 RÉSULTAT ATTENDU:');
    console.log('   - Login réussi');
    console.log('   - Token valide');
    console.log('   - Message envoyé (si premium) ou pop-up premium (si gratuit)');
    
  } catch (error) {
    console.error('❌ Erreur générale:', error);
  }
}

testFrontendAuth(); 