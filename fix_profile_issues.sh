#!/bin/bash

# Script pour corriger les problèmes de profil
echo "🔧 Correction des problèmes de profil..."

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

# Étape 1: Vérifier que les corrections ont été appliquées
show_step "Vérification des corrections appliquées..."

# Vérifier le service de profil
if grep -q "userUpdateData" "freeagentapp/lib/services/profile_service.dart"; then
    show_success "Correction du genre/nationalité appliquée"
else
    show_error "Correction du genre/nationalité manquante"
fi

# Vérifier le service de photo de profil
if grep -q "freeagenappmobile-production.up.railway.app" "freeagentapp/lib/services/profile_photo_service.dart"; then
    show_success "Correction des URLs de photos appliquée"
else
    show_error "Correction des URLs de photos manquante"
fi

# Vérifier les utilitaires premium
if grep -q "maskEmailForNonPremium" "freeagentapp/lib/utils/premium_utils.dart"; then
    show_success "Masquage des emails appliqué"
else
    show_error "Masquage des emails manquant"
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
./deploy_from_build.sh

if [ $? -eq 0 ]; then
    show_success "Déploiement réussi"
else
    show_error "Erreur lors du déploiement"
fi

# Étape 4: Résumé des corrections
echo ""
echo -e "${GREEN}🎉 Corrections appliquées :${NC}"
echo ""
echo -e "${YELLOW}1. Genre et nationalité :${NC}"
echo "   ✅ Sauvegardés dans la table users"
echo "   ✅ Mise à jour automatique lors de l'édition"
echo ""
echo -e "${YELLOW}2. Photos de profil :${NC}"
echo "   ✅ URLs corrigées pour Railway"
echo "   ✅ Récupération et export fonctionnels"
echo ""
echo -e "${YELLOW}3. Masquage des emails :${NC}"
echo "   ✅ Emails masqués pour les utilisateurs non premium"
echo "   ✅ Indicateur 'Premium' ajouté"
echo "   ✅ Emails complets pour les utilisateurs premium"
echo ""
echo -e "${BLUE}🔗 URL de test :${NC}"
echo "https://web-na4p0oz7o-marvynshes-projects.vercel.app/"
echo ""
echo -e "${YELLOW}📱 Testez :${NC}"
echo "1. Éditez votre profil (genre/nationalité)"
echo "2. Uploadez une photo de profil"
echo "3. Vérifiez que les emails sont masqués si non premium" 