/**
 * Script pour créer un compte de test pour Google Play Console
 * Ce compte sera utilisé par Google pour examiner l'application
 */

const pool = require('../config/db.config');
const bcrypt = require('bcrypt');

async function createPlayStoreTestAccount() {
  try {
    console.log('🔐 Création du compte de test pour Google Play Console...\n');

    const testEmail = 'playstore.test@freeagent.app';
    const testPassword = 'GooglePlay2024!Test';
    const testName = 'Google Play Test Account';

    // Vérifier si le compte existe déjà
    const [existingUsers] = await pool.query(
      'SELECT * FROM users WHERE email = ?',
      [testEmail]
    );

    if (existingUsers.length > 0) {
      console.log('⚠️  Le compte de test existe déjà !');
      console.log(`📧 Email: ${testEmail}`);
      console.log(`🔑 Mot de passe: ${testPassword}`);
      console.log('\n✅ Utilisez ces identifiants dans Google Play Console\n');
      return;
    }

    // Hasher le mot de passe
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(testPassword, salt);

    // Créer le compte de test (sans subscription_type pour éviter les erreurs)
    const [result] = await pool.query(
      `INSERT INTO users (name, email, password, profile_type, is_premium, created_at)
       VALUES (?, ?, ?, 'player', 1, NOW())`,
      [testName, testEmail, hashedPassword]
    );

    console.log('✅ Compte de test créé avec succès !\n');
    console.log('📋 INFORMATIONS POUR GOOGLE PLAY CONSOLE:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`📧 Email: ${testEmail}`);
    console.log(`🔑 Mot de passe: ${testPassword}`);
    console.log(`👤 Nom: ${testName}`);
    console.log(`🎯 Type de profil: Player (Joueur)`);
    console.log(`⭐ Statut: Premium`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    console.log('📝 Instructions:');
    console.log('1. Allez dans Google Play Console');
    console.log('2. Accédez à "Politique de l\'app" > "Déclaration d\'accès à l\'app"');
    console.log('3. Ajoutez ces identifiants dans la section "Identifiants de connexion"');
    console.log('4. Indiquez que ce compte a accès à toutes les fonctionnalités\n');

  } catch (error) {
    console.error('❌ Erreur lors de la création du compte:', error);
    throw error;
  }
}

// Exécuter le script
createPlayStoreTestAccount()
  .then(() => {
    console.log('✅ Script terminé avec succès');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Erreur:', error);
    process.exit(1);
  });

