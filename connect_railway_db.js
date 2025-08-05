const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');

// Configuration directe avec les informations Railway
const dbConfig = {
  host: 'mysql.railway.internal',
  user: 'root',
  password: 'WkdwbGCWQjoQhjNdeGEumAVztCSRXvZn',
  database: 'railway',
  port: 3306
};

async function connectAndUpdatePassword() {
  try {
    console.log('🔧 Connexion à la base de données Railway...');
    console.log('Host:', dbConfig.host);
    console.log('Port:', dbConfig.port);
    console.log('Database:', dbConfig.database);
    
    const connection = await mysql.createConnection(dbConfig);
    console.log('✅ Connexion réussie!');
    
    // Test de la connexion
    const [rows] = await connection.execute('SELECT 1 as test');
    console.log('✅ Test de connexion réussi:', rows[0]);
    
    // Vérifier si l'utilisateur existe
    console.log('🔍 Vérification du compte marvyn@gmail.com...');
    const [users] = await connection.execute(
      'SELECT id, email, name FROM users WHERE email = ?',
      ['marvyn@gmail.com']
    );
    
    if (users.length === 0) {
      console.log('❌ Aucun utilisateur trouvé avec cet email');
      await connection.end();
      return;
    }
    
    const user = users[0];
    console.log(`✅ Utilisateur trouvé: ${user.name} (ID: ${user.id})`);
    
    // Générer le nouveau mot de passe
    const newPassword = 'Marvyn2024!';
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    
    // Mettre à jour le mot de passe
    console.log('🔐 Mise à jour du mot de passe...');
    const [result] = await connection.execute(
      'UPDATE users SET password = ? WHERE email = ?',
      [hashedPassword, 'marvyn@gmail.com']
    );
    
    if (result.affectedRows > 0) {
      console.log('✅ Mot de passe mis à jour avec succès!');
      console.log('');
      console.log('📧 Vos nouveaux identifiants:');
      console.log(`   Email: marvyn@gmail.com`);
      console.log(`   Mot de passe: ${newPassword}`);
      console.log('');
      console.log('🔗 Connectez-vous sur:');
      console.log('https://web-na4p0oz7o-marvynshes-projects.vercel.app/');
    } else {
      console.log('❌ Erreur lors de la mise à jour');
    }
    
    await connection.end();
    
  } catch (error) {
    console.error('❌ Erreur de connexion:', error.message);
    console.log('');
    console.log('💡 Vérifiez que:');
    console.log('1. Les informations de connexion sont correctes');
    console.log('2. La base de données est accessible');
    console.log('3. Le service Railway est en cours d\'exécution');
  }
}

connectAndUpdatePassword(); 