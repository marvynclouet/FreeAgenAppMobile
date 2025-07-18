const db = require('../database/db');

async function verifyAdminUser() {
  try {
    console.log('Vérification de l\'utilisateur administrateur...');
    
    const [users] = await db.execute(
      'SELECT id, name, email, profile_type, is_admin, created_at FROM users WHERE email = ?',
      ['admin@freeagentapp.com']
    );
    
    if (users.length > 0) {
      const admin = users[0];
      console.log('✅ Utilisateur admin trouvé :');
      console.log(`ID: ${admin.id}`);
      console.log(`Nom: ${admin.name}`);
      console.log(`Email: ${admin.email}`);
      console.log(`Type de profil: ${admin.profile_type}`);
      console.log(`Admin: ${admin.is_admin ? 'Oui' : 'Non'}`);
      console.log(`Créé le: ${admin.created_at}`);
    } else {
      console.log('❌ Utilisateur admin non trouvé');
    }
    
    // Vérifier la colonne is_admin
    try {
      const [columns] = await db.execute(
        "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'users' AND COLUMN_NAME = 'is_admin'"
      );
      console.log(`Colonne is_admin: ${columns.length > 0 ? 'Existe' : 'N\'existe pas'}`);
    } catch (error) {
      console.log('Erreur lors de la vérification de la colonne is_admin:', error.message);
    }
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur lors de la vérification:', error);
    process.exit(1);
  }
}

verifyAdminUser(); 