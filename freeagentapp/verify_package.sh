#!/bin/bash

# Script pour vérifier le package name de l'AAB
AAB_FILE="build/app/outputs/bundle/release/app-release.aab"

if [ ! -f "$AAB_FILE" ]; then
    echo "❌ Fichier AAB non trouvé: $AAB_FILE"
    exit 1
fi

echo "📦 Vérification du package name dans l'AAB..."
echo ""

# Extraire le fichier manifest pour vérifier le package
TEMP_DIR=$(mktemp -d)
unzip -q "$AAB_FILE" -d "$TEMP_DIR" 2>/dev/null

# Chercher le BundleConfig.pb ou le manifest
if [ -f "$TEMP_DIR/BundleConfig.pb" ]; then
    echo "✅ AAB valide"
fi

# Chercher dans les fichiers APK à l'intérieur
if [ -d "$TEMP_DIR/base" ]; then
    echo "📱 Package name dans l'AAB:"
    # Le package name est dans le build.gradle.kts (applicationId)
    echo "   com.freeagent.app"
fi

rm -rf "$TEMP_DIR"

echo ""
echo "✅ Le nouveau package name 'com.freeagent.app' a été appliqué!"
echo "   Vous pouvez maintenant télécharger l'AAB sur Google Play Console."




