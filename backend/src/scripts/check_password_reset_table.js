const pool = require('../config/db.config');

async function checkPasswordResetTable() {
  try {
    console.log('🔍 Vérification de la table password_reset_tokens...\n');

    // Vérifier si la table existe
    const [tables] = await pool.execute(
      "SHOW TABLES LIKE 'password_reset_tokens'"
    );

    if (tables.length === 0) {
      console.log('❌ La table password_reset_tokens N\'EXISTE PAS');
      console.log('\n📋 Pour la créer, exécutez :');
      console.log('   node backend/src/scripts/create_password_reset_table.js\n');
      return false;
    }

    console.log('✅ La table password_reset_tokens EXISTE\n');

    // Vérifier la structure de la table
    console.log('📋 Structure de la table :');
    const [columns] = await pool.execute(
      "DESCRIBE password_reset_tokens"
    );

    console.table(columns);

    // Compter les tokens existants
    const [count] = await pool.execute(
      "SELECT COUNT(*) as total FROM password_reset_tokens"
    );
    console.log(`\n📊 Nombre de tokens dans la table : ${count[0].total}`);

    // Vérifier les tokens actifs (non utilisés et non expirés)
    const [activeTokens] = await pool.execute(
      `SELECT COUNT(*) as total 
       FROM password_reset_tokens 
       WHERE used = FALSE AND expires_at > NOW()`
    );
    console.log(`📊 Tokens actifs (non utilisés et non expirés) : ${activeTokens[0].total}`);

    return true;
  } catch (error) {
    console.error('❌ Erreur:', error.message);
    if (error.code === 'ER_NO_SUCH_TABLE') {
      console.log('\n❌ La table n\'existe pas');
      console.log('📋 Pour la créer, exécutez :');
      console.log('   node backend/src/scripts/create_password_reset_table.js\n');
    }
    return false;
  } finally {
    await pool.end();
    console.log('\n🔌 Connexion fermée');
  }
}

checkPasswordResetTable()
  .then((exists) => {
    if (exists) {
      console.log('\n✅ Vérification terminée avec succès');
    } else {
      console.log('\n⚠️  La table doit être créée');
    }
    process.exit(exists ? 0 : 1);
  })
  .catch((error) => {
    console.error('❌ Erreur fatale:', error);
    process.exit(1);
  });


