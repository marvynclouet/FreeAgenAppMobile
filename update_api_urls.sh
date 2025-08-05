#!/bin/bash

# Script pour mettre à jour toutes les URLs API
echo "🔧 Updating API URLs to use production configuration..."

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

# Étape 1: Vérifier que le fichier config.dart existe
show_step "Checking config.dart..."
if [ ! -f "freeagentapp/lib/services/config.dart" ]; then
    show_error "config.dart not found!"
    exit 1
fi
show_success "config.dart found"

# Étape 2: Mettre à jour les services
show_step "Updating service files..."

# Liste des fichiers à mettre à jour
services=(
    "freeagentapp/lib/services/profile_service.dart"
    "freeagentapp/lib/services/opportunity_service.dart"
    "freeagentapp/lib/services/payment_service.dart"
    "freeagentapp/lib/services/subscription_service.dart"
    "freeagentapp/lib/services/matching_service.dart"
    "freeagentapp/lib/services/content_service.dart"
    "freeagentapp/lib/services/profile_photo_service.dart"
)

# Mettre à jour chaque service
for service in "${services[@]}"; do
    if [ -f "$service" ]; then
        show_step "Updating $service..."
        
        # Ajouter l'import config.dart si pas déjà présent
        if ! grep -q "import 'config.dart';" "$service"; then
            # Trouver la ligne après les imports existants
            sed -i '' '/^import/a\
import '\''config.dart'\'';
' "$service"
        fi
        
        # Remplacer les URLs hardcodées
        sed -i '' "s|static const String baseUrl = 'http://192.168.1.43:3000/api'|static String get baseUrl => ApiConfig.baseUrl|g" "$service"
        sed -i '' "s|static const String _baseUrl = 'http://192.168.1.43:3000/api'|static String get _baseUrl => ApiConfig.baseUrl|g" "$service"
        sed -i '' "s|static const String baseUrl = 'http://localhost:3000/api'|static String get baseUrl => ApiConfig.baseUrl|g" "$service"
        sed -i '' "s|static const String _baseUrl = 'http://localhost:3000/api'|static String get _baseUrl => ApiConfig.baseUrl|g" "$service"
        
        # Mettre à jour les URLs d'upload
        sed -i '' "s|static const String baseUrl = 'http://localhost:3000/api/upload'|static String get baseUrl => ApiConfig.uploadUrl|g" "$service"
        
        show_success "Updated $service"
    else
        show_error "File not found: $service"
    fi
done

# Étape 3: Rebuild Flutter
show_step "Rebuilding Flutter web..."
cd freeagentapp
flutter clean
flutter build web --release
cd ..

if [ $? -eq 0 ]; then
    show_success "Flutter build completed"
else
    show_error "Flutter build failed"
    exit 1
fi

# Étape 4: Déployer
show_step "Deploying to Vercel..."
./deploy_from_build.sh

show_success "All services updated and deployed!"
echo ""
echo -e "${GREEN}🎉 Your app now uses the production Railway backend!${NC}"
echo ""
echo -e "${YELLOW}🔧 Test the login functionality:${NC}"
echo "1. Go to: https://web-2d02evwvh-marvynshes-projects.vercel.app/"
echo "2. Try to login with your credentials"
echo "3. Check browser console for any errors" 