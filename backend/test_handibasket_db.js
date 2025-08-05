const mysql = require('mysql2/promise');

// Configuration de la base de données Railway
const dbConfig = {
  host: 'mysql.railway.internal',
  user: 'root',
  password: 'WkdwbGCWQhjNdeGEumAVztCSRXvZn',
  database: 'railway',
  port: 3306
};

async function testHandibasketDatabase() {
  let connection;
  
  try {
    console.log('🔌 Connexion à la base de données Railway...');
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Connexion réussie');

    // 1. Vérifier la structure de la table handibasket_profiles
    console.log('\n📋 Structure de la table handibasket_profiles:');
    const [columns] = await connection.execute('DESCRIBE handibasket_profiles');
    columns.forEach(col => {
      console.log(`  - ${col.Field}: ${col.Type} ${col.Null === 'NO' ? '(NOT NULL)' : '(NULL)'} ${col.Default ? `DEFAULT: ${col.Default}` : ''}`);
    });

    // 2. Vérifier les contraintes
    console.log('\n🔍 Contraintes de la table:');
    const [constraints] = await connection.execute(`
      SELECT 
        CONSTRAINT_NAME,
        COLUMN_NAME,
        REFERENCED_TABLE_NAME,
        REFERENCED_COLUMN_NAME
      FROM information_schema.KEY_COLUMN_USAGE 
      WHERE TABLE_SCHEMA = 'railway' 
      AND TABLE_NAME = 'handibasket_profiles'
    `);
    
    if (constraints.length > 0) {
      constraints.forEach(constraint => {
        console.log(`  - ${constraint.CONSTRAINT_NAME}: ${constraint.COLUMN_NAME} -> ${constraint.REFERENCED_TABLE_NAME}.${constraint.REFERENCED_COLUMN_NAME}`);
      });
    } else {
      console.log('  - Aucune contrainte trouvée');
    }

    // 3. Compter les profils handibasket existants
    console.log('\n📊 Profils handibasket existants:');
    const [countResult] = await connection.execute('SELECT COUNT(*) as count FROM handibasket_profiles');
    console.log(`  - Nombre total: ${countResult[0].count}`);

    // 4. Vérifier les données existantes
    const [existingProfiles] = await connection.execute(`
      SELECT 
        hp.id,
        hp.user_id,
        hp.birth_date,
        hp.handicap_type,
        hp.cat,
        hp.residence,
        hp.profession,
        u.name,
        u.email
      FROM handibasket_profiles hp
      JOIN users u ON hp.user_id = u.id
      LIMIT 5
    `);

    if (existingProfiles.length > 0) {
      console.log('\n👥 Exemples de profils existants:');
      existingProfiles.forEach(profile => {
        console.log(`  - ID: ${profile.id}, User: ${profile.name} (${profile.email})`);
        console.log(`    Birth: ${profile.birth_date}, Handicap: ${profile.handicap_type}, Cat: ${profile.cat}`);
        console.log(`    Residence: ${profile.residence}, Profession: ${profile.profession}`);
      });
    } else {
      console.log('\n❌ Aucun profil handibasket trouvé');
    }

    // 5. Test d'insertion simulé
    console.log('\n🧪 Test d\'insertion simulé:');
    const testData = {
      user_id: 999999, // ID fictif pour le test
      birth_date: '1990-01-01',
      handicap_type: 'Physique',
      cat: 'Sport',
      residence: 'Paris',
      profession: 'Étudiant',
      club: 'Test Club',
      coach: 'Test Coach',
      position: 'polyvalent',
      championship_level: 'non_specifie'
    };

    console.log('  Données de test:', testData);

    // Vérifier si l'insertion fonctionnerait
    try {
      await connection.execute(`
        INSERT INTO handibasket_profiles (
          user_id, birth_date, handicap_type, cat, residence, profession, 
          club, coach, position, championship_level
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `, [
        testData.user_id,
        testData.birth_date,
        testData.handicap_type,
        testData.cat,
        testData.residence,
        testData.profession,
        testData.club,
        testData.coach,
        testData.position,
        testData.championship_level
      ]);
      
      console.log('✅ Test d\'insertion réussi');
      
      // Nettoyer le test
      await connection.execute('DELETE FROM handibasket_profiles WHERE user_id = ?', [testData.user_id]);
      console.log('🧹 Données de test supprimées');
      
    } catch (insertError) {
      console.log('❌ Erreur lors du test d\'insertion:', insertError.message);
      console.log('   Code:', insertError.code);
      console.log('   SQL:', insertError.sql);
    }

    console.log('\n✅ Test terminé avec succès');

  } catch (error) {
    console.error('❌ Erreur:', error.message);
    console.error('   Code:', error.code);
    if (error.sql) {
      console.error('   SQL:', error.sql);
    }
  } finally {
    if (connection) {
      await connection.end();
      console.log('\n🔌 Connexion fermée');
    }
  }
}

// Exécuter le test
testHandibasketDatabase(); 