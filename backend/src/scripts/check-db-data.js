const mysql = require('mysql2/promise');
const dbConfig = require('../config/db.config');

async function checkDatabaseData() {
  let connection;
  
  try {
    console.log('🔍 Vérification des données dans la base de données...');
    
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Connexion à la base de données établie');

    // Vérifier les utilisateurs
    const [users] = await connection.execute('SELECT COUNT(*) as count FROM users');
    console.log(`👥 Utilisateurs: ${users[0].count}`);

    // Vérifier les annonces
    const [annonces] = await connection.execute('SELECT COUNT(*) as count FROM annonces');
    console.log(`📢 Annonces: ${annonces[0].count}`);

    // Vérifier les messages
    const [messages] = await connection.execute('SELECT COUNT(*) as count FROM messages');
    console.log(`💬 Messages: ${messages[0].count}`);

    // Vérifier les posts
    const [posts] = await connection.execute('SELECT COUNT(*) as count FROM posts');
    console.log(`📝 Posts: ${posts[0].count}`);

    // Vérifier les opportunités
    const [opportunities] = await connection.execute('SELECT COUNT(*) as count FROM opportunities');
    console.log(`🎯 Opportunités: ${opportunities[0].count}`);

    // Afficher quelques exemples d'utilisateurs
    const [userExamples] = await connection.execute('SELECT id, email, profile_type, subscription_type, is_premium FROM users LIMIT 5');
    console.log('\n📋 Exemples d\'utilisateurs:');
    userExamples.forEach(user => {
      console.log(`  - ID: ${user.id}, Email: ${user.email}, Type: ${user.profile_type}, Abonnement: ${user.subscription_type}, Premium: ${user.is_premium}`);
    });

    // Afficher quelques exemples d'annonces
    const [annonceExamples] = await connection.execute('SELECT id, title, description FROM annonces LIMIT 3');
    console.log('\n📢 Exemples d\'annonces:');
    annonceExamples.forEach(annonce => {
      console.log(`  - ID: ${annonce.id}, Titre: ${annonce.title}`);
    });

  } catch (error) {
    console.error('❌ Erreur lors de la vérification:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

checkDatabaseData(); 