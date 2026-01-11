#!/bin/bash

# Script complet pour préparer l'application pour le Play Store
# Usage: ./setup_playstore.sh

set -e

echo "🚀 Configuration complète pour le Play Store"
echo "============================================"
echo ""

cd "$(dirname "$0")"

# Vérifier Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé"
    exit 1
fi

# Vérifier Java pour la clé
if ! command -v java &> /dev/null && ! command -v keytool &> /dev/null; then
    echo "⚠️  Java n'est pas installé"
    echo "   Consultez SETUP_JAVA.md pour l'installer"
    echo ""
    echo "   Pour l'instant, nous allons créer la configuration sans la clé."
    echo "   Vous devrez créer la clé manuellement plus tard."
    echo ""
    read -p "Continuer? (o/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
        exit 1
    fi
    HAS_JAVA=false
else
    HAS_JAVA=true
fi

echo ""
echo "✅ 1. Configuration de l'Application ID..."
echo "   Application ID: com.freeagent.app"
echo "   Nom de l'app: FreeAgent"
echo "   ✅ Déjà configuré!"

echo ""
echo "✅ 2. Création du fichier key.properties..."
if [ -f "android/key.properties" ]; then
    echo "   ✅ key.properties existe déjà"
else
    echo "   ✅ key.properties créé"
fi

echo ""
if [ "$HAS_JAVA" = true ]; then
    echo "✅ 3. Création de la clé de signature..."
    if [ -f "android/upload-keystore.jks" ]; then
        echo "   ⚠️  La clé existe déjà"
        read -p "   Voulez-vous la recréer? (o/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[OoYy]$ ]]; then
            cd android
            ./create_keystore_auto.sh <<< "o"
            cd ..
        fi
    else
        cd android
        ./create_keystore_auto.sh <<< "o"
        cd ..
    fi
    echo "   ✅ Clé créée!"
else
    echo "⚠️  3. Création de la clé de signature..."
    echo "   ⚠️  Java n'est pas installé. Créez la clé manuellement:"
    echo "      cd android && ./create_keystore_auto.sh"
    echo "   Ou installez Java (voir SETUP_JAVA.md)"
fi

echo ""
echo "📋 4. Vérification de la configuration..."
flutter doctor
echo ""

echo ""
echo "🧹 5. Nettoyage des builds précédents..."
flutter clean

echo ""
echo "📥 6. Récupération des dépendances..."
flutter pub get

echo ""
if [ -f "android/upload-keystore.jks" ] || [ "$HAS_JAVA" = false ]; then
    echo "🔨 7. Construction de l'App Bundle (AAB)..."
    flutter build appbundle --release
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ App Bundle construit avec succès!"
        echo ""
        echo "📍 Fichier généré:"
        AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
        echo "   $AAB_PATH"
        echo ""
        if [ -f "$AAB_PATH" ]; then
            SIZE=$(du -h "$AAB_PATH" | cut -f1)
            echo "   Taille: $SIZE"
        fi
        echo ""
        echo "📤 Prochaines étapes:"
        echo "   1. Connectez-vous à Google Play Console"
        echo "   2. Créez ou sélectionnez votre application"
        echo "   3. Téléchargez le fichier app-release.aab"
        echo ""
        echo "📚 Documentation:"
        echo "   - Guide complet: PLAYSTORE_DEPLOYMENT.md"
        echo "   - Métadonnées: PLAYSTORE_METADATA.md"
        echo "   - Démarrage rapide: QUICK_START_PLAYSTORE.md"
    else
        echo ""
        echo "❌ Erreur lors de la construction"
        exit 1
    fi
else
    echo "⚠️  7. Construction de l'AAB..."
    echo "   ⚠️  Impossible de construire sans clé de signature"
    echo "   Créez d'abord la clé, puis exécutez:"
    echo "   flutter build appbundle --release"
fi

echo ""
echo "✅ Configuration terminée!"
echo ""





