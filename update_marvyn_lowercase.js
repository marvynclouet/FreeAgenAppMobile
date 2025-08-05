const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');

// Configuration Railway
const dbConfig = {
  host: 'containers-us-west-207.railway.app',
  user: 'root',
  password: 'your_railway_password_here', // Remplacez par votre vrai mot de passe
  database: 'railway',
  port: 6884
};

async function updateMarvynPassword() {
  try {
    console.log('🔧 Connexion à la base de données Railway...');
    
    const connection = await mysql.createConnection(dbConfig);
    console.log('✅ Connexion réussie');
    
    // Nouveau mot de passe
    const newPassword = 'Marvyn2024!';
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    
    // Mettre à jour le mot de passe
    console.log('🔐 Mise à jour du mot de passe...');
    const [result] = await connection.execute(
      'UPDATE users SET password = ? WHERE email = ?',
      [hashedPassword, 'marvyn@gmail.com']
    );
    
    if (result.affectedRows > 0) {
      console.log('✅ Mot de passe mis à jour avec succès!');
      console.log('');
      console.log('📧 Vos nouveaux identifiants:');
      console.log(`   Email: marvyn@gmail.com`);
      console.log(`   Mot de passe: ${newPassword}`);
      console.log('');
      console.log('🔗 Connectez-vous sur:');
      console.log('https://web-na4p0oz7o-marvynshes-projects.vercel.app/');
    } else {
      console.log('❌ Aucun utilisateur trouvé avec cet email');
    }
    
    await connection.end();
    
  } catch (error) {
    console.error('❌ Erreur:', error.message);
    console.log('');
    console.log('💡 Solution alternative via Dashboard Railway:');
    console.log('1. Connectez-vous à https://railway.app/dashboard');
    console.log('2. Sélectionnez votre projet FreeAgent');
    console.log('3. Allez dans Database → Query');
    console.log('4. Exécutez cette requête SQL:');
    console.log(`   UPDATE users SET password = '${hashedPassword}' WHERE email = 'marvyn@gmail.com';`);
  }
}

updateMarvynPassword(); 