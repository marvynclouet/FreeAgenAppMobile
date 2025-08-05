const bcrypt = require('bcrypt');

async function updatePasswordViaAPI() {
  try {
    console.log('🔧 Mise à jour du mot de passe via l\'API Railway...');
    
    // Générer le hash du mot de passe
    const newPassword = 'Marvyn2024!';
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    
    console.log('✅ Hash généré avec succès!');
    console.log('');
    console.log('📧 Vos nouveaux identifiants:');
    console.log(`   Email: marvyn@gmail.com`);
    console.log(`   Mot de passe: ${newPassword}`);
    console.log('');
    console.log('🔐 Hash du mot de passe:');
    console.log(hashedPassword);
    console.log('');
    console.log('📝 Requête SQL à exécuter dans Railway:');
    console.log(`UPDATE users SET password = '${hashedPassword}' WHERE email = 'marvyn@gmail.com';`);
    console.log('');
    console.log('🔗 URL de connexion:');
    console.log('https://web-na4p0oz7o-marvynshes-projects.vercel.app/');
    console.log('');
    console.log('💡 Instructions pour Railway Dashboard:');
    console.log('1. Allez sur https://railway.app/dashboard');
    console.log('2. Sélectionnez votre projet FreeAgent');
    console.log('3. Cherchez l\'onglet "Database" ou "MySQL"');
    console.log('4. Cliquez sur "Connect" ou "Open Database"');
    console.log('5. Exécutez la requête SQL ci-dessus');
    console.log('');
    console.log('🎯 Alternative: Utilisez un client MySQL comme MySQL Workbench');
    console.log('   Host: containers-us-west-207.railway.app');
    console.log('   Port: 6884');
    console.log('   User: root');
    console.log('   Password: WkdwbGCWQjoQhjNdeGEumAVztCSRXvZn');
    console.log('   Database: railway');
    
  } catch (error) {
    console.error('❌ Erreur:', error.message);
  }
}

updatePasswordViaAPI(); 