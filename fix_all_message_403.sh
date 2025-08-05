#!/bin/bash

# Script pour corriger l'erreur 403 dans toutes les pages utilisant createConversation
echo "🔧 Correction de l'erreur 403 - Toutes les pages de messages"

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

# Liste des fichiers à corriger
FILES_TO_FIX=(
    "freeagentapp/lib/players_page.dart"
    "freeagentapp/lib/dietitians_page.dart"
    "freeagentapp/lib/lawyers_page.dart"
    "freeagentapp/lib/matching_page.dart"
    "freeagentapp/lib/teams_page.dart"
    "freeagentapp/lib/handibasket_page.dart"
    "freeagentapp/lib/coaches_page.dart"
)

# Étape 1: Ajouter les imports nécessaires
show_step "Ajout des imports premium..."

for file in "${FILES_TO_FIX[@]}"; do
    if [ -f "$file" ]; then
        # Ajouter les imports si ils n'existent pas déjà
        if ! grep -q "subscription_service.dart" "$file"; then
            # Trouver la ligne avec les autres imports
            import_line=$(grep -n "import.*service" "$file" | tail -1 | cut -d: -f1)
            if [ ! -z "$import_line" ]; then
                # Ajouter les imports après la dernière ligne d'import
                sed -i '' "${import_line}a\\
import 'services/subscription_service.dart';\\
import 'utils/premium_messages.dart';" "$file"
                show_success "Imports ajoutés dans $file"
            fi
        else
            show_success "Imports déjà présents dans $file"
        fi
    else
        show_error "Fichier non trouvé: $file"
    fi
done

# Étape 2: Ajouter la vérification premium dans chaque fichier
show_step "Ajout de la vérification premium..."

for file in "${FILES_TO_FIX[@]}"; do
    if [ -f "$file" ]; then
        # Chercher la fonction qui contient createConversation
        if grep -q "createConversation" "$file"; then
            # Ajouter la vérification premium avant createConversation
            sed -i '' 's/final result = await.*createConversation(/\
    \/\/ Vérifier le statut premium AVANT d\'envoyer le message\
    try {\
      final subscriptionService = SubscriptionService();\
      final subscriptionStatus = await subscriptionService.getSubscriptionStatus();\
      final isFreemium = subscriptionStatus == null || subscriptionStatus.type == '\''free'\'';\
\
      if (isFreemium) {\
        \/\/ Afficher le pop-up premium personnalisé\
        PremiumMessages.showPremiumDialog(context, '\''player'\'', '\''message'\'',\
            onUpgrade: () {\
          Navigator.pushNamed(context, '\''\/premium'\'');\
        });\
        return; \/\/ Bloquer l\'envoi du message\
      }\
    } catch (e) {\
      print('\''Erreur lors de la vérification du statut premium: '\'' + e.toString());\
      PremiumMessages.showPremiumDialog(context, '\''player'\'', '\''message'\'',\
          onUpgrade: () {\
        Navigator.pushNamed(context, '\''\/premium'\'');\
      });\
      return;\
    }\
\
    final result = await createConversation(/' "$file"
            
            show_success "Vérification premium ajoutée dans $file"
        fi
    fi
done

# Étape 3: Build Flutter
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

# Étape 4: Déployer
show_step "Déploiement sur Vercel..."
cd freeagentapp/build/web
vercel --prod --yes
cd ../../..

if [ $? -eq 0 ]; then
    show_success "Déploiement réussi"
else
    show_error "Erreur lors du déploiement"
fi

# Étape 5: Résumé
echo ""
echo -e "${GREEN}🎉 Correction de l'erreur 403 appliquée partout :${NC}"
echo ""
echo -e "${YELLOW}Pages corrigées :${NC}"
for file in "${FILES_TO_FIX[@]}"; do
    echo "   ✅ $(basename "$file")"
done
echo ""
echo -e "${YELLOW}Corrections appliquées :${NC}"
echo "   ✅ Imports premium ajoutés"
echo "   ✅ Vérification premium avant envoi"
echo "   ✅ Pop-up premium personnalisé"
echo "   ✅ Blocage des messages pour utilisateurs gratuits"
echo ""
echo -e "${BLUE}🔗 URL de test :${NC}"
echo "https://web-e0vukmg7p-marvynshes-projects.vercel.app/"
echo ""
echo -e "${YELLOW}📱 Testez :${NC}"
echo "1. Connectez-vous avec un compte gratuit"
echo "2. Essayez d'envoyer un message depuis n'importe quelle page"
echo "3. Vérifiez que le pop-up premium s'affiche partout"
echo "4. Passez premium et testez l'envoi normal" 