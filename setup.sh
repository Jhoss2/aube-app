#!/bin/bash

echo "🚀 U-AUBEN INVENTORY APP - Installation"
echo "========================================"
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js n'est pas installé. Veuillez installer Node.js 20.x"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
    echo "⚠️  Node.js version trop ancienne. Version 20+ recommandée."
fi

echo "✅ Node.js détecté: $(node -v)"

# Check Java
if ! command -v java &> /dev/null; then
    echo "❌ Java n'est pas installé. Veuillez installer Java 21"
    exit 1
fi

echo "✅ Java détecté: $(java -version 2>&1 | head -n 1)"

# Install dependencies
echo ""
echo "📦 Installation des dépendances..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de l'installation des dépendances"
    exit 1
fi

echo "✅ Dépendances installées"

# Download assets
echo ""
echo "⬇️  Téléchargement des assets locaux..."
npm run copy-assets

if [ $? -ne 0 ]; then
    echo "⚠️  Erreur lors du téléchargement des assets (peut nécessiter une connexion Internet)"
    echo "   Vous pouvez continuer mais l'app aura besoin de CDN"
fi

# Sync Capacitor
echo ""
echo "🔄 Synchronisation Capacitor..."
npx cap sync android

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de la synchronisation Capacitor"
    exit 1
fi

echo "✅ Synchronisation terminée"

echo ""
echo "============================================"
echo "✅ Installation terminée avec succès !"
echo ""
echo "Prochaines étapes :"
echo "1. Ouvrir dans Android Studio : npm run open:android"
echo "2. Ou builder directement : cd android && ./gradlew assembleRelease"
echo ""
echo "L'APK sera dans : android/app/build/outputs/apk/release/"
echo "============================================"

