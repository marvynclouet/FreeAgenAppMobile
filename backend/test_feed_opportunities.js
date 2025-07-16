const mysql = require('mysql2/promise');
const dbConfig = require('./src/config/db.config');

async function testFeedOpportunities() {
  let connection;
  try {
    connection = await dbConfig.getConnection();
    
    console.log('🔍 Test de récupération des opportunités dans le fil d\'actualités...');
    
    // Récupérer les opportunités
    const [opportunities] = await connection.execute(`
      SELECT 
        a.id,
        'opportunity' as type,
        a.title,
        a.description as content,
        NULL as image_url,
        a.location,
        a.salary_range,
        a.requirements,
        a.created_at,
        u.name as author_name,
        u.profile_type as author_type,
        u.profile_image_url as author_avatar
      FROM annonces a
      JOIN users u ON a.user_id = u.id
      WHERE a.status = 'open'
      ORDER BY a.created_at DESC
      LIMIT 10
    `);
    
    console.log(`✅ Opportunités trouvées: ${opportunities.length}`);
    
    if (opportunities.length > 0) {
      console.log('📋 Détails des opportunités:');
      opportunities.forEach((opp, index) => {
        console.log(`  ${index + 1}. ${opp.title} (${opp.author_name})`);
        console.log(`     Type: ${opp.type}`);
        console.log(`     Localisation: ${opp.location || 'Non spécifiée'}`);
        console.log(`     Date: ${opp.created_at}`);
        console.log('');
      });
    } else {
      console.log('⚠️  Aucune opportunité trouvée dans la table annonces');
      
      // Vérifier s'il y a des annonces
      const [annonces] = await connection.execute('SELECT COUNT(*) as count FROM annonces');
      console.log(`📊 Total annonces dans la base: ${annonces[0].count}`);
      
      // Vérifier les statuts
      const [statuses] = await connection.execute('SELECT status, COUNT(*) as count FROM annonces GROUP BY status');
      console.log('📊 Répartition par statut:');
      statuses.forEach(status => {
        console.log(`  - ${status.status}: ${status.count}`);
      });
    }
    
  } catch (error) {
    console.error('❌ Erreur lors du test:', error);
  } finally {
    if (connection) {
      connection.release();
    }
  }
}

testFeedOpportunities(); 