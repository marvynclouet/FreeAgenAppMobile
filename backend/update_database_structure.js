const https = require('https');

// Fonction pour exécuter une requête SQL via l'API
function executeSQL(sql) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({ sql });
    
    const options = {
      hostname: 'freeagenappmobile-production.up.railway.app',
      port: 443,
      path: '/api/admin/execute-sql',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    const req = https.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        try {
          const jsonData = JSON.parse(responseData);
          resolve({ status: res.statusCode, data: jsonData });
        } catch (e) {
          resolve({ status: res.statusCode, data: responseData });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.write(postData);
    req.end();
  });
}

// Fonction pour mettre à jour la structure de la base de données
async function updateDatabaseStructure() {
  console.log('🔧 Mise à jour de la structure de la base de données...\n');

  const sqlCommands = [
    // 1. Modifier l'énumération profile_type
    "ALTER TABLE users MODIFY COLUMN profile_type ENUM('player', 'handibasket', 'coach_pro', 'coach_basket', 'juriste', 'dieteticienne', 'club', 'handibasket_team') NOT NULL",
    
    // 2. Créer la table des profils d'équipes handibasket
    `CREATE TABLE IF NOT EXISTS handibasket_team_profiles (
      id INT PRIMARY KEY AUTO_INCREMENT,
      user_id INT NOT NULL,
      team_name VARCHAR(255) NOT NULL,
      city VARCHAR(100) NOT NULL,
      region VARCHAR(100),
      level ENUM('Regional', 'Nationale 3', 'Nationale 2', 'Nationale 1', 'Elite') NOT NULL,
      division VARCHAR(50),
      founded_year INT,
      description TEXT,
      achievements TEXT,
      contact_person VARCHAR(255),
      phone VARCHAR(20),
      email_contact VARCHAR(255),
      website VARCHAR(255),
      social_media JSON,
      facilities TEXT,
      training_schedule TEXT,
      competition_schedule TEXT,
      recruitment_needs TEXT,
      budget_range VARCHAR(100),
      accommodation_offered BOOLEAN DEFAULT FALSE,
      transport_offered BOOLEAN DEFAULT FALSE,
      medical_support BOOLEAN DEFAULT FALSE,
      coaching_staff JSON,
      player_requirements TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )`,
    
    // 3. Ajouter des colonnes pour les opportunités handibasket
    "ALTER TABLE opportunities ADD COLUMN handibasket_specific BOOLEAN DEFAULT FALSE",
    "ALTER TABLE opportunities ADD COLUMN handicap_types JSON",
    "ALTER TABLE opportunities ADD COLUMN classification_required VARCHAR(50)",
    "ALTER TABLE opportunities ADD COLUMN experience_required INT",
    "ALTER TABLE opportunities ADD COLUMN position_required VARCHAR(100)",
    "ALTER TABLE opportunities ADD COLUMN level_required VARCHAR(100)"
  ];

  for (const sql of sqlCommands) {
    console.log(`📝 Exécution: ${sql.substring(0, 50)}...`);
    
    try {
      const response = await executeSQL(sql);
      
      if (response.status === 200) {
        console.log(`✅ Succès`);
      } else {
        console.log(`⚠️ Erreur: ${response.status} - ${response.data.message || response.data}`);
      }
    } catch (error) {
      console.log(`❌ Erreur de connexion: ${error.message}`);
    }
    
    console.log('');
  }

  console.log('🎉 Mise à jour de la structure terminée !');
}

// Exécuter le script
updateDatabaseStructure();
