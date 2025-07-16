const mysql = require('mysql2/promise');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'freeagent_db',
  port: process.env.DB_PORT || 3306
};

async function testContentAPI() {
  let connection;
  
  try {
    console.log('🧪 Test de l\'API de contenu...');
    
    connection = await mysql.createConnection(dbConfig);
    
    // Récupérer un utilisateur existant
    const [users] = await connection.execute('SELECT id, email FROM users LIMIT 1');
    
    if (users.length === 0) {
      console.log('❌ Aucun utilisateur trouvé');
      return;
    }
    
    const user = users[0];
    console.log(`👤 Utilisateur de test : ${user.email}`);
    
    // Créer un token JWT
    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '1h' }
    );
    
    console.log('🔑 Token créé');
    
    // Test de l'API avec fetch (simulation)
    console.log('\n📡 Test de l\'endpoint /api/feed...');
    
    // Simuler une requête HTTP
    const http = require('http');
    
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/api/feed',
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    };
    
    const req = http.request(options, (res) => {
      console.log(`📊 Status: ${res.statusCode}`);
      
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          console.log('✅ Réponse de l\'API :');
          console.log(`   - Nombre d'éléments dans le feed : ${response.feed?.length || 0}`);
          
          if (response.feed && response.feed.length > 0) {
            console.log('   - Types de contenu trouvés :');
            const types = [...new Set(response.feed.map(item => item.type))];
            types.forEach(type => {
              const count = response.feed.filter(item => item.type === type).length;
              console.log(`     • ${type} : ${count}`);
            });
            
            console.log('\n📝 Premier élément du feed :');
            const firstItem = response.feed[0];
            console.log(`   - Type : ${firstItem.type}`);
            console.log(`   - Auteur : ${firstItem.author?.name || 'N/A'}`);
            console.log(`   - Contenu : ${firstItem.content?.substring(0, 50)}...`);
            console.log(`   - Likes : ${firstItem.likes || 0}`);
            console.log(`   - Commentaires : ${firstItem.comments || 0}`);
          }
        } catch (error) {
          console.log('❌ Erreur lors du parsing de la réponse :', error.message);
          console.log('📄 Réponse brute :', data);
        }
      });
    });
    
    req.on('error', (error) => {
      console.log('❌ Erreur de requête :', error.message);
    });
    
    req.end();
    
  } catch (error) {
    console.error('❌ Erreur lors du test :', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

// Exécuter le test
testContentAPI(); 