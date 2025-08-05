#!/bin/bash

# Script final pour corriger Vercel
echo "🔧 Fixing Vercel deployment..."

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

show_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

show_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Étape 1: Rebuild Flutter
show_step "Rebuilding Flutter web..."
cd freeagentapp
flutter clean
flutter build web --release
cd ..

# Étape 2: Vérifier les fichiers
show_step "Checking build files..."
if [ ! -f "freeagentapp/build/web/manifest.json" ]; then
    show_error "manifest.json not found!"
    exit 1
fi

if [ ! -f "freeagentapp/build/web/main.dart.js" ]; then
    show_error "main.dart.js not found!"
    exit 1
fi

show_success "All required files found"

# Étape 3: Créer .vercelignore correct
show_step "Creating correct .vercelignore..."
cat > .vercelignore << 'EOF'
# Ignore everything except what we need
*
!freeagentapp/build/web/
!vercel.json
!README.md
EOF

show_success ".vercelignore created"

# Étape 4: Forcer l'ajout des fichiers
show_step "Forcing git add of build files..."
git add -f freeagentapp/build/web/
git add vercel.json .vercelignore

# Étape 5: Commit et push
show_step "Committing changes..."
git commit -m "Fix Vercel deployment with proper static files" || true

# Étape 6: Déployer
show_step "Deploying to Vercel..."
vercel --prod --force

if [ $? -eq 0 ]; then
    show_success "Deployment completed!"
    echo ""
    echo -e "${GREEN}🎉 Your app should now work correctly!${NC}"
    echo ""
    echo -e "${YELLOW}🔧 Test these URLs:${NC}"
    echo "1. Main page: https://free-agen-app.vercel.app/"
    echo "2. Manifest: https://free-agen-app.vercel.app/manifest.json"
    echo "3. Main JS: https://free-agen-app.vercel.app/main.dart.js"
    echo ""
    echo -e "${BLUE}📱 If still not working, use the manual solution in VERCEL_MANUAL_SOLUTION.md${NC}"
else
    show_error "Deployment failed"
    echo ""
    echo -e "${YELLOW}🔧 Use manual solution:${NC}"
    echo "1. Go to https://vercel.com/dashboard"
    echo "2. Create new project"
    echo "3. Root Directory: freeagentapp/build/web"
    echo "4. Output Directory: ."
fi 