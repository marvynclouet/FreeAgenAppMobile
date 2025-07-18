const bcrypt = require('bcrypt');
const db = require('../database/db');

async function createAdminUser() {
  try {
    console.log('Création de l\'utilisateur administrateur...');
    
    // Vérifier si la colonne is_admin existe
    try {
      await db.execute('SELECT is_admin FROM users LIMIT 1');
      console.log('Colonne is_admin existe déjà');
    } catch (error) {
      console.log('Ajout de la colonne is_admin...');
      await db.execute('ALTER TABLE users ADD COLUMN is_admin BOOLEAN DEFAULT FALSE');
    }
    
    // Vérifier si l'admin existe déjà
    const [existingUsers] = await db.execute(
      'SELECT id FROM users WHERE email = ?',
      ['admin@freeagentapp.com']
    );
    
    if (existingUsers.length > 0) {
      console.log('L\'utilisateur admin existe déjà, mise à jour du statut admin...');
      await db.execute(
        'UPDATE users SET is_admin = TRUE WHERE email = ?',
        ['admin@freeagentapp.com']
      );
    } else {
      console.log('Création du nouvel utilisateur admin...');
      const hashedPassword = await bcrypt.hash('Admin123!', 10);
      
      await db.execute(
        'INSERT INTO users (name, email, password, profile_type, is_admin, created_at, updated_at) VALUES (?, ?, ?, ?, ?, NOW(), NOW())',
        [
          'Administrateur FreeAgent',
          'admin@freeagentapp.com',
          hashedPassword,
          'player',
          true
        ]
      );
    }
    
    console.log('✅ Utilisateur administrateur créé avec succès !');
    console.log('Email: admin@freeagentapp.com');
    console.log('Mot de passe: Admin123!');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur lors de la création de l\'admin:', error);
    process.exit(1);
  }
}

createAdminUser(); 