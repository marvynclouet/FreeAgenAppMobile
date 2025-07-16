const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'freeagent_db',
  port: process.env.DB_PORT || 3306
};

async function setupContentSystem() {
  let connection;
  
  try {
    console.log('🔧 Configuration du système de contenu...');
    
    connection = await mysql.createConnection(dbConfig);
    
    // Lire et exécuter le fichier SQL des tables
    const sqlFile = path.join(__dirname, 'src/database/posts_tables.sql');
    const sqlContent = fs.readFileSync(sqlFile, 'utf8');
    
    const statements = sqlContent.split(';').filter(stmt => stmt.trim());
    
    for (const statement of statements) {
      if (statement.trim()) {
        await connection.execute(statement);
        console.log('✅ Table créée/mise à jour');
      }
    }
    
    // Insérer des données de test pour les posts
    console.log('📝 Insertion de données de test...');
    
    // Récupérer quelques utilisateurs existants
    const [users] = await connection.execute('SELECT id, name, profile_type FROM users LIMIT 5');
    
    if (users.length === 0) {
      console.log('❌ Aucun utilisateur trouvé. Créez d\'abord des utilisateurs.');
      return;
    }
    
    // Insérer des posts de test
    const testPosts = [
      {
        user_id: users[0].id,
        content: 'Super match hier soir ! 🏀 Félicitations à toute l\'équipe pour cette victoire importante. On continue sur cette lancée ! 💪 #Basketball #Victory',
        image_urls: JSON.stringify(['https://via.placeholder.com/400x300', 'https://via.placeholder.com/400x300']),
        event_date: null,
        event_location: null
      },
      {
        user_id: users[1]?.id || users[0].id,
        content: 'Entraînement ce matin avec l\'équipe ! 💪 La préparation physique est essentielle pour performer au plus haut niveau. #Training #Basketball',
        image_urls: JSON.stringify(['https://via.placeholder.com/400x300']),
        event_date: null,
        event_location: null
      },
      {
        user_id: users[2]?.id || users[0].id,
        content: 'Nouveau stage de perfectionnement ouvert ! Venez améliorer vos compétences avec nos coachs expérimentés. 📅 #Stage #Basketball',
        image_urls: JSON.stringify([]),
        event_date: '2024-02-15',
        event_location: 'Palais des Sports, Paris'
      }
    ];
    
    for (const post of testPosts) {
      await connection.execute(`
        INSERT INTO posts (user_id, content, image_urls, event_date, event_location, created_at)
        VALUES (?, ?, ?, ?, ?, DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 7) DAY))
      `, [post.user_id, post.content, post.image_urls, post.event_date, post.event_location]);
    }
    
    // Insérer des événements de test
    const testEvents = [
      {
        user_id: users[0].id,
        title: 'Tournoi National U18',
        description: 'Inscriptions ouvertes pour le tournoi national U18 qui se déroulera du 15 au 20 février 2024. Un événement à ne pas manquer !',
        image_url: 'https://via.placeholder.com/400x250',
        event_date: '2024-02-15',
        event_location: 'Paris, France',
        registration_deadline: '2024-02-01'
      },
      {
        user_id: users[1]?.id || users[0].id,
        title: 'Stage de Perfectionnement Pro',
        description: 'Stage intensif pour les joueurs professionnels et semi-professionnels. Techniques avancées et préparation mentale.',
        image_url: 'https://via.placeholder.com/400x250',
        event_date: '2024-03-01',
        event_location: 'Lyon, France',
        registration_deadline: '2024-02-15'
      }
    ];
    
    for (const event of testEvents) {
      await connection.execute(`
        INSERT INTO events (user_id, title, description, image_url, event_date, event_location, registration_deadline, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 5) DAY))
      `, [event.user_id, event.title, event.description, event.image_url, event.event_date, event.event_location, event.registration_deadline]);
    }
    
    // Insérer quelques likes et commentaires de test
    const [posts] = await connection.execute('SELECT id FROM posts LIMIT 3');
    
    for (const post of posts) {
      // Ajouter des likes
      for (let i = 0; i < Math.floor(Math.random() * 5) + 1; i++) {
        const randomUser = users[Math.floor(Math.random() * users.length)];
        try {
          await connection.execute(`
            INSERT INTO post_likes (post_id, user_id, created_at)
            VALUES (?, ?, NOW())
          `, [post.id, randomUser.id]);
        } catch (error) {
          // Ignorer les erreurs de doublon
        }
      }
      
      // Ajouter des commentaires
      const testComments = [
        'Super post ! 👍',
        'Merci pour le partage !',
        'Très motivant ! 💪',
        'À bientôt sur le terrain ! 🏀'
      ];
      
      for (let i = 0; i < Math.floor(Math.random() * 3) + 1; i++) {
        const randomUser = users[Math.floor(Math.random() * users.length)];
        const randomComment = testComments[Math.floor(Math.random() * testComments.length)];
        
        await connection.execute(`
          INSERT INTO post_comments (post_id, user_id, content, created_at)
          VALUES (?, ?, ?, DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 3) DAY))
        `, [post.id, randomUser.id, randomComment]);
      }
    }
    
    // Mettre à jour les compteurs
    await connection.execute(`
      UPDATE posts p 
      SET 
        likes_count = (SELECT COUNT(*) FROM post_likes WHERE post_id = p.id),
        comments_count = (SELECT COUNT(*) FROM post_comments WHERE post_id = p.id)
    `);
    
    console.log('✅ Système de contenu configuré avec succès !');
    console.log('📊 Données de test insérées :');
    console.log('   - Posts : 3');
    console.log('   - Événements : 2');
    console.log('   - Likes et commentaires : variables');
    
  } catch (error) {
    console.error('❌ Erreur lors de la configuration :', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

// Exécuter le script
setupContentSystem(); 