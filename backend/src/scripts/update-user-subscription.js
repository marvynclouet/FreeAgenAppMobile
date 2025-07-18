const db = require('../database/db');

async function updateUserSubscription() {
  const args = process.argv.slice(2);
  
  if (args.length < 3) {
    console.log('Usage: node update-user-subscription.js <email> <subscription_type> <expiry_date>');
    console.log('Example: node update-user-subscription.js user@example.com premium_pro 2025-12-31');
    console.log('Subscription types: free, premium_basic, premium_pro');
    process.exit(1);
  }

  const [email, subscriptionType, expiryDate] = args;

  try {
    console.log(`Mise à jour de l'abonnement pour ${email}...`);
    
    // Vérifier que l'utilisateur existe
    const [users] = await db.execute(
      'SELECT id, name, subscription_type FROM users WHERE email = ?',
      [email]
    );

    if (users.length === 0) {
      console.log('❌ Utilisateur non trouvé');
      process.exit(1);
    }

    const user = users[0];
    console.log(`Utilisateur trouvé: ${user.name} (ID: ${user.id})`);
    console.log(`Ancien abonnement: ${user.subscription_type || 'free'}`);

    // Mettre à jour l'abonnement
    const expiryDateTime = expiryDate ? `${expiryDate}T23:59:59` : null;
    
    await db.execute(
      `UPDATE users 
       SET subscription_type = ?, 
           subscription_expiry = ?, 
           subscription_created_at = NOW(),
           is_premium = ?
       WHERE email = ?`,
      [
        subscriptionType,
        expiryDateTime,
        subscriptionType !== 'free' ? 1 : 0,
        email
      ]
    );

    console.log('✅ Abonnement mis à jour avec succès !');
    console.log(`Nouveau type: ${subscriptionType}`);
    console.log(`Expiration: ${expiryDate || 'Aucune'}`);
    console.log(`Premium: ${subscriptionType !== 'free' ? 'Oui' : 'Non'}`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur lors de la mise à jour:', error);
    process.exit(1);
  }
}

updateUserSubscription(); 