#!/bin/bash

# Script pour construire l'App Bundle (AAB) pour le Play Store
# Usage: ./build_release.sh

echo "📦 Construction de l'App Bundle pour le Play Store"
echo "=================================================="
echo ""

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

# Vérifier que la clé existe
if [ ! -f "android/upload-keystore.jks" ]; then
    echo "⚠️  La clé de signature n'existe pas!"
    echo ""
    echo "Créez-la d'abord avec:"
    echo "  cd android && ./create_keystore.sh"
    echo ""
    read -p "Continuer sans clé? (l'application sera signée avec la clé debug) (o/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
        echo "❌ Opération annulée"
        exit 1
    fi
fi

# Vérifier que key.properties existe
if [ ! -f "android/key.properties" ]; then
    echo "⚠️  Le fichier key.properties n'existe pas!"
    echo ""
    echo "Créez-le en copiant key.properties.template et en remplissant vos informations"
    echo ""
    read -p "Continuer sans key.properties? (o/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
        echo "❌ Opération annulée"
        exit 1
    fi
fi

echo "🔍 Vérification de la configuration Flutter..."
flutter doctor
echo ""

echo "🧹 Nettoyage des builds précédents..."
flutter clean
echo ""

echo "📥 Récupération des dépendances..."
flutter pub get
echo ""

echo "🔨 Construction de l'App Bundle (AAB)..."
flutter build appbundle --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ App Bundle construit avec succès!"
    echo ""
    echo "📍 Fichier généré:"
    echo "   build/app/outputs/bundle/release/app-release.aab"
    echo ""
    echo "📤 Prochaines étapes:"
    echo "   1. Connectez-vous à Google Play Console"
    echo "   2. Créez ou sélectionnez votre application"
    echo "   3. Allez dans Production > Créer une version"
    echo "   4. Téléchargez le fichier app-release.aab"
    echo ""
    echo "📚 Consultez PLAYSTORE_DEPLOYMENT.md pour plus de détails"
else
    echo ""
    echo "❌ Erreur lors de la construction"
    exit 1
fi





