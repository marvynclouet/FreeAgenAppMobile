const fs = require('fs');
const path = require('path');
const pool = require('../config/db.config.js');

async function applyPremiumSchema() {
  try {
    console.log('📋 Application du schéma premium...');
    
    // Lire le fichier SQL
    const sqlFile = path.join(__dirname, '../database/premium_schema.sql');
    let sqlContent = fs.readFileSync(sqlFile, 'utf8');
    
    // Diviser en requêtes individuelles (séparer par ;)
    // Retirer les commentaires et les lignes vides
    sqlContent = sqlContent.replace(/--.*$/gm, ''); // Supprimer les commentaires
    sqlContent = sqlContent.replace(/\/\*[\s\S]*?\*\//g, ''); // Supprimer les commentaires multi-lignes
    
    // Séparer les requêtes par ';' mais ignorer les triggers et procédures
    const queries = [];
    let currentQuery = '';
    let inDelimiter = false;
    
    const lines = sqlContent.split('\n');
    
    for (const line of lines) {
      const trimmedLine = line.trim();
      
      if (trimmedLine === '') continue;
      
      if (trimmedLine.startsWith('DELIMITER')) {
        inDelimiter = !inDelimiter;
        currentQuery += line + '\n';
        continue;
      }
      
      currentQuery += line + '\n';
      
      if (!inDelimiter && trimmedLine.endsWith(';')) {
        if (currentQuery.trim()) {
          queries.push(currentQuery.trim());
        }
        currentQuery = '';
      }
    }
    
    // Ajouter la dernière requête si elle existe
    if (currentQuery.trim()) {
      queries.push(currentQuery.trim());
    }
    
    console.log(`📝 ${queries.length} requêtes à exécuter`);
    
    // Exécuter chaque requête
    for (let i = 0; i < queries.length; i++) {
      const query = queries[i];
      if (query.trim() === '') continue;
      
      console.log(`⏳ Exécution de la requête ${i + 1}/${queries.length}...`);
      
      try {
        // Ignorer les requêtes USE et DELIMITER
        if (query.startsWith('USE ') || query.startsWith('DELIMITER')) {
          console.log(`⏭️  Ignore: ${query.substring(0, 50)}...`);
          continue;
        }
        
        await pool.execute(query);
        console.log(`✅ Requête ${i + 1} exécutée avec succès`);
      } catch (error) {
        console.error(`❌ Erreur lors de l'exécution de la requête ${i + 1}:`, error.message);
        console.error(`📋 Requête: ${query.substring(0, 200)}...`);
        // Continuer avec les autres requêtes
      }
    }
    
    console.log('🎉 Schéma premium appliqué avec succès!');
    
    // Vérifier les nouvelles colonnes
    const [rows] = await pool.execute(`
      SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = 'freeagent_db' 
      AND TABLE_NAME = 'users' 
      AND COLUMN_NAME IN ('subscription_type', 'subscription_expiry', 'is_premium')
    `);
    
    console.log('📊 Nouvelles colonnes ajoutées:', rows);
    
    // Vérifier les plans d'abonnement
    const [plans] = await pool.execute('SELECT * FROM subscription_plans ORDER BY price');
    console.log('💳 Plans d\'abonnement créés:', plans);
    
  } catch (error) {
    console.error('❌ Erreur lors de l\'application du schéma:', error);
  } finally {
    await pool.end();
  }
}

// Exécuter le script
applyPremiumSchema(); 