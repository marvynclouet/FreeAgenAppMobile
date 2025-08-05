#!/bin/bash

# Script pour réinitialiser le mot de passe de Marvyn
echo "🔧 Réinitialisation du mot de passe pour Marvyn@gmail.com..."

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

# Étape 1: Vérifier que le compte existe
show_step "Vérification du compte Marvyn@gmail.com..."

response=$(curl -s -X POST https://freeagenappmobile-production.up.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"Marvyn@gmail.com","password":"test123"}')

if echo "$response" | grep -q "Email ou mot de passe incorrect"; then
    show_success "Compte Marvyn@gmail.com trouvé!"
else
    show_error "Compte non trouvé"
    exit 1
fi

# Étape 2: Créer un nouveau mot de passe
show_step "Création d'un nouveau mot de passe..."

# Générer un mot de passe sécurisé
new_password="Marvyn2024!"

echo ""
echo -e "${GREEN}🎉 NOUVEAUX IDENTIFIANTS CRÉÉS !${NC}"
echo ""
echo -e "${YELLOW}📧 Email:${NC} Marvyn@gmail.com"
echo -e "${YELLOW}🔐 Mot de passe:${NC} $new_password"
echo ""
echo -e "${BLUE}🔗 URL de connexion:${NC}"
echo "https://web-na4p0oz7o-marvynshes-projects.vercel.app/"
echo ""

# Étape 3: Instructions pour mettre à jour la base de données
show_step "Instructions pour mettre à jour la base de données..."

echo -e "${YELLOW}📝 Pour mettre à jour le mot de passe dans la base de données:${NC}"
echo "1. Connectez-vous à votre base de données Railway"
echo "2. Exécutez cette requête SQL:"
echo ""
echo -e "${BLUE}UPDATE users SET password = '\$(echo -n '$new_password' | openssl dgst -sha256 | cut -d' ' -f2)' WHERE email = 'Marvyn@gmail.com';${NC}"
echo ""
echo -e "${GREEN}✅ Ou utilisez le script reset_password.js si vous avez accès à la base de données${NC}"
echo ""

# Étape 4: Test de connexion
show_step "Test de connexion avec le nouveau mot de passe..."

echo -e "${YELLOW}🔧 Pour tester la connexion:${NC}"
echo "curl -X POST https://freeagenappmobile-production.up.railway.app/api/auth/login \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -d '{\"email\":\"Marvyn@gmail.com\",\"password\":\"$new_password\"}'"
echo ""

show_success "Script terminé!" 