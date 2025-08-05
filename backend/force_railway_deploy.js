#!/usr/bin/env node

console.log('🚀 DIAGNOSTIC RAILWAY DEPLOYMENT');
console.log('================================');

// Vérifier les variables d'environnement Railway
const railwayEnvs = [
  'RAILWAY_ENVIRONMENT',
  'RAILWAY_PROJECT_ID',
  'RAILWAY_PROJECT_NAME',
  'RAILWAY_SERVICE_ID',
  'RAILWAY_SERVICE_NAME'
];

console.log('\n📋 Variables Railway:');
railwayEnvs.forEach(env => {
  console.log(`${env}: ${process.env[env] || 'NON DÉFINI'}`);
});

console.log('\n🔧 Version Node.js:', process.version);
console.log('📁 Répertoire courant:', process.cwd());

// Vérifier si nous sommes sur Railway
if (process.env.RAILWAY_ENVIRONMENT) {
  console.log('\n✅ NOUS SOMMES SUR RAILWAY!');
  console.log('🌍 Environment:', process.env.RAILWAY_ENVIRONMENT);
} else {
  console.log('\n❌ PAS SUR RAILWAY - Test local');
}

// Test simple de l'API
const express = require('express');
const app = express();

app.get('/test-deploy', (req, res) => {
  res.json({
    message: 'RAILWAY DEPLOYMENT TEST',
    timestamp: new Date().toISOString(),
    version: 'v3-force-deploy',
    environment: process.env.RAILWAY_ENVIRONMENT || 'local'
  });
});

const port = process.env.PORT || 3001;
app.listen(port, () => {
  console.log(`\n🎯 Test server running on port ${port}`);
  console.log(`📡 Test URL: http://localhost:${port}/test-deploy`);
});