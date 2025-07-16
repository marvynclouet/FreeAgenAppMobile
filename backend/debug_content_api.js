const mysql = require('mysql2/promise');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'freeagent_db',
  port: process.env.DB_PORT || 3306
};

async function debugContentAPI() {
  let connection;
  
  try {
    console.log('🔍 Debug de l\'API de contenu...');
    
    connection = await mysql.createConnection(dbConfig);
    
    // Test 1: Vérifier la connexion
    console.log('✅ Connexion à la base de données réussie');
    
    // Test 2: Vérifier les tables
    const tables = ['posts', 'post_likes', 'post_comments', 'events', 'opportunities', 'users'];
    for (const table of tables) {
      try {
        const [result] = await connection.execute(`SELECT COUNT(*) as count FROM ${table}`);
        console.log(`📊 Table ${table}: ${result[0].count} enregistrements`);
      } catch (error) {
        console.log(`❌ Erreur table ${table}:`, error.message);
      }
    }
    
    // Test 3: Vérifier les posts avec leurs auteurs
    console.log('\n📝 Test de la requête posts...');
    try {
      const [posts] = await connection.execute(`
        SELECT 
          p.id,
          p.content,
          p.created_at,
          u.name as author_name,
          u.profile_type as author_type
        FROM posts p
        JOIN users u ON p.user_id = u.id
        LIMIT 3
      `);
      console.log(`✅ ${posts.length} posts trouvés`);
      posts.forEach((post, index) => {
        console.log(`   ${index + 1}. ${post.author_name} (${post.author_type}): ${post.content.substring(0, 50)}...`);
      });
    } catch (error) {
      console.log('❌ Erreur requête posts:', error.message);
    }
    
    // Test 4: Vérifier les opportunités
    console.log('\n💼 Test de la requête opportunités...');
    try {
      const [opportunities] = await connection.execute(`
        SELECT 
          o.id,
          o.title,
          o.description,
          o.created_at,
          u.name as author_name
        FROM opportunities o
        JOIN users u ON o.user_id = u.id
        WHERE o.status = 'active'
        LIMIT 3
      `);
      console.log(`✅ ${opportunities.length} opportunités trouvées`);
      opportunities.forEach((opp, index) => {
        console.log(`   ${index + 1}. ${opp.author_name}: ${opp.title}`);
      });
    } catch (error) {
      console.log('❌ Erreur requête opportunités:', error.message);
    }
    
    // Test 5: Vérifier les événements
    console.log('\n📅 Test de la requête événements...');
    try {
      const [events] = await connection.execute(`
        SELECT 
          e.id,
          e.title,
          e.description,
          e.event_date,
          u.name as author_name
        FROM events e
        JOIN users u ON e.user_id = u.id
        WHERE e.event_date >= CURDATE()
        LIMIT 3
      `);
      console.log(`✅ ${events.length} événements trouvés`);
      events.forEach((event, index) => {
        console.log(`   ${index + 1}. ${event.author_name}: ${event.title} (${event.event_date})`);
      });
    } catch (error) {
      console.log('❌ Erreur requête événements:', error.message);
    }
    
    // Test 6: Simuler la requête complète du feed
    console.log('\n🔄 Test de la requête complète du feed...');
    try {
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
      
      const [opportunities] = await connection.execute(`
        SELECT 
          o.id,
          'opportunity' as type,
          o.title,
          o.description as content,
          o.image_url,
          o.location,
          o.salary_range,
          o.requirements,
          o.created_at,
          u.name as author_name,
          u.profile_type as author_type,
          u.profile_image_url as author_avatar
        FROM opportunities o
        JOIN users u ON o.user_id = u.id
        WHERE o.status = 'active'
        ORDER BY o.created_at DESC
        LIMIT 10
      `);
      
      const [events] = await connection.execute(`
        SELECT 
          e.id,
          'event' as type,
          e.title,
          e.description as content,
          e.image_url,
          e.event_date,
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
      
      const feed = [...posts, ...opportunities, ...events]
        .sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
      
      console.log(`✅ Feed complet: ${feed.length} éléments`);
      console.log(`   - Posts: ${posts.length}`);
      console.log(`   - Opportunités: ${opportunities.length}`);
      console.log(`   - Événements: ${events.length}`);
      
    } catch (error) {
      console.log('❌ Erreur requête feed complet:', error.message);
    }
    
  } catch (error) {
    console.error('❌ Erreur lors du debug :', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

// Exécuter le debug
debugContentAPI(); 