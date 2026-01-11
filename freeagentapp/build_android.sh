#!/bin/bash

# Script pour builder l'application Android avec la bonne configuration Java

set -e

echo "🔧 Configuration de Java..."
export JAVA_HOME=$(brew --prefix openjdk@17)/libexec/openjdk.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"

echo "✅ Java configuré: $JAVA_HOME"
java -version | head -3

echo ""
echo "📦 Build de l'application Android..."
flutter build appbundle --release

echo ""
if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    ls -lh build/app/outputs/bundle/release/app-release.aab
    echo ""
    echo "✅ AAB généré avec succès !"
    echo "📁 Fichier: $(pwd)/build/app/outputs/bundle/release/app-release.aab"
else
    echo "❌ Erreur: Fichier AAB non trouvé"
    exit 1
fi



