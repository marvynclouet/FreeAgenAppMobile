const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');

// Configuration de la base de données Railway
const dbConfig = {
  host: process.env.DB_HOST || 'containers-us-west-207.railway.app',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'your_password_here',
  database: process.env.DB_NAME || 'railway',
  port: process.env.DB_PORT || 6884
};

async function resetPassword() {
  try {
    console.log('🔧 Connexion à la base de données...');
    
    const connection = await mysql.createConnection(dbConfig);
    console.log('✅ Connexion réussie');
    
    // Vérifier si l'utilisateur existe
    console.log('🔍 Vérification du compte Marvyn@gmail.com...');
    const [users] = await connection.execute(
      'SELECT id, email, name FROM users WHERE email = ?',
      ['Marvyn@gmail.com']
    );
    
    if (users.length === 0) {
      console.log('❌ Aucun compte trouvé avec cet email');
      return;
    }
    
    const user = users[0];
    console.log(`✅ Compte trouvé: ${user.name} (ID: ${user.id})`);
    
    // Générer un nouveau mot de passe
    const newPassword = 'Marvyn2024!';
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    
    // Mettre à jour le mot de passe
    console.log('🔐 Mise à jour du mot de passe...');
    await connection.execute(
      'UPDATE users SET password = ? WHERE email = ?',
      [hashedPassword, 'Marvyn@gmail.com']
    );
    
    console.log('✅ Mot de passe mis à jour avec succès!');
    console.log('');
    console.log('📧 Vos nouveaux identifiants:');
    console.log(`   Email: Marvyn@gmail.com`);
    console.log(`   Mot de passe: ${newPassword}`);
    console.log('');
    console.log('🔗 Connectez-vous sur: https://web-na4p0oz7o-marvynshes-projects.vercel.app/');
    
    await connection.end();
    
  } catch (error) {
    console.error('❌ Erreur:', error.message);
  }
}

resetPassword(); 