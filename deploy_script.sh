#!/bin/bash

echo "🚀 Script de déploiement FreeAgentApp"
echo "======================================"

# Vérifier qu'on est dans le bon répertoire
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Erreur: pubspec.yaml non trouvé. Assurez-vous d'être dans le répertoire freeagentapp/"
    exit 1
fi

echo "✅ Répertoire Flutter détecté"

# Nettoyer le cache Flutter
echo "🧹 Nettoyage du cache Flutter..."
flutter clean
flutter pub get

# Vérifier les modifications dans le code
echo "🔍 Vérification des modifications..."

# Vérifier le bouton vidéo dans profile_page.dart
if grep -q "Voir la vidéo" lib/profile_page.dart; then
    echo "✅ Bouton vidéo trouvé dans profile_page.dart"
else
    echo "❌ Bouton vidéo manquant dans profile_page.dart"
fi

# Vérifier les améliorations d'images dans home_page.dart
if grep -q "Positioned.fill" lib/home_page.dart; then
    echo "✅ Améliorations d'images trouvées dans home_page.dart"
else
    echo "❌ Améliorations d'images manquantes dans home_page.dart"
fi

# Build Flutter
echo "🔨 Build de l'application Flutter..."
flutter build web --release

if [ $? -eq 0 ]; then
    echo "✅ Build réussi"
else
    echo "❌ Erreur lors du build"
    exit 1
fi

# Déployer sur Vercel
echo "🚀 Déploiement sur Vercel..."
vercel --prod --force

if [ $? -eq 0 ]; then
    echo "✅ Déploiement réussi!"
    echo "🌐 Vérifiez votre application sur Vercel"
else
    echo "❌ Erreur lors du déploiement"
    exit 1
fi

echo "🎉 Script terminé!"
