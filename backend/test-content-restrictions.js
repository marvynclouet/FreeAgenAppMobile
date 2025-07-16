const BASE_URL = 'http://localhost:3000/api';

// Test des restrictions de contenu pour les utilisateurs non premium
async function testContentRestrictions() {
  try {
    console.log('🧪 Test des restrictions de contenu...\n');

    // 1. Connexion avec un utilisateur non premium
    console.log('1. Connexion avec un utilisateur non premium...');
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

    // 2. Vérifier le statut d'abonnement
    console.log('2. Vérification du statut d\'abonnement...');
    const userResponse = await fetch(`${BASE_URL}/users/profile`, {
      headers: { Authorization: `Bearer ${token}` }
    });

    const userData = await userResponse.json();
    const subscriptionType = userData.subscription_type;
    console.log(`📊 Type d'abonnement: ${subscriptionType || 'free'}\n`);

    // 3. Tenter de créer un post (devrait être bloqué)
    console.log('3. Tentative de création d\'un post...');
    try {
      const postResponse = await fetch(`${BASE_URL}/posts`, {
        method: 'POST',
        headers: { 
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          content: 'Test post from non-premium user',
          imageUrls: []
        })
      });

      if (postResponse.status === 403) {
        const errorData = await postResponse.json();
        console.log('✅ SUCCÈS: Création de post bloquée pour utilisateur non premium');
        console.log(`📝 Message: ${errorData.message}`);
      } else {
        console.log('❌ ERREUR: Le post a été créé alors qu\'il ne devrait pas l\'être');
      }
    } catch (error) {
      console.log('❌ ERREUR: Erreur lors de la création du post:', error.message);
    }

    // 4. Tenter de liker un post (devrait fonctionner)
    console.log('\n4. Tentative de like d\'un post...');
    try {
      const likeResponse = await fetch(`${BASE_URL}/posts/1/like`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}` }
      });

      if (likeResponse.ok) {
        console.log('✅ SUCCÈS: Like fonctionne pour utilisateur non premium');
      } else {
        const errorData = await likeResponse.json();
        console.log('❌ ERREUR: Like ne fonctionne pas:', errorData.message);
      }
    } catch (error) {
      console.log('❌ ERREUR: Erreur lors du like:', error.message);
    }

    // 5. Tenter de commenter un post (devrait fonctionner)
    console.log('\n5. Tentative de commentaire...');
    try {
      const commentResponse = await fetch(`${BASE_URL}/posts/1/comments`, {
        method: 'POST',
        headers: { 
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          content: 'Test comment from non-premium user'
        })
      });

      if (commentResponse.ok) {
        console.log('✅ SUCCÈS: Commentaire fonctionne pour utilisateur non premium');
      } else {
        const errorData = await commentResponse.json();
        console.log('❌ ERREUR: Commentaire ne fonctionne pas:', errorData.message);
      }
    } catch (error) {
      console.log('❌ ERREUR: Erreur lors du commentaire:', error.message);
    }

    // 6. Récupérer le feed (devrait fonctionner)
    console.log('\n6. Récupération du feed...');
    try {
      const feedResponse = await fetch(`${BASE_URL}/feed`, {
        headers: { Authorization: `Bearer ${token}` }
      });

      if (feedResponse.ok) {
        const feedData = await feedResponse.json();
        console.log('✅ SUCCÈS: Feed accessible pour utilisateur non premium');
        console.log(`📊 Nombre d'éléments dans le feed: ${feedData.feed.length}`);
      } else {
        const errorData = await feedResponse.json();
        console.log('❌ ERREUR: Feed inaccessible:', errorData.message);
      }
    } catch (error) {
      console.log('❌ ERREUR: Erreur lors de la récupération du feed:', error.message);
    }

    console.log('\n🎉 Test des restrictions terminé !');

  } catch (error) {
    console.error('❌ Erreur lors du test:', error.message);
  }
}

// Exécuter le test
testContentRestrictions(); 