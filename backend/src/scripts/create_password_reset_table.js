const pool = require('../config/db.config');

async function createPasswordResetTable() {
  try {
    console.log('🔧 Connexion à la base de données...');
    console.log('✅ Connexion réussie');

    console.log('📋 Création de la table password_reset_tokens...');
    
    const createTableQuery = `
      CREATE TABLE IF NOT EXISTS password_reset_tokens (
        id INT PRIMARY KEY AUTO_INCREMENT,
        user_id INT NOT NULL,
        token VARCHAR(255) NOT NULL UNIQUE,
        expires_at TIMESTAMP NOT NULL,
        used BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_token (token),
        INDEX idx_user_id (user_id),
        INDEX idx_expires_at (expires_at)
      )
    `;

    await pool.execute(createTableQuery);
    console.log('✅ Table password_reset_tokens créée avec succès !');

    // Vérifier que la table existe
    const [tables] = await pool.execute(
      "SHOW TABLES LIKE 'password_reset_tokens'"
    );
    
    if (tables.length > 0) {
      console.log('✅ Vérification : La table existe bien');
    } else {
      console.log('⚠️  La table n\'a pas été trouvée');
    }

  } catch (error) {
    console.error('❌ Erreur:', error.message);
    if (error.code === 'ER_TABLE_EXISTS_ERROR') {
      console.log('ℹ️  La table existe déjà, c\'est normal');
    } else {
      throw error;
    }
  } finally {
    await pool.end();
    console.log('🔌 Connexion fermée');
  }
}

createPasswordResetTable()
  .then(() => {
    console.log('✅ Script terminé avec succès');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Erreur fatale:', error);
    process.exit(1);
  });

