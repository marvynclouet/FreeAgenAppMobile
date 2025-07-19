#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Routes qui ont besoin d'une route racine
const routesToFix = [
  'profile.routes.js',
  'subscription.routes.js', 
  'store.routes.js',
  'upload.routes.js',
  'content.routes.js'
];

const routesDir = path.join(__dirname, 'backend/src/routes');

function addRootRoute(filePath, routeName) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    
    // Vérifier si la route racine existe déjà
    if (content.includes("router.get('/',")) {
      console.log(`✅ ${routeName} - Route racine déjà présente`);
      return false;
    }
    
    // Trouver la ligne après les imports
    const lines = content.split('\n');
    let insertIndex = -1;
    
    for (let i = 0; i < lines.length; i++) {
      if (lines[i].includes('module.exports = router')) {
        insertIndex = i;
        break;
      }
    }
    
    if (insertIndex === -1) {
      console.log(`❌ ${routeName} - Impossible de trouver la fin du fichier`);
      return false;
    }
    
    // Ajouter la route racine
    const rootRoute = `
// Route racine pour tester
router.get('/', (req, res) => {
  res.json({ message: '${routeName.replace('.routes.js', '')} API is working' });
});

`;
    
    lines.splice(insertIndex, 0, rootRoute);
    const newContent = lines.join('\n');
    
    fs.writeFileSync(filePath, newContent);
    console.log(`✅ ${routeName} - Route racine ajoutée`);
    return true;
    
  } catch (error) {
    console.log(`❌ ${routeName} - Erreur: ${error.message}`);
    return false;
  }
}

function main() {
  console.log('🔧 Fixing missing root routes...\n');
  
  let fixed = 0;
  let total = routesToFix.length;
  
  routesToFix.forEach(routeFile => {
    const filePath = path.join(routesDir, routeFile);
    
    if (fs.existsSync(filePath)) {
      if (addRootRoute(filePath, routeFile)) {
        fixed++;
      }
    } else {
      console.log(`❌ ${routeFile} - Fichier non trouvé`);
    }
  });
  
  console.log(`\n📊 Résumé: ${fixed}/${total} routes corrigées`);
  
  if (fixed > 0) {
    console.log('\n🚀 Redéployez le backend pour appliquer les changements:');
    console.log('   git add . && git commit -m "Add missing root routes"');
    console.log('   git push origin stable-backend-16-07');
    console.log('   railway up');
  }
}

main(); 