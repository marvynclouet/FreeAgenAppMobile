const https = require('https');

// Fonction pour faire une requête POST
function makeRequest(url, data) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(data);
    
    const options = {
      hostname: 'freeagenappmobile-production.up.railway.app',
      port: 443,
      path: url,
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

// Fonction pour faire une requête PUT
function makePutRequest(url, data, token) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(data);
    
    const options = {
      hostname: 'freeagenappmobile-production.up.railway.app',
      port: 443,
      path: url,
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
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

// Fonction pour créer une équipe handibasket complète
async function createHandibasketTeam(teamData) {
  console.log(`🏀 Création de l'équipe ${teamData.team_name}...`);
  
  try {
    // 1. Inscription
    const registerData = {
      name: teamData.team_name,
      email: teamData.email,
      password: teamData.password,
      profile_type: 'handibasket_team',
      gender: 'M',
      nationality: 'Française'
    };

    const registerResponse = await makeRequest('/api/auth/register', registerData);
    
    if (registerResponse.status !== 201) {
      console.log(`❌ Erreur d'inscription pour ${teamData.team_name}:`);
      console.log(`   Status: ${registerResponse.status}`);
      console.log(`   Message: ${registerResponse.data.message || registerResponse.data}`);
      return;
    }

    const token = registerResponse.data.token;
    console.log(`✅ ${teamData.team_name} inscrit avec succès`);

    // 2. Mise à jour du profil d'équipe
    const profileData = {
      team_name: teamData.team_name,
      city: teamData.city,
      region: teamData.region,
      level: teamData.level,
      division: teamData.division,
      founded_year: teamData.founded_year,
      description: teamData.description,
      achievements: teamData.achievements,
      contact_person: teamData.contact_person,
      phone: teamData.phone,
      email_contact: teamData.email_contact,
      website: teamData.website,
      facilities: teamData.facilities,
      training_schedule: teamData.training_schedule,
      recruitment_needs: teamData.recruitment_needs,
      budget_range: teamData.budget_range,
      accommodation_offered: teamData.accommodation_offered,
      transport_offered: teamData.transport_offered,
      medical_support: teamData.medical_support,
      player_requirements: teamData.player_requirements
    };

    const profileResponse = await makePutRequest('/api/handibasket-teams/profile', profileData, token);
    
    if (profileResponse.status === 200) {
      console.log(`✅ Profil d'équipe mis à jour pour ${teamData.team_name}`);
    } else {
      console.log(`⚠️ Erreur lors de la mise à jour du profil pour ${teamData.team_name}:`);
      console.log(`   Status: ${profileResponse.status}`);
      console.log(`   Message: ${profileResponse.data.message || profileResponse.data}`);
    }

  } catch (error) {
    console.log(`❌ Erreur pour ${teamData.team_name}: ${error.message}`);
  }
  
  console.log('');
}

// Fonction principale
async function createHandibasketTeams() {
  console.log('🏀 Création des équipes handibasket...\n');

  const teams = [
    {
      team_name: 'Paris Handibasket Club',
      email: 'contact@paris-handibasket.fr',
      password: 'Test123!',
      city: 'Paris',
      region: 'Île-de-France',
      level: 'Elite',
      division: 'Championnat de France',
      founded_year: 1995,
      description: 'Club de handibasket de haut niveau basé à Paris, évoluant en Elite. Nous recherchons des joueurs talentueux pour renforcer notre effectif.',
      achievements: 'Champions de France 2023, Vice-champions d\'Europe 2022, 3 titres de champion de France',
      contact_person: 'Jean-Pierre Durand',
      phone: '01 23 45 67 89',
      email_contact: 'contact@paris-handibasket.fr',
      website: 'https://paris-handibasket.fr',
      facilities: 'Gymnase moderne avec équipements adaptés, salle de musculation, vestiaires accessibles',
      training_schedule: 'Mardi et Jeudi 19h-21h, Samedi 14h-16h',
      recruitment_needs: 'Recherche 2 pivots et 1 meneur de jeu pour la saison 2024-2025',
      budget_range: '2000-5000€/mois',
      accommodation_offered: true,
      transport_offered: true,
      medical_support: true,
      player_requirements: 'Classification I-II, expérience minimum 3 ans, niveau Elite ou Nationale 1'
    },
    {
      team_name: 'Lyon Handibasket Association',
      email: 'info@lyon-handibasket.fr',
      password: 'Test123!',
      city: 'Lyon',
      region: 'Auvergne-Rhône-Alpes',
      level: 'Nationale 1',
      division: 'Championnat de France',
      founded_year: 1988,
      description: 'Association handibasket dynamique de Lyon, évoluant en Nationale 1. Nous développons le handibasket dans la région.',
      achievements: 'Champions de France Nationale 2 en 2022, Finalistes coupe de France 2023',
      contact_person: 'Marie-Claire Bernard',
      phone: '04 78 12 34 56',
      email_contact: 'info@lyon-handibasket.fr',
      website: 'https://lyon-handibasket.fr',
      facilities: 'Complexe sportif avec 2 terrains, salle de réunion, espace détente',
      training_schedule: 'Lundi et Mercredi 18h30-20h30, Dimanche 10h-12h',
      recruitment_needs: 'Recherche 1 ailier et 1 arrière pour compléter l\'effectif',
      budget_range: '1500-3000€/mois',
      accommodation_offered: false,
      transport_offered: true,
      medical_support: true,
      player_requirements: 'Classification II-III, expérience minimum 2 ans, niveau Nationale 1 ou 2'
    }
  ];

  for (const team of teams) {
    await createHandibasketTeam(team);
  }

  console.log('🎉 Toutes les équipes handibasket ont été créées !');
  console.log('\n📋 Résumé des équipes créées :');
  teams.forEach(team => {
    console.log(`- ${team.team_name} (${team.email}) - Mot de passe: Test123!`);
  });
}

// Exécuter le script
createHandibasketTeams();
