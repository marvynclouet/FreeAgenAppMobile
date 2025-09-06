const mysql = require('mysql2/promise');

async function createTeamProfileDirect() {
  let connection;
  
  try {
    console.log('🔗 Connexion à la base de données...');
    
    // Configuration de la base de données Railway
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'mysql.railway.internal',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || 'password',
      database: process.env.DB_NAME || 'railway',
      port: process.env.DB_PORT || 3306
    });
    
    console.log('✅ Connecté à la base de données');
    
    // 1. Vérifier l'utilisateur équipe handibasket
    console.log('🔍 Vérification de l\'utilisateur équipe...');
    const [teamUsers] = await connection.execute(
      'SELECT * FROM users WHERE email = ? AND profile_type = ?',
      ['equipe.handibasket.paris@gmail.com', 'handibasket_team']
    );
    
    if (teamUsers.length === 0) {
      console.log('❌ Utilisateur équipe non trouvé');
      return;
    }
    
    const teamUser = teamUsers[0];
    console.log('✅ Utilisateur équipe trouvé:', teamUser.id, teamUser.name);
    
    // 2. Vérifier si le profil existe déjà
    const [existingProfiles] = await connection.execute(
      'SELECT * FROM handibasket_team_profiles WHERE user_id = ?',
      [teamUser.id]
    );
    
    if (existingProfiles.length > 0) {
      console.log('✅ Profil équipe existe déjà');
      console.log('📊 Profil:', existingProfiles[0]);
    } else {
      console.log('📝 Création du profil équipe...');
      
      // Créer le profil équipe
      await connection.execute(`
        INSERT INTO handibasket_team_profiles 
        (user_id, team_name, city, region, level, division, founded_year, description,
         achievements, contact_person, phone, email_contact, website, facilities,
         training_schedule, recruitment_needs, budget_range, accommodation_offered,
         transport_offered, medical_support, player_requirements) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `, [
        teamUser.id,
        'Équipe Handibasket Paris',
        'Paris',
        'Île-de-France',
        'National',
        'Division 1',
        2020,
        'Équipe de handibasket de haut niveau recherchant des joueurs talentueux',
        'Champion de France 2023, Vice-champion 2022',
        'Jean Dupont',
        '0123456789',
        'contact@handibasket-paris.fr',
        'https://handibasket-paris.fr',
        'Gymnase moderne avec équipements adaptés, vestiaires accessibles',
        'Mardi et Jeudi 19h-21h, Samedi 10h-12h',
        'Recherche joueurs de niveau national, toutes positions',
        '5000-10000€',
        true,
        true,
        true,
        'Niveau national minimum, expérience handibasket requise, motivation et engagement'
      ]);
      
      console.log('✅ Profil équipe créé');
    }
    
    // 3. Vérifier l'utilisateur joueur handibasket
    console.log('🔍 Vérification de l\'utilisateur joueur...');
    const [playerUsers] = await connection.execute(
      'SELECT * FROM users WHERE email = ? AND profile_type = ?',
      ['joueur.handibasket.test@gmail.com', 'handibasket']
    );
    
    if (playerUsers.length === 0) {
      console.log('❌ Utilisateur joueur non trouvé');
      return;
    }
    
    const playerUser = playerUsers[0];
    console.log('✅ Utilisateur joueur trouvé:', playerUser.id, playerUser.name);
    
    // 4. Vérifier si le profil joueur existe déjà
    const [existingPlayerProfiles] = await connection.execute(
      'SELECT * FROM handibasket_profiles WHERE user_id = ?',
      [playerUser.id]
    );
    
    if (existingPlayerProfiles.length > 0) {
      console.log('✅ Profil joueur existe déjà');
      console.log('📊 Profil:', existingPlayerProfiles[0]);
    } else {
      console.log('📝 Création du profil joueur...');
      
      // Créer le profil joueur
      await connection.execute(`
        INSERT INTO handibasket_profiles 
        (user_id, birth_date, handicap_type, cat, residence, club, coach, profession,
         position, championship_level, passport_type, height, weight, experience_years,
         level, achievements, video_url, bio) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `, [
        playerUser.id,
        '1995-06-15',
        'moteur',
        '3',
        'Français',
        'Club Handibasket Test',
        'Coach Test',
        'Développeur',
        'meneur',
        'National',
        'Français',
        185,
        80,
        8,
        'National',
        'Champion de France 2022, Sélectionné en équipe de France',
        'https://youtube.com/watch?v=test',
        'Joueur passionné de handibasket avec 8 ans d\'expérience au niveau national. Recherche une équipe de haut niveau pour continuer ma progression.'
      ]);
      
      console.log('✅ Profil joueur créé');
    }
    
    // 5. Créer des annonces
    console.log('📝 Création des annonces...');
    
    // Annonce équipe
    const [existingTeamAnnouncements] = await connection.execute(
      'SELECT * FROM annonces WHERE user_id = ? AND type = ?',
      [teamUser.id, 'equipe_recherche_joueur']
    );
    
    if (existingTeamAnnouncements.length === 0) {
      await connection.execute(`
        INSERT INTO annonces 
        (user_id, title, description, type, requirements, salary_range, location, target_profile) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      `, [
        teamUser.id,
        'Recherche joueurs handibasket niveau national',
        'Équipe de handibasket de Paris recherche des joueurs talentueux pour la saison 2024-2025. Niveau national requis, toutes positions acceptées.',
        'equipe_recherche_joueur',
        'Niveau national, expérience handibasket, motivation',
        '5000-10000€',
        'Paris, Île-de-France',
        'handibasket'
      ]);
      console.log('✅ Annonce équipe créée');
    } else {
      console.log('✅ Annonce équipe existe déjà');
    }
    
    // Annonce joueur
    const [existingPlayerAnnouncements] = await connection.execute(
      'SELECT * FROM annonces WHERE user_id = ? AND type = ?',
      [playerUser.id, 'joueur_recherche_club']
    );
    
    if (existingPlayerAnnouncements.length === 0) {
      await connection.execute(`
        INSERT INTO annonces 
        (user_id, title, description, type, requirements, salary_range, location, target_profile) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      `, [
        playerUser.id,
        'Joueur handibasket niveau national cherche équipe',
        'Joueur expérimenté de handibasket niveau national recherche une équipe de haut niveau pour la saison 2024-2025. Position meneur, 8 ans d\'expérience.',
        'joueur_recherche_club',
        'Équipe de niveau national, entraînements réguliers',
        '5000-8000€',
        'Paris, Île-de-France',
        'handibasket_team'
      ]);
      console.log('✅ Annonce joueur créée');
    } else {
      console.log('✅ Annonce joueur existe déjà');
    }
    
    console.log('🎉 Configuration terminée !');
    
  } catch (error) {
    console.error('❌ Erreur:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

createTeamProfileDirect();