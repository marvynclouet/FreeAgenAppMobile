#!/bin/bash

# Script de déploiement Vercel complet pour FreeAgent App
echo "🚀 Starting complete Vercel deployment process..."

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="freeagent-app-stable"
DOMAIN_SUFFIX="freeagent-stable"

# Fonction pour afficher les étapes
show_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

show_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

show_error() {
    echo -e "${RED}❌ $1${NC}"
}

show_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Étape 1: Vérifier les prérequis
show_step "Checking prerequisites..."

# Vérifier Vercel CLI
if ! command -v vercel &> /dev/null; then
    show_error "Vercel CLI not found. Installing..."
    npm install -g vercel
fi

# Vérifier Flutter
if ! command -v flutter &> /dev/null; then
    show_error "Flutter not found. Please install Flutter first."
    exit 1
fi

show_success "Prerequisites checked"

# Étape 2: Nettoyer et préparer
show_step "Cleaning and preparing..."

# Nettoyer les builds précédents
rm -rf web/
rm -rf freeagentapp/build/web/

# Aller dans le dossier Flutter
cd freeagentapp

# Nettoyer Flutter
flutter clean
show_success "Flutter cleaned"

# Récupérer les dépendances
flutter pub get
show_success "Dependencies installed"

# Étape 3: Build Flutter Web
show_step "Building Flutter web app..."
flutter build web --release
if [ $? -ne 0 ]; then
    show_error "Flutter build failed"
    exit 1
fi
show_success "Flutter web build completed"

# Retourner au dossier racine
cd ..

# Étape 4: Préparer les fichiers pour Vercel
show_step "Preparing files for Vercel..."

# Créer le dossier web
mkdir -p web

# Copier les fichiers du build
cp -r freeagentapp/build/web/* web/

# Créer un vercel.json optimisé
cat > vercel.json << 'EOF'
{
  "version": 2,
  "name": "freeagent-app-stable",
  "buildCommand": "echo 'Build completed'",
  "outputDirectory": "web",
  "installCommand": "echo 'Install completed'",
  "framework": null,
  "rewrites": [
    {
      "source": "/flutter_bootstrap.js",
      "destination": "/flutter_bootstrap.js"
    },
    {
      "source": "/main.dart.js",
      "destination": "/main.dart.js"
    },
    {
      "source": "/flutter.js",
      "destination": "/flutter.js"
    },
    {
      "source": "/flutter_service_worker.js",
      "destination": "/flutter_service_worker.js"
    },
    {
      "source": "/version.json",
      "destination": "/version.json"
    },
    {
      "source": "/assets/(.*)",
      "destination": "/assets/$1"
    },
    {
      "source": "/icons/(.*)",
      "destination": "/icons/$1"
    },
    {
      "source": "/canvaskit/(.*)",
      "destination": "/canvaskit/$1"
    },
    {
      "source": "/manifest.json",
      "destination": "/manifest.json"
    },
    {
      "source": "/favicon.png",
      "destination": "/favicon.png"
    },
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ],
  "headers": [
    {
      "source": "/main.dart.js",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    },
    {
      "source": "/flutter_bootstrap.js",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    },
    {
      "source": "/assets/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    }
  ]
}
EOF

# Créer un .vercelignore optimisé
cat > .vercelignore << 'EOF'
# Backend files
backend/
node_modules/
*.js
*.json
!vercel.json

# Flutter source files
freeagentapp/lib/
freeagentapp/test/
freeagentapp/android/
freeagentapp/ios/
freeagentapp/macos/
freeagentapp/windows/
freeagentapp/linux/
freeagentapp/.dart_tool/
freeagentapp/.flutter-plugins
freeagentapp/.flutter-plugins-dependencies
freeagentapp/pubspec.yaml
freeagentapp/pubspec.lock

# IDE files
.idea/
.vscode/
*.iml

# OS files
.DS_Store
Thumbs.db

# Git
.git/
.gitignore

# Test files
test_*.js
fix_*.js
*.md
!README.md

# Railway files
.railwayignore
railway.json
EOF

show_success "Files prepared for Vercel"

# Étape 5: Vérifier les fichiers essentiels
show_step "Checking essential files..."

required_files=("web/index.html" "web/main.dart.js" "web/flutter_bootstrap.js")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        show_success "$file exists"
    else
        show_error "$file missing"
        exit 1
    fi
done

# Étape 6: Déployer sur Vercel
show_step "Deploying to Vercel..."

# Vérifier si on est connecté à Vercel
if ! vercel whoami &> /dev/null; then
    show_warning "Not logged in to Vercel. Please login first:"
    echo "vercel login"
    exit 1
fi

# Déployer
echo "Deploying to Vercel..."
vercel --prod --yes

if [ $? -eq 0 ]; then
    show_success "Deployment completed successfully!"
    
    # Afficher l'URL
    echo ""
    echo -e "${GREEN}🎉 Your app is now deployed!${NC}"
    echo -e "${BLUE}📱 Check your Vercel dashboard for the URL${NC}"
    echo ""
    echo -e "${YELLOW}📊 Build size:${NC}"
    du -sh web/
    
else
    show_error "Deployment failed"
    echo ""
    echo -e "${YELLOW}🔧 Troubleshooting:${NC}"
    echo "1. Check Vercel logs: vercel logs"
    echo "2. Try manual deployment: vercel --prod"
    echo "3. Check project settings in Vercel dashboard"
    exit 1
fi

# Étape 7: Nettoyer
show_step "Cleaning up..."

# Supprimer le dossier web temporaire
rm -rf web/

show_success "Cleanup completed"

echo ""
echo -e "${GREEN}🎯 Deployment process completed!${NC}"
echo -e "${BLUE}📝 Next time, just run: ./deploy_vercel_complete.sh${NC}" 