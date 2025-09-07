const axios = require('axios');

const BASE_URL = 'https://freeagenappmobile-production.up.railway.app';

async function activatePremiumForTestAccounts() {
  try {
    console.log('💎 Activation du premium pour les comptes de test...');
    
    // 1. Activer le premium pour l'équipe
    console.log('📝 Activation premium équipe...');
    const teamLogin = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'equipe.handibasket.paris@gmail.com',
      password: 'Test123'
    });
    
    const teamToken = teamLogin.data.token;
    console.log('✅ Équipe connectée:', teamLogin.data.user.name);
    
    try {
      const teamPremiumResponse = await axios.post(`${BASE_URL}/api/payments/activate-free-premium`, {}, {
        headers: { Authorization: `Bearer ${teamToken}` }
      });
      console.log('✅ Premium équipe activé:', teamPremiumResponse.data);
    } catch (error) {
      console.log('❌ Erreur premium équipe:', error.response?.data || error.message);
    }
    
    // 2. Activer le premium pour le joueur
    console.log('📝 Activation premium joueur...');
    const playerLogin = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: 'joueur.handibasket.test@gmail.com',
      password: 'Test123'
    });
    
    const playerToken = playerLogin.data.token;
    console.log('✅ Joueur connecté:', playerLogin.data.user.name);
    
    try {
      const playerPremiumResponse = await axios.post(`${BASE_URL}/api/payments/activate-free-premium`, {}, {
        headers: { Authorization: `Bearer ${playerToken}` }
      });
      console.log('✅ Premium joueur activé:', playerPremiumResponse.data);
    } catch (error) {
      console.log('❌ Erreur premium joueur:', error.response?.data || error.message);
    }
    
    console.log('🎉 Premium activé pour tous les comptes de test !');
    
  } catch (error) {
    console.error('❌ Erreur générale:', error.response?.data || error.message);
  }
}

activatePremiumForTestAccounts();

