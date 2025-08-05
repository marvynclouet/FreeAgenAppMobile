const express = require('express');
const bcrypt = require('bcrypt');
const pool = require('./src/config/db.config');

async function testHandibasketRegistration() {
  try {
    console.log('🧪 Test d\'inscription handibasket...');
    
    const name = 'Test Handibasket';
    const email = 'test.handibasket2@test.com';
    const password = 'test123';
    const profile_type = 'handibasket';

    // Vérifier si l'email existe déjà
    console.log('1. Vérification email existant...');
    const [existingUsers] = await pool.query(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );

    if (existingUsers.length > 0) {
      console.log('❌ Email déjà utilisé');
      return;
    }

    // Hasher le mot de passe
    console.log('2. Hashage du mot de passe...');
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Insérer l'utilisateur
    console.log('3. Insertion utilisateur...');
    const [result] = await pool.query(
      'INSERT INTO users (name, email, password, profile_type) VALUES (?, ?, ?, ?)',
      [name, email, hashedPassword, profile_type]
    );

    const userId = result.insertId;
    console.log('✅ Utilisateur créé avec ID:', userId);

    // Créer le profil handibasket
    console.log('4. Création profil handibasket...');
    const [handibasketResult] = await pool.query(
      `INSERT INTO handibasket_profiles (
        user_id, 
        birth_date, 
        handicap_type, 
        cat, 
        residence, 
        profession
      ) VALUES (?, CURDATE(), 'Non spécifié', 'Non spécifié', 'Non spécifié', 'Non spécifié')`,
      [userId]
    );

    console.log('✅ Profil handibasket créé avec ID:', handibasketResult.insertId);
    console.log('🎉 Inscription handibasket réussie !');

    // Vérifier que tout est bien créé
    console.log('5. Vérification finale...');
    const [userCheck] = await pool.query('SELECT * FROM users WHERE id = ?', [userId]);
    const [profileCheck] = await pool.query('SELECT * FROM handibasket_profiles WHERE user_id = ?', [userId]);
    
    console.log('Utilisateur:', userCheck[0]);
    console.log('Profil handibasket:', profileCheck[0]);

  } catch (error) {
    console.error('❌ Erreur lors du test:', error);
    console.error('Stack trace:', error.stack);
  } finally {
    await pool.end();
  }
}

testHandibasketRegistration(); 