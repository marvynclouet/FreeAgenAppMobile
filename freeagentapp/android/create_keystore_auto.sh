#!/bin/bash

# Script automatisé pour créer une clé de signature
# Usage: ./create_keystore_auto.sh

echo "🔐 Création automatisée de la clé de signature"
echo "================================================"
echo ""

# Variables par défaut (peuvent être surchargées par variables d'environnement)
KEYSTORE_PASSWORD="${KEYSTORE_PASSWORD:-FreeAgent2024!Secure}"
KEY_PASSWORD="${KEY_PASSWORD:-${KEYSTORE_PASSWORD}}"
ALIAS="${ALIAS:-freeagentapp}"
KEYSTORE_FILE="${KEYSTORE_FILE:-upload-keystore.jks}"

echo "⚠️  ATTENTION: Ce script va créer une clé avec des mots de passe par défaut."
echo "   Pour la production, changez les mots de passe!"
echo ""
echo "Configuration:"
echo "  - Keystore: $KEYSTORE_FILE"
echo "  - Alias: $ALIAS"
echo "  - Mot de passe: [configuré]"
echo ""
read -p "Voulez-vous utiliser les mots de passe par défaut? (o/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
    echo ""
    echo "Entrez vos informations manuellement:"
    read -sp "Mot de passe du keystore: " KEYSTORE_PASSWORD
    echo
    read -sp "Mot de passe de la clé (appuyez Entrée pour utiliser le même): " KEY_PASSWORD
    echo
    if [ -z "$KEY_PASSWORD" ]; then
        KEY_PASSWORD="$KEYSTORE_PASSWORD"
    fi
fi

# Vérifier si la clé existe déjà
if [ -f "$KEYSTORE_FILE" ]; then
    echo ""
    echo "⚠️  La clé $KEYSTORE_FILE existe déjà!"
    read -p "Voulez-vous la remplacer? (o/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
        echo "❌ Opération annulée"
        exit 1
    fi
    rm "$KEYSTORE_FILE"
fi

echo ""
echo "📝 Création de la clé avec les informations suivantes:"
echo "   - CN: FreeAgent App"
echo "   - OU: FreeAgent"
echo "   - O: FreeAgent"
echo "   - L: France"
echo "   - ST: France"
echo "   - C: FR"
echo ""
echo "⏳ Génération de la clé..."

# Créer la clé de manière non-interactive
keytool -genkey -v \
    -keystore "$KEYSTORE_FILE" \
    -alias "$ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass "$KEYSTORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "CN=FreeAgent App, OU=FreeAgent, O=FreeAgent, L=Paris, ST=France, C=FR"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Clé de signature créée avec succès!"
    echo ""
    echo "📋 Création du fichier key.properties..."
    
    # Créer le fichier key.properties
    cat > key.properties << EOF
storePassword=$KEYSTORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$ALIAS
storeFile=../$KEYSTORE_FILE
EOF
    
    echo "✅ Fichier key.properties créé!"
    echo ""
    echo "📝 IMPORTANT: Notez ces informations dans un endroit sûr:"
    echo "   - Mot de passe keystore: $KEYSTORE_PASSWORD"
    echo "   - Mot de passe clé: $KEY_PASSWORD"
    echo "   - Alias: $ALIAS"
    echo "   - Fichier: $KEYSTORE_FILE"
    echo ""
    echo "✅ Configuration terminée! Vous pouvez maintenant construire l'AAB."
else
    echo ""
    echo "❌ Erreur lors de la création de la clé"
    exit 1
fi





