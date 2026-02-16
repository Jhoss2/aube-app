# 🚀 Guide de Déploiement Rapide - U-AUBEN INVENTORY APP

## 📦 Méthode 1 : Build Local (Recommandé)

### Prérequis
✅ Node.js 20+
✅ Java 21
✅ Android SDK 35
✅ Android Studio (optionnel mais recommandé)

### Étapes

```bash
# 1. Cloner le projet
git clone <repo-url>
cd u-auben-inventory-app

# 2. Exécuter le script d'installation
chmod +x setup.sh
./setup.sh

# 3. Ouvrir dans Android Studio
npm run open:android

# 4. Dans Android Studio :
#    - Build → Generate Signed Bundle / APK
#    - Sélectionner APK
#    - Choisir "release"
#    - Signer avec votre keystore

# Ou en ligne de commande :
cd android
./gradlew assembleRelease

# APK généré ici :
# android/app/build/outputs/apk/release/app-release-unsigned.apk
```

### Signature de l'APK

```bash
# Créer un keystore (première fois seulement)
keytool -genkey -v -keystore u-auben-release.keystore \
  -alias u-auben -keyalg RSA -keysize 2048 -validity 10000

# Signer l'APK
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
  -keystore u-auben-release.keystore \
  android/app/build/outputs/apk/release/app-release-unsigned.apk u-auben

# Zipalign
zipalign -v 4 android/app/build/outputs/apk/release/app-release-unsigned.apk \
  u-auben-inventory-v1.0.0.apk
```

## ☁️ Méthode 2 : Codemagic CI/CD

### Configuration

1. **Créer un compte sur Codemagic**
   - Visitez https://codemagic.io
   - Connectez votre repo GitHub/GitLab/Bitbucket

2. **Configurer les variables d'environnement**
   - Dans Codemagic Dashboard → Settings → Environment variables
   - Ajouter :
     - `KEYSTORE_PATH` : Chemin vers votre keystore
     - `KEYSTORE_PASSWORD` : Mot de passe du keystore
     - `KEY_ALIAS` : Alias de la clé
     - `KEY_PASSWORD` : Mot de passe de la clé

3. **Uploader le keystore**
   - Team settings → Code signing identities
   - Upload votre fichier .keystore

4. **Lancer le build**
   - Push vers `main` ou `master` → Build automatique
   - Ou : Dashboard → Start new build

### Fichier codemagic.yaml

Le fichier est déjà configuré dans le projet. Il :
- ✅ Installe les dépendances
- ✅ Télécharge les assets locaux
- ✅ Synchronise Capacitor
- ✅ Build l'APK signé
- ✅ Envoie par email

### Récupérer l'APK

1. Dashboard → Votre build → Artifacts
2. Télécharger `app-release.apk`
3. Installer sur tablette via ADB ou transfert USB

## 📱 Installation sur Tablette

### Via ADB (Android Debug Bridge)

```bash
# 1. Activer le mode développeur sur la tablette
# Paramètres → À propos de la tablette → Taper 7x sur "Numéro de build"

# 2. Activer le débogage USB
# Paramètres → Options de développement → Débogage USB

# 3. Connecter la tablette en USB

# 4. Vérifier la connexion
adb devices

# 5. Installer l'APK
adb install -r u-auben-inventory-v1.0.0.apk

# Option : Installer et lancer directement
adb install -r u-auben-inventory-v1.0.0.apk && \
adb shell am start -n com.uauben.inventory/.MainActivity
```

### Via Transfert de Fichier

1. Connecter la tablette en USB
2. Copier l'APK dans `Downloads/`
3. Sur la tablette : Fichiers → Downloads → Taper sur l'APK
4. Autoriser l'installation de sources inconnues si demandé
5. Installer

### Via QR Code

```bash
# 1. Héberger l'APK temporairement
# Exemple avec Python :
python3 -m http.server 8000

# 2. Générer QR code avec l'URL
# http://<votre-ip>:8000/u-auben-inventory-v1.0.0.apk

# 3. Scanner avec la tablette
# Télécharger et installer
```

## 🔍 Vérification Post-Installation

### Tests de Base

1. **Lancement**
   - L'app démarre sans crash
   - Le splash screen s'affiche
   - L'écran d'accueil se charge

2. **Base de Données**
   ```bash
   # Via ADB Shell
   adb shell
   cd /data/data/com.uauben.inventory/databases/
   ls -la
   # Devrait afficher : u_auben_inventory
   ```

3. **CRUD Inventory**
   - Ajouter un produit → ✅ Sauvegardé
   - Afficher la liste → ✅ Produit visible
   - Supprimer → ✅ Produit retiré

4. **IA Aube**
   - Mode Offline → Tester sans Wi-Fi → ✅ Répond
   - Mode Online → Configurer API Key → ✅ Répond avec contexte

5. **Export**
   - Paramètres → Exporter DB → ✅ Fichier JSON téléchargé

### Logs de Débogage

```bash
# Voir les logs en temps réel
adb logcat | grep -E "(U-AUBEN|SQLite|Capacitor)"

# Filtrer par erreur
adb logcat *:E | grep U-AUBEN

# Sauvegarder les logs
adb logcat > logs_u-auben.txt
```

## 🐛 Dépannage

### Problème : "App not installed"
**Solutions :**
1. Désinstaller l'ancienne version
2. Vérifier la signature
3. Vérifier l'espace de stockage

### Problème : "Parse error"
**Solutions :**
1. APK corrompu → Re-télécharger
2. Architecture incompatible → Vérifier ARM/x86
3. Android version trop ancienne → Min SDK 24 requis

### Problème : "Unauthorized"
**Solutions :**
1. Révoquer autorisation USB → Reconnecter
2. Réactiver débogage USB
3. Changer de câble/port USB

### Problème : Base de données vide
**Solutions :**
```bash
# Vérifier les permissions
adb shell pm list permissions | grep STORAGE

# Vider le cache
adb shell pm clear com.uauben.inventory

# Réinstaller
adb uninstall com.uauben.inventory
adb install u-auben-inventory-v1.0.0.apk
```

## 📊 Checklist Finale

Avant de déployer en production :

- [ ] Version number incrémentée dans `package.json`
- [ ] Code signé avec release keystore
- [ ] Assets locaux tous téléchargés
- [ ] Tests sur tablette physique
- [ ] Mode offline testé
- [ ] Mode online testé (avec API key)
- [ ] Export/Import testé
- [ ] Logs vérifiés (pas d'erreurs critiques)
- [ ] Documentation mise à jour

## 🎯 Distribution

### Google Play Store (Future)

1. Créer compte développeur ($25 unique)
2. Créer une nouvelle app
3. Upload AAB (pas APK)
   ```bash
   cd android
   ./gradlew bundleRelease
   ```
4. Remplir les métadonnées
5. Soumettre pour review

### Distribution Directe

1. Héberger l'APK sur un serveur
2. Créer une page de landing
3. Fournir le lien de téléchargement
4. Instructions d'installation

## 📞 Support

En cas de problème :
1. Vérifier les logs : `adb logcat`
2. Consulter `SQLITE_GUIDE.md`
3. Tester en mode debug : `npm run open:android`

---

**Build réussi ? Bravo ! 🎉**

L'app U-AUBEN INVENTORY est maintenant prête à gérer l'inventaire universitaire de manière 100% offline avec l'assistance de l'IA Aube.
