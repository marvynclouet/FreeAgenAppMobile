const BASE_URL = 'https://freeagenappmobile-production.up.railway.app/api';

// Test des erreurs 403 pour identifier les pages problématiques
async function testMessage403() {
  try {
    console.log('🧪 Test des erreurs 403 - Messages\n');

    // 1. Connexion avec un utilisateur non premium
    console.log('1. Connexion avec un utilisateur non premium...');
    const loginResponse = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email: 'marvyn@gmail.com',
        password: 'Marvyn2024!'
      })
    });

    const loginData = await loginResponse.json();
    const token = loginData.token;
    console.log('✅ Connexion réussie\n');

    // 2. Vérifier le statut d'abonnement
    console.log('2. Vérification du statut d\'abonnement...');
    const userResponse = await fetch(`${BASE_URL}/users/profile`, {
      headers: { Authorization: `Bearer ${token}` }
    });

    const userData = await userResponse.json();
    const subscriptionType = userData.subscription_type;
    console.log(`📊 Type d'abonnement: ${subscriptionType || 'free'}\n`);

    // 3. Tenter d'envoyer un message (devrait être bloqué)
    console.log('3. Tentative d\'envoi de message...');
    const messageResponse = await fetch(`${BASE_URL}/messages/conversations`, {
      method: 'POST',
      headers: { 
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        receiverId: 1,
        content: 'Test message',
        subject: 'Test'
      })
    });

    console.log(`📡 Statut de la réponse: ${messageResponse.status}`);
    
    if (messageResponse.status === 403) {
      const errorData = await messageResponse.json();
      console.log('❌ Erreur 403 détectée:');
      console.log('Message:', errorData.message);
      console.log('Feature:', errorData.feature);
      console.log('Subscription required:', errorData.subscription_required);
    } else if (messageResponse.status === 200) {
      console.log('✅ Message envoyé avec succès (utilisateur premium)');
    } else {
      console.log('⚠️ Autre erreur:', messageResponse.status);
    }

  } catch (error) {
    console.error('❌ Erreur lors du test:', error);
  }
}

// Exécuter le test
testMessage403(); 