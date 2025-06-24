const bcrypt = require('bcrypt');

async function generateHash() {
    const password = 'user123';
    const saltRounds = 10;
    
    try {
        const hash = await bcrypt.hash(password, saltRounds);
        console.log('Hash généré pour le mot de passe "user123":');
        console.log(hash);
    } catch (error) {
        console.error('Erreur lors de la génération du hash:', error);
    }
}

generateHash(); 