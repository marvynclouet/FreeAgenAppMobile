require('dotenv').config();
const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');

async function createUser(name, email, password, profileType = 'player') {
  try {
    // Créer la connexion
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      port: process.env.DB_PORT
    });

    // Hasher le mot de passe
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Vérifier si l'utilisateur existe déjà
    const [existingUsers] = await connection.query(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );

    if (existingUsers.length > 0) {
      console.log('❌ Un utilisateur avec cet email existe déjà');
      await connection.end();
      return;
    }

    // Insérer le nouvel utilisateur
    const [result] = await connection.query(
      'INSERT INTO users (name, email, password, profile_type) VALUES (?, ?, ?, ?)',
      [name, email, hashedPassword, profileType]
    );

    console.log('✅ Utilisateur créé avec succès !');
    console.log('ID:', result.insertId);
    console.log('Nom:', name);
    console.log('Email:', email);
    console.log('Type de profil:', profileType);

    await connection.end();
  } catch (error) {
    console.error('❌ Erreur lors de la création de l\'utilisateur :');
    console.error(error.message);
  } finally {
    process.exit();
  }
}

// Exemple d'utilisation
const name = 'John Doe';
const email = 'john@freeagent.com';
const password = 'password123';
const profileType = 'player';

createUser(name, email, password, profileType); 