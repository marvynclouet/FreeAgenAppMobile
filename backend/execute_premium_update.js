const mysql = require('mysql2/promise');

// Configuration de la base de données
const dbConfig = {
  host: 'monorail.proxy.rlwy.net',
  port: 45189,
  user: 'root',
  password: 'HhGgFfEeDdCcBbAa123456789',
  database: 'railway'
};

async function updateUserToPremium() {
  let connection;
  
  try {
    console.log('🔧 Mise à jour de l\'utilisateur vers premium...\n');
    
    connection = await mysql.createConnection(dbConfig);
    
    // Vérifier l'état actuel
    console.log('1. Vérification de l\'état actuel...');
    const [currentUser] = await connection.execute(`
      SELECT id, email, name, subscription_type, is_premium, subscription_expiry 
      FROM users 
      WHERE email = 'premium@freeagent.com'
    `);
    
    if (currentUser.length === 0) {
      console.log('❌ Utilisateur premium@freeagent.com non trouvé');
      return;
    }
    
    const user = currentUser[0];
    console.log('📊 État actuel:');
    console.log(`   ID: ${user.id}`);
    console.log(`   Email: ${user.email}`);
    console.log(`   Type d'abonnement: ${user.subscription_type}`);
    console.log(`   Premium: ${user.is_premium}`);
    console.log(`   Expiration: ${user.subscription_expiry}\n`);
    
    // Mettre à jour vers premium
    console.log('2. Mise à jour vers premium...');
    await connection.execute(`
      UPDATE users 
      SET subscription_type = 'premium', 
          is_premium = TRUE, 
          subscription_expiry = DATE_ADD(NOW(), INTERVAL 1 YEAR)
      WHERE email = 'premium@freeagent.com'
    `);
    
    console.log('✅ Mise à jour effectuée!');
    
    // Vérifier la mise à jour
    console.log('\n3. Vérification de la mise à jour...');
    const [updatedUser] = await connection.execute(`
      SELECT id, email, name, subscription_type, is_premium, subscription_expiry 
      FROM users 
      WHERE email = 'premium@freeagent.com'
    `);
    
    const updated = updatedUser[0];
    console.log('📊 Nouvel état:');
    console.log(`   ID: ${updated.id}`);
    console.log(`   Email: ${updated.email}`);
    console.log(`   Type d'abonnement: ${updated.subscription_type}`);
    console.log(`   Premium: ${updated.is_premium}`);
    console.log(`   Expiration: ${updated.subscription_expiry}`);
    
    console.log('\n🎯 RÉSULTAT:');
    console.log('   - Utilisateur mis à jour vers premium');
    console.log('   - Peut maintenant envoyer des messages');
    console.log('   - Testez avec: premium@freeagent.com / Premium123!');
    
  } catch (error) {
    console.error('❌ Erreur lors de la mise à jour:', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

updateUserToPremium(); 