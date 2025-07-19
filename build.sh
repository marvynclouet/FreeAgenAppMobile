#!/bin/bash

# Script de build pour Vercel
echo "🚀 Starting Vercel build process..."

# Vérifier si le build Flutter existe
if [ ! -d "freeagentapp/build/web" ]; then
    echo "❌ Flutter web build not found. Please run 'cd freeagentapp && flutter build web --release' first."
    exit 1
fi

# Créer le dossier de sortie si nécessaire
mkdir -p web

# Copier les fichiers du build Flutter vers le dossier web
echo "📁 Copying Flutter web build files..."
cp -r freeagentapp/build/web/* web/

echo "✅ Build completed successfully!"
echo "📊 Files in web directory:"
ls -la web/ 