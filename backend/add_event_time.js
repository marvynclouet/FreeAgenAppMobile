const mysql = require('mysql2/promise');
const dbConfig = require('./src/config/db.config');

async function addEventTimeColumn() {
  let connection;
  try {
    connection = await dbConfig.getConnection();
    
    // Vérifier si la colonne event_time existe déjà
    const [columns] = await connection.execute(`
      SHOW COLUMNS FROM events LIKE 'event_time'
    `);
    
    if (columns.length === 0) {
      // Ajouter la colonne event_time si elle n'existe pas
      await connection.execute(`
        ALTER TABLE events 
        ADD COLUMN event_time TIME AFTER event_date
      `);
      console.log('✅ Colonne event_time ajoutée avec succès à la table events');
    } else {
      console.log('✅ Colonne event_time existe déjà');
    }
    
  } catch (error) {
    console.error('❌ Erreur lors de l\'ajout de la colonne event_time:', error);
  } finally {
    if (connection) {
      connection.release();
    }
  }
}

addEventTimeColumn(); 