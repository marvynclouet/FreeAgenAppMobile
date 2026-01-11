#!/bin/bash

# Script pour créer une clé de signature pour l'application FreeAgent
# Usage: ./create_keystore.sh

echo "🔐 Création de la clé de signature pour FreeAgent"
echo "=================================================="
echo ""

# Vérifier si la clé existe déjà
if [ -f "upload-keystore.jks" ]; then
    echo "⚠️  La clé upload-keystore.jks existe déjà!"
    read -p "Voulez-vous la remplacer? (o/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
        echo "❌ Opération annulée"
        exit 1
    fi
    rm upload-keystore.jks
fi

echo "📝 Vous allez être invité à entrer les informations suivantes:"
echo "   - Mot de passe du keystore (gardez-le en sécurité!)"
echo "   - Mot de passe de la clé (peut être le même)"
echo "   - Vos informations personnelles/organisationnelles"
echo ""
echo "⚠️  IMPORTANT: Notez ces informations dans un endroit sûr!"
echo "   Vous en aurez besoin pour toutes les mises à jour futures."
echo ""
read -p "Appuyez sur Entrée pour continuer..."

keytool -genkey -v \
    -keystore upload-keystore.jks \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias freeagentapp

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Clé de signature créée avec succès!"
    echo ""
    echo "📋 Prochaines étapes:"
    echo "   1. Créez le fichier key.properties avec vos informations"
    echo "   2. Ajoutez key.properties au .gitignore"
    echo "   3. Construisez l'AAB avec: flutter build appbundle --release"
else
    echo ""
    echo "❌ Erreur lors de la création de la clé"
    exit 1
fi





