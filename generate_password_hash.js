const bcrypt = require('bcrypt');

async function generatePasswordHash() {
  try {
    console.log('🔧 Génération du hash du mot de passe...');
    
    const password = 'Marvyn2024!';
    const hashedPassword = await bcrypt.hash(password, 10);
    
    console.log('✅ Hash généré avec succès!');
    console.log('');
    console.log('📧 Identifiants:');
    console.log(`   Email: marvyn@gmail.com`);
    console.log(`   Mot de passe: ${password}`);
    console.log('');
    console.log('🔐 Hash du mot de passe:');
    console.log(hashedPassword);
    console.log('');
    console.log('📝 Requête SQL à exécuter dans Railway:');
    console.log(`UPDATE users SET password = '${hashedPassword}' WHERE email = 'marvyn@gmail.com';`);
    console.log('');
    console.log('🔗 URL de connexion:');
    console.log('https://web-na4p0oz7o-marvynshes-projects.vercel.app/');
    
  } catch (error) {
    console.error('❌ Erreur:', error.message);
  }
}

generatePasswordHash(); 