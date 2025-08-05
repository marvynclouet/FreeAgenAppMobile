const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// Configuration de la base de données Railway
const dbConfig = {
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT || 3306
};

async function createTestUser() {
  let connection;
  
  try {
    console.log('🔌 Connexion à la base de données Railway...');
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Connexion réussie !');

    // Vérifier si l'utilisateur existe déjà
    const [existingUser] = await connection.execute(
      'SELECT id FROM users WHERE email = ?',
      ['contenttest@test.com']
    );

    if (existingUser.length > 0) {
      console.log('ℹ️ Utilisateur de test déjà existant');
      
      // Mettre à jour le mot de passe
      const hashedPassword = await bcrypt.hash('test123', 10);
      await connection.execute(
        'UPDATE users SET password = ? WHERE email = ?',
        [hashedPassword, 'contenttest@test.com']
      );
      console.log('✅ Mot de passe mis à jour');
      
      // Mettre à jour le statut premium
      await connection.execute(
        'UPDATE users SET subscription_type = ?, is_premium = 1 WHERE email = ?',
        ['premium_basic', 'contenttest@test.com']
      );
      console.log('✅ Statut premium mis à jour');
      
    } else {
      console.log('📝 Création d\'un nouvel utilisateur de test...');
      
      const hashedPassword = await bcrypt.hash('test123', 10);
      
      await connection.execute(`
        INSERT INTO users (name, email, password, profile_type, subscription_type, is_premium, created_at)
        VALUES (?, ?, ?, ?, ?, ?, NOW())
      `, [
        'Test Content User',
        'contenttest@test.com',
        hashedPassword,
        'player',
        'premium_basic',
        1
      ]);
      
      console.log('✅ Utilisateur de test créé avec succès');
    }

    // Afficher les informations de l'utilisateur
    const [userInfo] = await connection.execute(
      'SELECT id, name, email, profile_type, subscription_type, is_premium FROM users WHERE email = ?',
      ['contenttest@test.com']
    );
    
    console.log('\n📋 Informations de l\'utilisateur de test:');
    console.log(JSON.stringify(userInfo[0], null, 2));

    console.log('\n🎉 Utilisateur de test prêt pour les tests de contenu !');
    console.log('📧 Email: contenttest@test.com');
    console.log('🔑 Mot de passe: test123');

  } catch (error) {
    console.error('❌ Erreur lors de la création:', error);
  } finally {
    if (connection) {
      await connection.end();
      console.log('\n🔌 Connexion fermée');
    }
  }
}

// Exécuter la création
createTestUser(); 