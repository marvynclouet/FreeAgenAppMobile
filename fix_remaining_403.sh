#!/bin/bash

echo "🔧 Correction rapide des erreurs 403 restantes..."

# Pages à corriger
PAGES=(
    "lawyers_page.dart"
    "dietitians_page.dart"
    "matching_page.dart"
    "handibasket_page.dart"
    "coaches_page.dart"
)

for page in "${PAGES[@]}"; do
    echo "📝 Correction de $page..."
    
    # Ajouter les imports si ils n'existent pas
    if ! grep -q "subscription_service.dart" "freeagentapp/lib/$page"; then
        # Trouver la ligne avec les imports de services
        import_line=$(grep -n "import.*service" "freeagentapp/lib/$page" | tail -1 | cut -d: -f1)
        if [ ! -z "$import_line" ]; then
            sed -i '' "${import_line}a\\
import 'services/subscription_service.dart';\\
import 'utils/premium_messages.dart';" "freeagentapp/lib/$page"
        fi
    fi
    
    # Ajouter la vérification premium avant createConversation
    sed -i '' 's/final result = await.*createConversation(/\
    \/\/ Vérifier le statut premium AVANT d\'envoyer le message\
    try {\
      final subscriptionService = SubscriptionService();\
      final subscriptionStatus = await subscriptionService.getSubscriptionStatus();\
      final isFreemium = subscriptionStatus == null || subscriptionStatus.type == '\''free'\'';\
\
      if (isFreemium) {\
        PremiumMessages.showPremiumDialog(context, '\''player'\'', '\''message'\'',\
            onUpgrade: () {\
          Navigator.pushNamed(context, '\''\/premium'\'');\
        });\
        return;\
      }\
    } catch (e) {\
      PremiumMessages.showPremiumDialog(context, '\''player'\'', '\''message'\'',\
          onUpgrade: () {\
        Navigator.pushNamed(context, '\''\/premium'\'');\
      });\
      return;\
    }\
\
    final result = await createConversation(/' "freeagentapp/lib/$page"
    
    echo "✅ $page corrigé"
done

echo "🚀 Build et déploiement..."
cd freeagentapp
flutter build web --release
cd ..

cd freeagentapp/build/web
vercel --prod --yes
cd ../../..

echo "✅ Déploiement terminé !"
echo "🔗 URL: https://web-pl5wdga3w-marvynshes-projects.vercel.app/" 