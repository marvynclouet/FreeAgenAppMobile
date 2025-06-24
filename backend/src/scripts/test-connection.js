const pool = require('../config/db.config');

async function testConnection() {
  try {
    const connection = await pool.getConnection();
    console.log('✅ Connexion à la base de données réussie !');
    
    // Test d'une requête simple
    const [rows] = await connection.query('SELECT 1 as test');
    console.log('✅ Test de requête réussi !', rows);
    
    connection.release();
  } catch (error) {
    console.error('❌ Erreur de connexion :', error.message);
    console.error('Détails de l\'erreur :', error);
  } finally {
    process.exit();
  }
}

testConnection(); 