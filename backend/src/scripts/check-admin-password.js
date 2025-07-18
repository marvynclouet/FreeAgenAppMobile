const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');
const dbConfig = require('../config/db.config');

async function checkAndFixAdminPassword() {
  let connection;
  
  try {
    console.log('🔍 Vérification du mot de passe admin...');
    
    connection = await mysql.createConnection(dbConfig);
    
    // Récupérer l'admin
    const [admins] = await connection.execute(
      'SELECT id, email, password FROM users WHERE is_admin = 1 LIMIT 1'
    );
    
    if (admins.length === 0) {
      console.log('❌ Aucun admin trouvé');
      return;
    }
    
    const admin = admins[0];
    console.log(`👤 Admin trouvé: ${admin.email}`);
    
    // Tester le mot de passe actuel
    const testPassword = 'admin123';
    const isPasswordCorrect = await bcrypt.compare(testPassword, admin.password);
    
    console.log(`🔐 Mot de passe actuel correct: ${isPasswordCorrect}`);
    
    if (!isPasswordCorrect) {
      console.log('🔄 Mise à jour du mot de passe...');
      const hashedPassword = await bcrypt.hash(testPassword, 10);
      
      await connection.execute(
        'UPDATE users SET password = ? WHERE id = ?',
        [hashedPassword, admin.id]
      );
      
      console.log('✅ Mot de passe mis à jour avec succès');
    }
    
  } catch (error) {
    console.error('❌ Erreur:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

checkAndFixAdminPassword(); 