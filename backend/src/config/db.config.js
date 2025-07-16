const mysql = require('mysql2/promise');
const path = require('path');

// Charger le .env depuis la racine du backend
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

// Debug des variables d'environnement
console.log('🔧 Configuration DB:', {
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD ? '***' : 'undefined',
  database: process.env.DB_NAME,
  port: process.env.DB_PORT
});

const pool = mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'root',
  database: process.env.DB_NAME || 'freeagent_db',
  port: process.env.DB_PORT || 8889,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Test de connexion au démarrage
pool.getConnection()
  .then(connection => {
    console.log('✅ Pool MySQL connecté avec succès');
    connection.release();
  })
  .catch(error => {
    console.error('❌ Erreur de connexion du pool MySQL:', error.message);
  });

module.exports = pool; 