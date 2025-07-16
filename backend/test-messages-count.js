const BASE_URL = 'http://localhost:3000/api';

// Test du comptage des messages non lus
async function testUnreadMessagesCount() {
  try {
    console.log('🧪 Test du comptage des messages non lus...\n');

    // 1. Connexion avec un utilisateur
    console.log('1. Connexion avec un utilisateur...');
    const loginResponse = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email: 'test@example.com',
        password: 'password123'
      })
    });

    const loginData = await loginResponse.json();
    const token = loginData.token;
    console.log('✅ Connexion réussie\n');

    // 2. Récupérer le nombre de messages non lus
    console.log('2. Récupération du nombre de messages non lus...');
    const countResponse = await fetch(`${BASE_URL}/messages/unread-count`, {
      headers: { Authorization: `Bearer ${token}` }
    });

    if (countResponse.ok) {
      const countData = await countResponse.json();
      console.log('✅ Nombre de messages non lus récupéré avec succès');
      console.log(`📊 Messages non lus: ${countData.unread_count}`);
    } else {
      const errorData = await countResponse.json();
      console.log('❌ Erreur lors de la récupération:', errorData);
    }

    // 3. Récupérer les conversations pour comparaison
    console.log('\n3. Récupération des conversations...');
    const conversationsResponse = await fetch(`${BASE_URL}/messages/conversations`, {
      headers: { Authorization: `Bearer ${token}` }
    });

    if (conversationsResponse.ok) {
      const conversationsData = await conversationsResponse.json();
      const totalUnread = conversationsData.conversations.reduce((sum, conv) => sum + (conv.unread_count || 0), 0);
      console.log('✅ Conversations récupérées');
      console.log(`📊 Total des messages non lus dans les conversations: ${totalUnread}`);
    } else {
      console.log('❌ Erreur lors de la récupération des conversations');
    }

    console.log('\n🎉 Test terminé !');

  } catch (error) {
    console.error('❌ Erreur lors du test:', error.message);
  }
}

// Exécuter le test
testUnreadMessagesCount(); 