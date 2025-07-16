const bcrypt = require('bcryptjs');
const pool = require('./src/config/db.config');

async function createTestUser() {
  try {
    console.log('🔧 Vérification de l\'utilisateur de test...');
    
    // Vérifier si l'utilisateur existe déjà
    const [userRows] = await pool.execute(`
      SELECT id FROM users WHERE email = ?
    `, ['joueur.test@example.com']);
    
    let userId;
    
    if (userRows.length > 0) {
      userId = userRows[0].id;
      console.log(`✅ Utilisateur existant trouvé avec l'ID: ${userId}`);
    } else {
      // Hasher le mot de passe
      const hashedPassword = await bcrypt.hash('test123', 10);
      
      // Créer l'utilisateur
      const [result] = await pool.execute(`
        INSERT INTO users (
          name, email, password, first_name, last_name, profile_type,
          subscription_type, subscription_expiry, is_premium, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
      `, [
        'Thomas Joueur',
        'joueur.test@example.com',
        hashedPassword,
        'Thomas',
        'Joueur',
        'player',
        'free',
        null,
        false
      ]);
      
      userId = result.insertId;
      console.log(`✅ Utilisateur créé avec l'ID: ${userId}`);
    }
    
    // Vérifier/créer les limites d'utilisation
    const [limitsRows] = await pool.execute(`
      SELECT user_id FROM user_limits WHERE user_id = ?
    `, [userId]);
    
    if (limitsRows.length === 0) {
      await pool.execute(`
        INSERT INTO user_limits (
          user_id, applications_count, opportunities_posted, messages_sent, last_reset_date
        ) VALUES (?, 0, 0, 0, CURRENT_DATE)
      `, [userId]);
      
      console.log('✅ Limites d\'utilisation créées');
    } else {
      console.log('✅ Limites d\'utilisation déjà présentes');
    }
    
    console.log('\n🎯 UTILISATEUR DE TEST CRÉÉ:');
    console.log('Email: joueur.test@example.com');
    console.log('Mot de passe: test123');
    console.log('Type: Joueur GRATUIT');
    console.log('Restrictions: 0 candidatures, 0 messages, 0 opportunités');
    
  } catch (error) {
    console.error('❌ Erreur lors de la création de l\'utilisateur:', error);
  } finally {
    process.exit(0);
  }
}

createTestUser(); 