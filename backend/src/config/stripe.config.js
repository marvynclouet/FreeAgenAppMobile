// Vérifier que la clé Stripe existe
if (!process.env.STRIPE_SECRET_KEY || process.env.STRIPE_SECRET_KEY.includes('your_stripe_secret_key')) {
  console.warn('⚠️  STRIPE_SECRET_KEY non configurée - fonctionnalités Stripe désactivées');
  module.exports = null;
} else {
  const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
  module.exports = stripe;
} 