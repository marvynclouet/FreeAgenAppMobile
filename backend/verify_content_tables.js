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

async function verifyContentTables() {
  let connection;
  
  try {
    console.log('🔍 Vérification des tables du système de contenu...');
    
    connection = await mysql.createConnection(dbConfig);
    
    // Vérifier si les tables existent
    const tablesToCheck = [
      'posts',
      'post_likes', 
      'post_comments',
      'events',
      'opportunities'
    ];
    
    for (const table of tablesToCheck) {
      try {
        const [result] = await connection.execute(`SHOW TABLES LIKE '${table}'`);
        if (result.length > 0) {
          console.log(`✅ Table '${table}' existe`);
        } else {
          console.log(`❌ Table '${table}' manquante`);
        }
      } catch (error) {
        console.log(`❌ Erreur lors de la vérification de '${table}':`, error.message);
      }
    }
    
    // Créer les tables manquantes
    console.log('\n🔧 Création des tables manquantes...');
    
    const sqlFile = path.join(__dirname, 'src/database/posts_tables.sql');
    if (fs.existsSync(sqlFile)) {
      const sqlContent = fs.readFileSync(sqlFile, 'utf8');
      const statements = sqlContent.split(';').filter(stmt => stmt.trim());
      
      for (const statement of statements) {
        if (statement.trim()) {
          try {
            await connection.execute(statement);
            console.log('✅ Table créée/mise à jour');
          } catch (error) {
            if (error.code === 'ER_TABLE_EXISTS_ERROR') {
              console.log('ℹ️ Table existe déjà');
            } else {
              console.log('❌ Erreur lors de la création:', error.message);
            }
          }
        }
      }
    } else {
      console.log('❌ Fichier SQL non trouvé');
    }
    
    // Vérifier la table opportunities
    try {
      const [result] = await connection.execute(`SHOW TABLES LIKE 'opportunities'`);
      if (result.length === 0) {
        console.log('🔧 Création de la table opportunities...');
        await connection.execute(`
          CREATE TABLE IF NOT EXISTS opportunities (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            title VARCHAR(255) NOT NULL,
            description TEXT,
            image_url VARCHAR(500),
            location VARCHAR(255),
            salary_range VARCHAR(100),
            requirements JSON,
            status ENUM('active', 'inactive', 'closed') DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        `);
        console.log('✅ Table opportunities créée');
      }
    } catch (error) {
      console.log('❌ Erreur lors de la création de opportunities:', error.message);
    }
    
    // Insérer des données de test si les tables sont vides
    console.log('\n📝 Vérification des données de test...');
    
    const [postCount] = await connection.execute('SELECT COUNT(*) as count FROM posts');
    if (postCount[0].count === 0) {
      console.log('📝 Insertion de données de test...');
      
      // Récupérer quelques utilisateurs existants
      const [users] = await connection.execute('SELECT id, name, profile_type FROM users LIMIT 3');
      
      if (users.length > 0) {
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
            user_id: users[0].id,
            content: 'Entraînement ce matin avec l\'équipe ! 💪 La préparation physique est essentielle pour performer au plus haut niveau. #Training #Basketball',
            image_urls: JSON.stringify(['https://via.placeholder.com/400x300']),
            event_date: null,
            event_location: null
          }
        ];
        
        for (const post of testPosts) {
          await connection.execute(`
            INSERT INTO posts (user_id, content, image_urls, event_date, event_location, created_at)
            VALUES (?, ?, ?, ?, ?, DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 7) DAY))
          `, [post.user_id, post.content, post.image_urls, post.event_date, post.event_location]);
        }
        
        console.log('✅ Posts de test insérés');
      }
    } else {
      console.log(`ℹ️ ${postCount[0].count} posts existent déjà`);
    }
    
    // Vérifier les opportunités
    const [oppCount] = await connection.execute('SELECT COUNT(*) as count FROM opportunities');
    if (oppCount[0].count === 0) {
      console.log('📝 Insertion d\'opportunités de test...');
      
      const [users] = await connection.execute('SELECT id, name FROM users WHERE profile_type = "club" LIMIT 2');
      if (users.length === 0) {
        const [allUsers] = await connection.execute('SELECT id, name FROM users LIMIT 2');
        if (allUsers.length > 0) {
          const testOpportunities = [
            {
              user_id: allUsers[0].id,
              title: 'Recrutement Joueur Pro',
              description: 'Le club ASVEL recherche un meneur de jeu pour la saison 2024-2025. Profil recherché : joueur expérimenté avec un bon leadership.',
              image_url: 'https://via.placeholder.com/400x200',
              location: 'Lyon, France',
              salary_range: '5000-8000€/mois',
              requirements: JSON.stringify(['Pro A', 'Leadership', 'Expérience'])
            },
            {
              user_id: allUsers[0].id,
              title: 'Coach Assistant Recherché',
              description: 'Le club de Nanterre recherche un coach assistant pour accompagner l\'équipe première. Formation requise et expérience appréciée.',
              image_url: 'https://via.placeholder.com/400x200',
              location: 'Nanterre, France',
              salary_range: '3000-4500€/mois',
              requirements: JSON.stringify(['Diplôme coach', 'Expérience', 'Disponibilité'])
            }
          ];
          
          for (const opp of testOpportunities) {
            await connection.execute(`
              INSERT INTO opportunities (user_id, title, description, image_url, location, salary_range, requirements, created_at)
              VALUES (?, ?, ?, ?, ?, ?, ?, DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 5) DAY))
            `, [opp.user_id, opp.title, opp.description, opp.image_url, opp.location, opp.salary_range, opp.requirements]);
          }
          
          console.log('✅ Opportunités de test insérées');
        }
      }
    } else {
      console.log(`ℹ️ ${oppCount[0].count} opportunités existent déjà`);
    }
    
    console.log('\n✅ Vérification terminée !');
    
  } catch (error) {
    console.error('❌ Erreur lors de la vérification :', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

// Exécuter le script
verifyContentTables(); 