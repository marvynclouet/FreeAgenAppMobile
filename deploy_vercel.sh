#!/bin/bash

# Script de déploiement Vercel pour FreeAgent App
echo "🚀 Starting Vercel deployment preparation..."

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Vérifier que Flutter est installé
echo -e "${BLUE}📱 Checking Flutter installation...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed. Please install Flutter first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Flutter is installed${NC}"

# Aller dans le dossier Flutter
cd freeagentapp

# Nettoyer les builds précédents
echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
flutter clean

# Récupérer les dépendances
echo -e "${BLUE}📦 Getting dependencies...${NC}"
flutter pub get

# Vérifier que tout compile
echo -e "${BLUE}🔍 Checking compilation...${NC}"
flutter analyze

# Construire pour le web
echo -e "${BLUE}🏗️  Building for web...${NC}"
flutter build web --release

# Vérifier que le build a réussi
if [ ! -d "build/web" ]; then
    echo -e "${RED}❌ Build failed. build/web directory not found.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful!${NC}"

# Vérifier les fichiers essentiels
echo -e "${BLUE}📋 Checking essential files...${NC}"
required_files=("build/web/index.html" "build/web/main.dart.js" "build/web/flutter_bootstrap.js")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $file exists${NC}"
    else
        echo -e "${RED}❌ $file missing${NC}"
        exit 1
    fi
done

# Retourner au dossier racine
cd ..

# Vérifier la configuration Vercel
echo -e "${BLUE}⚙️  Checking Vercel configuration...${NC}"
if [ -f "vercel.json" ]; then
    echo -e "${GREEN}✅ vercel.json exists${NC}"
else
    echo -e "${RED}❌ vercel.json missing${NC}"
    exit 1
fi

if [ -f ".vercelignore" ]; then
    echo -e "${GREEN}✅ .vercelignore exists${NC}"
else
    echo -e "${RED}❌ .vercelignore missing${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Everything is ready for Vercel deployment!${NC}"
echo -e "${YELLOW}📝 Next steps:${NC}"
echo -e "${YELLOW}   1. Commit your changes: git add . && git commit -m 'Prepare for Vercel deployment'${NC}"
echo -e "${YELLOW}   2. Push to GitHub: git push origin main${NC}"
echo -e "${YELLOW}   3. Vercel will automatically deploy from your GitHub repository${NC}"
echo -e "${YELLOW}   4. Or deploy manually: vercel --prod${NC}"

# Afficher la taille du build
echo -e "${BLUE}📊 Build size:${NC}"
du -sh freeagentapp/build/web 