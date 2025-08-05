const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');

async function updatePasswordWithEnv() {
  try {
    console.log('🔧 Connexion à la base de données via MYSQL_URL...');
    
    // Utiliser la variable d'environnement MYSQL_URL
    const mysqlUrl = process.env.MYSQL_URL;
    
    if (!mysqlUrl) {
      console.log('❌ Variable MYSQL_URL non trouvée');
      console.log('');
      console.log('💡 Pour configurer MYSQL_URL:');
      console.log('1. Allez sur Railway Dashboard');
      console.log('2. Sélectionnez votre projet FreeAgent');
      console.log('3. Allez dans Variables');
      console.log('4. Ajoutez: MYSQL_URL = ${{ MySQL.MYSQL_URL }}');
      console.log('5. Redéployez votre service');
      return;
    }
    
    console.log('✅ MYSQL_URL trouvée');
    
    // Créer la connexion
    const connection = await mysql.createConnection(mysqlUrl);
    console.log('✅ Connexion à la base de données réussie');
    
    // Nouveau mot de passe
    const password = 'Marvyn2024!';
    const hashedPassword = await bcrypt.hash(password, 10);
    
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
      console.log(`   Mot de passe: ${password}`);
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
    console.log('💡 Solution manuelle:');
    console.log('1. Allez sur Railway Dashboard');
    console.log('2. Trouvez votre base de données MySQL');
    console.log('3. Exécutez cette requête SQL:');
    console.log(`   UPDATE users SET password = '$2b$10$sr8JCeS2AXuZ1q3nKGwotes3ZzowAU/yi4jsGDhnOH0.7uid5P89G' WHERE email = 'marvyn@gmail.com';`);
  }
}

updatePasswordWithEnv(); 