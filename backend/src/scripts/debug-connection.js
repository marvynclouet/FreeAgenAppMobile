require('dotenv').config();
const mysql = require('mysql2/promise');

// Afficher les variables d'environnement (sans le mot de passe)
console.log('Configuration de connexion :');
console.log('Host:', process.env.DB_HOST);
console.log('User:', process.env.DB_USER);
console.log('Database:', process.env.DB_NAME);
console.log('Port:', process.env.DB_PORT);
console.log('Password:', process.env.DB_PASSWORD ? '******' : 'non défini');

async function testConnection() {
  try {
    console.log('\nTentative de connexion...');
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      port: process.env.DB_PORT
    });
    
    console.log('✅ Connexion réussie !');
    
    // Test d'une requête simple
    const [rows] = await connection.query('SELECT 1 as test');
    console.log('✅ Test de requête réussi !', rows);
    
    await connection.end();
  } catch (error) {
    console.error('\n❌ Erreur de connexion :');
    console.error('Message:', error.message);
    console.error('Code:', error.code);
    console.error('Errno:', error.errno);
    console.error('SQL State:', error.sqlState);
  } finally {
    process.exit();
  }
}

testConnection(); 