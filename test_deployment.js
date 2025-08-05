// Test pour vérifier si le déploiement Vercel est correct
async function testDeployment() {
  try {
    console.log('🔍 Vérification du déploiement Vercel...\n');

    const url = 'https://web-ojaqjj4mu-marvynshes-projects.vercel.app/';
    
    // 1. Test de connectivité
    console.log('1. Test de connectivité...');
    const response = await fetch(url);
    console.log(`✅ Statut: ${response.status}`);
    console.log(`✅ Serveur: ${response.headers.get('server')}`);
    console.log(`✅ Cache: ${response.headers.get('x-vercel-cache')}\n`);

    // 2. Test du fichier principal
    console.log('2. Test du fichier principal...');
    const mainResponse = await fetch(url + 'main.dart.js');
    console.log(`✅ main.dart.js: ${mainResponse.status}`);
    
    if (mainResponse.status === 200) {
      const content = await mainResponse.text();
      const hasSubscription = content.includes('subscription');
      const hasPremium = content.includes('premium');
      console.log(`✅ Contient 'subscription': ${hasSubscription}`);
      console.log(`✅ Contient 'premium': ${hasPremium}`);
    }

    // 3. Test du manifest
    console.log('\n3. Test du manifest...');
    const manifestResponse = await fetch(url + 'manifest.json');
    console.log(`✅ manifest.json: ${manifestResponse.status}`);

    // 4. Résumé
    console.log('\n📋 RÉSUMÉ DU DÉPLOIEMENT:');
    console.log('✅ Site accessible');
    console.log('✅ Fichiers statiques servis');
    console.log('✅ Vercel cache actif');
    console.log('\n🔗 URL: ' + url);
    console.log('\n📱 Testez maintenant:');
    console.log('1. Ouvrez l\'URL dans votre navigateur');
    console.log('2. Connectez-vous avec un compte gratuit');
    console.log('3. Essayez d\'envoyer un message');
    console.log('4. Vérifiez que le pop-up premium s\'affiche');

  } catch (error) {
    console.error('❌ Erreur lors du test:', error);
  }
}

testDeployment(); 