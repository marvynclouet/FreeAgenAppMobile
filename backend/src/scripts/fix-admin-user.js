const mysql = require('mysql2/promise');
const dbConfig = require('../config/db.config');

async function fixAdminUser() {
  let connection;
  
  try {
    console.log('🔧 Correction de l\'utilisateur admin...');
    
    connection = await mysql.createConnection(dbConfig);
    
    // Vérifier l'utilisateur marvyn@gmail.com
    const [users] = await connection.execute(
      'SELECT id, email, is_admin FROM users WHERE email = ?',
      ['marvyn@gmail.com']
    );
    
    if (users.length === 0) {
      console.log('❌ Utilisateur marvyn@gmail.com non trouvé');
      return;
    }
    
    const user = users[0];
    console.log(`👤 Utilisateur trouvé: ${user.email}, is_admin: ${user.is_admin}`);
    
    if (!user.is_admin) {
      console.log('🔄 Mise à jour du statut admin...');
      
      await connection.execute(
        'UPDATE users SET is_admin = 1 WHERE id = ?',
        [user.id]
      );
      
      console.log('✅ Statut admin mis à jour');
    } else {
      console.log('✅ Utilisateur déjà admin');
    }
    
    // Vérifier le résultat
    const [updatedUsers] = await connection.execute(
      'SELECT id, email, is_admin FROM users WHERE email = ?',
      ['marvyn@gmail.com']
    );
    
    console.log(`📋 Résultat final: is_admin = ${updatedUsers[0].is_admin}`);
    
  } catch (error) {
    console.error('❌ Erreur:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

fixAdminUser(); 