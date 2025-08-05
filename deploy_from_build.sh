#!/bin/bash

# Déploiement depuis le répertoire build
echo "🚀 Deploying from build directory..."

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

# Étape 1: Vérifier que le build existe
show_step "Checking build directory..."
if [ ! -d "freeagentapp/build/web" ]; then
    show_error "Build directory not found. Building..."
    cd freeagentapp
    flutter build web --release
    cd ..
fi

show_success "Build directory ready"

# Étape 2: Aller dans le répertoire build
show_step "Moving to build directory..."
cd freeagentapp/build/web

# Étape 3: Déployer depuis ce répertoire
show_step "Deploying from build directory..."
vercel --prod

if [ $? -eq 0 ]; then
    show_success "Deployment successful!"
    echo ""
    echo -e "${GREEN}🎉 Your app is now deployed!${NC}"
    echo ""
    echo -e "${YELLOW}🔧 Test these URLs:${NC}"
    echo "1. Main page: Check the URL above"
    echo "2. Manifest: [URL]/manifest.json"
    echo "3. Main JS: [URL]/main.dart.js"
else
    show_error "Deployment failed"
    echo ""
    echo -e "${YELLOW}🔧 Alternative: Manual upload${NC}"
    echo "1. Go to https://vercel.com/dashboard"
    echo "2. New Project → Upload"
    echo "3. Select this directory: $(pwd)"
fi

# Retourner au répertoire racine
cd ../../.. 