#!/bin/bash

echo "🚀 Déploiement rapide des corrections messages..."

# Build Flutter
cd freeagentapp
flutter build web --release
cd ..

# Déployer sur Vercel
cd freeagentapp/build/web
vercel --prod --yes
cd ../../..

echo "✅ Déploiement terminé !"
echo "🔗 URL: https://web-e0vukmg7p-marvynshes-projects.vercel.app/"
echo ""
echo "📱 Testez maintenant :"
echo "1. Connectez-vous avec un compte gratuit"
echo "2. Essayez d'envoyer un message"
echo "3. Vérifiez que le pop-up premium s'affiche" 