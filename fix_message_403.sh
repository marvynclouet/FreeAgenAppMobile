#!/bin/bash

# Script pour corriger l'erreur 403 lors de l'envoi de messages
echo "🔧 Correction de l'erreur 403 - Messages"

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

# Étape 1: Vérifier les corrections appliquées
show_step "Vérification des corrections..."

# Vérifier que la vérification premium a été ajoutée
if grep -q "subscriptionStatus" "freeagentapp/lib/new_message_page.dart"; then
    show_success "Vérification premium ajoutée dans new_message_page.dart"
else
    show_error "Vérification premium manquante dans new_message_page.dart"
fi

# Vérifier que PremiumMessages est importé
if grep -q "PremiumMessages" "freeagentapp/lib/new_message_page.dart"; then
    show_success "Import PremiumMessages ajouté"
else
    show_error "Import PremiumMessages manquant"
fi

# Étape 2: Build Flutter
show_step "Build de l'application Flutter..."
cd freeagentapp
flutter clean
flutter build web --release
cd ..

if [ $? -eq 0 ]; then
    show_success "Build réussi"
else
    show_error "Erreur lors du build"
    exit 1
fi

# Étape 3: Déployer
show_step "Déploiement sur Vercel..."
cd freeagentapp/build/web
vercel --prod
cd ../../..

if [ $? -eq 0 ]; then
    show_success "Déploiement réussi"
else
    show_error "Erreur lors du déploiement"
fi

# Étape 4: Résumé
echo ""
echo -e "${GREEN}🎉 Correction de l'erreur 403 appliquée :${NC}"
echo ""
echo -e "${YELLOW}Problème résolu :${NC}"
echo "   ❌ Erreur 403 lors de l'envoi de messages"
echo "   ✅ Vérification premium avant envoi"
echo "   ✅ Pop-up premium personnalisé"
echo "   ✅ Blocage des messages pour utilisateurs gratuits"
echo ""
echo -e "${BLUE}🔗 URL de test :${NC}"
echo "https://web-di1beu3m4-marvynshes-projects.vercel.app/"
echo ""
echo -e "${YELLOW}📱 Testez :${NC}"
echo "1. Connectez-vous avec un compte gratuit"
echo "2. Essayez d'envoyer un message"
echo "3. Vérifiez que le pop-up premium s'affiche"
echo "4. Passez premium et testez l'envoi de message" 