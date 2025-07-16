const mysql = require('mysql2/promise');
const dbConfig = require('./src/config/db.config');

async function testFeedAPI() {
  let connection;
  try {
    connection = await dbConfig.getConnection();
    
    console.log('🔍 Test de l\'API complète du fil d\'actualités...');
    
    // Récupérer les posts
    const [posts] = await connection.execute(`
      SELECT 
        p.id,
        'post' as type,
        p.content,
        p.image_urls,
        p.event_date,
        p.event_location,
        p.created_at,
        p.likes_count,
        p.comments_count,
        u.name as author_name,
        u.profile_type as author_type,
        u.profile_image_url as author_avatar
      FROM posts p
      JOIN users u ON p.user_id = u.id
      ORDER BY p.created_at DESC
      LIMIT 20
    `);

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

    // Récupérer les événements
    const [events] = await connection.execute(`
      SELECT 
        e.id,
        'event' as type,
        e.title,
        e.description as content,
        e.image_url,
        e.event_date,
        e.event_time,
        e.event_location,
        e.created_at,
        u.name as author_name,
        u.profile_type as author_type,
        u.profile_image_url as author_avatar
      FROM events e
      JOIN users u ON e.user_id = u.id
      WHERE e.event_date >= CURDATE()
      ORDER BY e.event_date ASC
      LIMIT 10
    `);

    // Combiner et trier par date
    const feed = [...posts, ...opportunities, ...events]
      .sort((a, b) => new Date(b.created_at) - new Date(a.created_at));

    console.log(`✅ Feed complet: ${feed.length} éléments`);
    console.log(`   - Posts: ${posts.length}`);
    console.log(`   - Opportunités: ${opportunities.length}`);
    console.log(`   - Événements: ${events.length}`);
    
    console.log('\n📋 Détails du feed:');
    feed.forEach((item, index) => {
      console.log(`  ${index + 1}. [${item.type.toUpperCase()}] ${item.title || item.content?.substring(0, 50)}...`);
      console.log(`     Auteur: ${item.author_name} (${item.author_type})`);
      console.log(`     Date: ${item.created_at}`);
      if (item.type === 'opportunity') {
        console.log(`     Localisation: ${item.location || 'Non spécifiée'}`);
        console.log(`     Salaire: ${item.salary_range || 'Non spécifié'}`);
      }
      if (item.type === 'event' && item.event_time) {
        console.log(`     Heure: ${item.event_time}`);
      }
      console.log('');
    });
    
  } catch (error) {
    console.error('❌ Erreur lors du test:', error);
  } finally {
    if (connection) {
      connection.release();
    }
  }
}

testFeedAPI(); 