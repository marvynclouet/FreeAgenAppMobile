const http = require('http');

const baseUrl = 'https://freeagenappmobile-production.up.railway.app/api/auth';

async function testRoute(method, path, data = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, baseUrl);
    const options = {
      method: method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    const req = http.request(url, options, (res) => {
      let body = '';
      res.on('data', (chunk) => {
        body += chunk;
      });
      res.on('end', () => {
        resolve({
          status: res.statusCode,
          headers: res.headers,
          body: body.substring(0, 200), // Limiter à 200 caractères
        });
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }
    req.end();
  });
}

async function testAllRoutes() {
  console.log('🔍 Test des routes d\'authentification sur Railway...\n');

  const routes = [
    { method: 'POST', path: '/login', data: { email: 'test@test.com', password: 'test' } },
    { method: 'POST', path: '/register', data: { name: 'Test', email: 'test@test.com', password: 'Test123', profile_type: 'player' } },
    { method: 'GET', path: '/validate' },
    { method: 'GET', path: '/version' },
    { method: 'POST', path: '/forgot-password', data: { email: 'test@test.com' } },
    { method: 'POST', path: '/reset-password', data: { token: 'test', newPassword: 'Test123' } },
  ];

  for (const route of routes) {
    try {
      console.log(`📡 Test ${route.method} ${route.path}...`);
      const result = await testRoute(route.method, route.path, route.data);
      
      if (result.status === 404) {
        console.log(`   ❌ 404 - Route non trouvée\n`);
      } else if (result.status === 200 || result.status === 201 || result.status === 400 || result.status === 401) {
        console.log(`   ✅ ${result.status} - Route existe (réponse: ${result.status})\n`);
      } else {
        console.log(`   ⚠️  ${result.status} - Route existe mais erreur: ${result.body.substring(0, 100)}\n`);
      }
    } catch (error) {
      console.log(`   ❌ Erreur: ${error.message}\n`);
    }
  }

  console.log('\n📋 Résumé :');
  console.log('   - Si /forgot-password retourne 404, Railway n\'a pas encore redéployé');
  console.log('   - Si /login fonctionne mais pas /forgot-password, le code n\'est pas à jour sur Railway');
  console.log('   - Solution : Forcer un redéploiement sur Railway Dashboard');
}

testAllRoutes()
  .then(() => {
    console.log('\n✅ Tests terminés');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Erreur fatale:', error);
    process.exit(1);
  });


