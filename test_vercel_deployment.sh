#!/bin/bash

# Script de test pour vérifier le déploiement Vercel
echo "🧪 Testing Vercel deployment..."

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VERCEL_URL=""

# Fonction pour afficher les résultats
show_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

show_error() {
    echo -e "${RED}❌ $1${NC}"
}

show_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Étape 1: Récupérer l'URL Vercel
echo "📋 Getting Vercel deployment URL..."

# Essayer de récupérer l'URL depuis Vercel CLI
if command -v vercel &> /dev/null; then
    VERCEL_URL=$(vercel ls --json | grep -o '"url":"[^"]*"' | head -1 | cut -d'"' -f4)
    if [ -n "$VERCEL_URL" ]; then
        show_success "Found Vercel URL: $VERCEL_URL"
    else
        show_error "Could not find Vercel URL automatically"
        echo "Please enter your Vercel URL manually:"
        read -p "Vercel URL: " VERCEL_URL
    fi
else
    show_error "Vercel CLI not found"
    echo "Please enter your Vercel URL manually:"
    read -p "Vercel URL: " VERCEL_URL
fi

if [ -z "$VERCEL_URL" ]; then
    show_error "No Vercel URL provided"
    exit 1
fi

# Étape 2: Tester les endpoints principaux
echo ""
echo "🔍 Testing main endpoints..."

# Test de la page d'accueil
echo "Testing homepage..."
if curl -s -o /dev/null -w "%{http_code}" "$VERCEL_URL" | grep -q "200"; then
    show_success "Homepage accessible"
else
    show_error "Homepage not accessible"
fi

# Test des fichiers essentiels
echo "Testing essential files..."

files=(
    "/flutter_bootstrap.js"
    "/main.dart.js"
    "/flutter.js"
    "/index.html"
    "/manifest.json"
    "/favicon.png"
)

for file in "${files[@]}"; do
    if curl -s -o /dev/null -w "%{http_code}" "$VERCEL_URL$file" | grep -q "200"; then
        show_success "$file accessible"
    else
        show_error "$file not accessible"
    fi
done

# Test des assets
echo "Testing assets..."
if curl -s -o /dev/null -w "%{http_code}" "$VERCEL_URL/assets/" | grep -q "200\|403"; then
    show_success "Assets directory accessible"
else
    show_error "Assets directory not accessible"
fi

# Test des icônes
echo "Testing icons..."
if curl -s -o /dev/null -w "%{http_code}" "$VERCEL_URL/icons/Icon-192.png" | grep -q "200"; then
    show_success "Icons accessible"
else
    show_error "Icons not accessible"
fi

# Étape 3: Test de performance
echo ""
echo "⚡ Testing performance..."

# Mesurer le temps de chargement
start_time=$(date +%s.%N)
curl -s "$VERCEL_URL" > /dev/null
end_time=$(date +%s.%N)

load_time=$(echo "$end_time - $start_time" | bc)
echo "Load time: ${load_time}s"

if (( $(echo "$load_time < 3" | bc -l) )); then
    show_success "Fast loading time"
else
    show_warning "Slow loading time"
fi

# Étape 4: Test de sécurité
echo ""
echo "🔒 Testing security headers..."

# Vérifier les headers de sécurité
headers=$(curl -s -I "$VERCEL_URL" | grep -E "(X-Frame-Options|X-Content-Type-Options|X-XSS-Protection|Strict-Transport-Security)")

if [ -n "$headers" ]; then
    show_success "Security headers present"
    echo "$headers"
else
    show_warning "No security headers detected"
fi

# Étape 5: Test de compatibilité
echo ""
echo "🌐 Testing browser compatibility..."

# Vérifier le Content-Type
content_type=$(curl -s -I "$VERCEL_URL" | grep "Content-Type" | head -1)

if echo "$content_type" | grep -q "text/html"; then
    show_success "Correct Content-Type for HTML"
else
    show_error "Incorrect Content-Type"
fi

# Étape 6: Résumé
echo ""
echo "📊 Deployment Test Summary"
echo "=========================="
echo "URL: $VERCEL_URL"
echo "Load time: ${load_time}s"
echo ""
echo "🎯 Next steps:"
echo "1. Open $VERCEL_URL in your browser"
echo "2. Test all app features"
echo "3. Check mobile responsiveness"
echo "4. Verify backend connectivity"

show_success "Test completed!" 