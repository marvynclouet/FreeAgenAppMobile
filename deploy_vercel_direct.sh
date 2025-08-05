#!/bin/bash

# Script de déploiement direct Vercel
echo "🚀 Deploying directly to Vercel..."

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

show_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

show_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Étape 1: S'assurer que le build est prêt
show_step "Ensuring Flutter build is ready..."

if [ ! -d "freeagentapp/build/web" ]; then
    show_error "Flutter web build not found. Building..."
    cd freeagentapp
    flutter build web --release
    cd ..
fi

show_success "Build ready"

# Étape 2: Créer un vercel.json minimal
show_step "Creating minimal vercel.json..."

cat > vercel.json << 'EOF'
{
  "version": 2,
  "buildCommand": "echo 'Build completed'",
  "outputDirectory": "freeagentapp/build/web",
  "installCommand": "echo 'Install completed'",
  "framework": null,
  "functions": {},
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
EOF

show_success "vercel.json created"

# Étape 3: Créer un .vercelignore minimal
show_step "Creating minimal .vercelignore..."

cat > .vercelignore << 'EOF'
# Exclude everything except what's needed
*
!freeagentapp/build/web/
!vercel.json
!README.md
EOF

show_success ".vercelignore created"

# Étape 4: Déployer
show_step "Deploying to Vercel..."

# Forcer un nouveau déploiement
vercel --prod --force

if [ $? -eq 0 ]; then
    show_success "Deployment completed!"
    
    # Afficher l'URL
    echo ""
    echo -e "${GREEN}🎉 Your app is deployed!${NC}"
    echo -e "${BLUE}📱 Check the URL above${NC}"
    
    # Instructions pour tester
    echo ""
    echo -e "${YELLOW}🔧 To test:${NC}"
    echo "1. Open the URL in your browser"
    echo "2. Check browser console for errors"
    echo "3. If manifest.json fails, it's usually not critical"
    
else
    show_error "Deployment failed"
    echo ""
    echo -e "${YELLOW}🔧 Alternative solution:${NC}"
    echo "1. Go to https://vercel.com/dashboard"
    echo "2. Create a new project"
    echo "3. Upload the freeagentapp/build/web folder directly"
fi 