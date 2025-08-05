#!/bin/bash

echo "🚀 Redéploiement du backend Railway..."

# Aller dans le dossier backend
cd backend

# Vérifier que nous sommes dans le bon dossier
if [ ! -f "package.json" ]; then
    echo "❌ Erreur: package.json non trouvé. Assurez-vous d'être dans le dossier backend."
    exit 1
fi

echo "📦 Vérification des dépendances..."
npm install

echo "🔧 Vérification de la configuration..."
if [ ! -f ".env" ]; then
    echo "⚠️  Fichier .env non trouvé. Copie depuis config.example.env..."
    cp config.example.env .env
fi

echo "🚀 Déploiement sur Railway..."
railway up --detach

echo "⏳ Attente du déploiement..."
sleep 30

echo "🔍 Test de connectivité..."
curl -I https://reeagenappmobile-production.up.railway.app/

echo "✅ Redéploiement terminé!"
echo "🔗 URL: https://reeagenappmobile-production.up.railway.app/" 