const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');

// Configuration de la base de données
const dbConfig = {
  host: 'monorail.proxy.rlwy.net',
  port: 45189,
  user: 'root',
  password: 'HhGgFfEeDdCcBbAa123456789',
  database: 'railway'
};

async function createTestUser() {
  let connection;
  
  try {
    console.log('🔧 Création d\'un utilisateur de test...\n');
    
    connection = await mysql.createConnection(dbConfig);
    
    // Données de l'utilisateur de test
    const testUser = {
      email: 'test@freeagent.com',
      password: 'Test123!',
      name: 'Test User',
      profile_type: 'player'
    };
    
    // Vérifier si l'utilisateur existe déjà
    const [existingUser] = await connection.execute(
      'SELECT id FROM users WHERE email = ?',
      [testUser.email]
    );
    
    if (existingUser.length > 0) {
      console.log('⚠️  Utilisateur de test existe déjà');
      console.log(`   Email: ${testUser.email}`);
      console.log(`   Mot de passe: ${testUser.password}`);
      return;
    }
    
    // Hasher le mot de passe
    const hashedPassword = await bcrypt.hash(testUser.password, 10);
    
    // Créer l'utilisateur
    const [result] = await connection.execute(`
      INSERT INTO users (email, password, name, profile_type, subscription_type, is_premium, created_at)
      VALUES (?, ?, ?, ?, 'free', FALSE, NOW())
    `, [testUser.email, hashedPassword, testUser.name, testUser.profile_type]);
    
    const userId = result.insertId;
    
    // Créer le profil
    await connection.execute(`
      INSERT INTO profiles (user_id, profile_type, created_at)
      VALUES (?, ?, NOW())
    `, [userId, testUser.profile_type]);
    
    // Créer les limites d'utilisation
    await connection.execute(`
      INSERT INTO user_limits (user_id, applications_count, opportunities_posted, messages_sent, last_reset_date)
      VALUES (?, 0, 0, 0, NOW())
    `, [userId]);
    
    console.log('✅ Utilisateur de test créé avec succès!');
    console.log(`   ID: ${userId}`);
    console.log(`   Email: ${testUser.email}`);
    console.log(`   Mot de passe: ${testUser.password}`);
    console.log(`   Type d'abonnement: free`);
    console.log(`   Premium: false`);
    
    console.log('\n🔧 Test de l\'erreur 403:');
    console.log('   - Cet utilisateur est gratuit');
    console.log('   - Il ne peut pas envoyer de messages');
    console.log('   - Le backend devrait retourner 403');
    console.log('   - Le frontend devrait afficher un pop-up premium');
    
  } catch (error) {
    console.error('❌ Erreur lors de la création:', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

createTestUser(); 