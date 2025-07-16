const mysql = require('mysql2/promise');
require('dotenv').config();

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'freeagent_db',
  port: process.env.DB_PORT || 3306
};

async function fixOpportunitiesTable() {
  let connection;
  
  try {
    console.log('🔧 Correction de la table opportunities...');
    
    connection = await mysql.createConnection(dbConfig);
    
    // Vérifier la structure actuelle
    console.log('📊 Structure actuelle de la table opportunities:');
    const [columns] = await connection.execute('DESCRIBE opportunities');
    columns.forEach(col => {
      console.log(`   - ${col.Field}: ${col.Type} ${col.Null === 'YES' ? 'NULL' : 'NOT NULL'}`);
    });
    
    // Vérifier si les colonnes nécessaires existent
    const columnNames = columns.map(col => col.Field);
    const requiredColumns = ['user_id', 'title', 'description', 'image_url', 'location', 'salary_range', 'requirements', 'status'];
    
    console.log('\n🔍 Vérification des colonnes requises:');
    for (const col of requiredColumns) {
      if (columnNames.includes(col)) {
        console.log(`✅ ${col} existe`);
      } else {
        console.log(`❌ ${col} manquant`);
      }
    }
    
    // Ajouter les colonnes manquantes
    console.log('\n🔧 Ajout des colonnes manquantes...');
    
    if (!columnNames.includes('user_id')) {
      await connection.execute('ALTER TABLE opportunities ADD COLUMN user_id INT NOT NULL');
      console.log('✅ Colonne user_id ajoutée');
    }
    
    if (!columnNames.includes('image_url')) {
      await connection.execute('ALTER TABLE opportunities ADD COLUMN image_url VARCHAR(500)');
      console.log('✅ Colonne image_url ajoutée');
    }
    
    // Ajouter la clé étrangère si elle n'existe pas
    try {
      await connection.execute('ALTER TABLE opportunities ADD CONSTRAINT fk_opportunities_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE');
      console.log('✅ Clé étrangère ajoutée');
    } catch (error) {
      if (error.code === 'ER_DUP_KEYNAME') {
        console.log('ℹ️ Clé étrangère existe déjà');
      } else {
        console.log('❌ Erreur clé étrangère:', error.message);
      }
    }
    
    // Insérer des données de test
    console.log('\n📝 Insertion de données de test...');
    
    const [users] = await connection.execute('SELECT id, name FROM users LIMIT 2');
    const [teams] = await connection.execute('SELECT id FROM teams LIMIT 1');
    
    if (users.length > 0 && teams.length > 0) {
      const testOpportunities = [
        {
          team_id: teams[0].id,
          user_id: users[0].id,
          title: 'Recrutement Joueur Pro',
          description: 'Le club ASVEL recherche un meneur de jeu pour la saison 2024-2025. Profil recherché : joueur expérimenté avec un bon leadership.',
          type: 'recrutement',
          image_url: 'https://via.placeholder.com/400x200',
          location: 'Lyon, France',
          salary_range: '5000-8000€/mois',
          requirements: 'Pro A, Leadership, Expérience',
          status: 'open'
        },
        {
          team_id: teams[0].id,
          user_id: users[0].id,
          title: 'Coach Assistant Recherché',
          description: 'Le club de Nanterre recherche un coach assistant pour accompagner l\'équipe première. Formation requise et expérience appréciée.',
          type: 'coaching',
          image_url: 'https://via.placeholder.com/400x200',
          location: 'Nanterre, France',
          salary_range: '3000-4500€/mois',
          requirements: 'Diplôme coach, Expérience, Disponibilité',
          status: 'open'
        }
      ];
      
      for (const opp of testOpportunities) {
        await connection.execute(`
          INSERT INTO opportunities (team_id, user_id, title, description, type, image_url, location, salary_range, requirements, status, created_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 5) DAY))
        `, [opp.team_id, opp.user_id, opp.title, opp.description, opp.type, opp.image_url, opp.location, opp.salary_range, opp.requirements, opp.status]);
      }
      
      console.log('✅ Opportunités de test insérées');
    } else {
      console.log('❌ Pas assez d\'utilisateurs ou d\'équipes pour créer des opportunités de test');
    }
    
    // Vérifier le résultat
    const [count] = await connection.execute('SELECT COUNT(*) as count FROM opportunities');
    console.log(`\n📊 Opportunités dans la base: ${count[0].count}`);
    
    console.log('\n✅ Table opportunities corrigée !');
    
  } catch (error) {
    console.error('❌ Erreur lors de la correction :', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

// Exécuter le script
fixOpportunitiesTable(); 