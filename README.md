# 🚀 U-AUBEN INVENTORY APP

Application native Android de gestion d'inventaire avec IA hybride (online/offline) et stockage SQLite local.

## 📋 Caractéristiques

### ✅ Architecture 100% Offline-First
- **Aucune dépendance externe** : Tous les assets (CSS, JS, fonts) sont servis localement
- **Persistance SQLite** : Base de données locale avec @capacitor-community/sqlite
- **Design adapté tablette** : Conteneur max-width 1024px pour une ergonomie optimale

### 🤖 IA "Aube" Hybride
- **Mode Online** : Utilise l'API Gemini de Google avec contexte d'inventaire en temps réel
- **Mode Offline (Aube Lite)** : Traitement local des requêtes via pattern matching
- **Continuité de service** : L'utilisateur peut interroger ses données même sans Wi-Fi

### 💾 Gestion des Données
- **Table `inventory`** : Gestion complète des produits (nom, quantité, unité, date)
- **Table `notes`** : Système de notes avec catégories
- **CRUD complet** : Créer, Lire, Modifier, Supprimer
- **Export/Import** : Sauvegarde en JSON

## 🛠️ Installation et Build

### Prérequis
- Node.js 20.x
- Java 21
- Android SDK 35
- Capacitor 6+

### Étapes

```bash
# 1. Installation des dépendances
npm install

# 2. Téléchargement des assets locaux
npm run copy-assets

# 3. Synchronisation avec Android
npm run build

# 4. Ouvrir dans Android Studio
npm run open:android

# 5. Build de l'APK
cd android
./gradlew assembleRelease
```

### Build via Codemagic

Le fichier `codemagic.yaml` est configuré pour un build automatisé :
1. Push le code sur votre repo
2. Connectez Codemagic à votre repo
3. Le build se lance automatiquement
4. L'APK est disponible dans les artifacts

## 📱 Utilisation

### Premier Lancement
1. L'app crée automatiquement la base de données SQLite
2. Accédez au menu Paramètres (⚙️) pour configurer la clé API Gemini (optionnel)

### Fonctionnalités Principales

#### 🏠 Accueil
- Vue de l'inventaire complet
- Recherche de produits
- Navigation rapide

#### ➕ Ajouter un Produit
- Nom, quantité, unité
- Enregistrement en SQLite
- Mise à jour instantanée

#### 📝 Notes
- Créer des notes avec catégories
- Historique complet
- Stockage local

#### 🤖 Chat Aube IA
**Mode Online** (avec clé API Gemini) :
- "Combien de Colis A reste-t-il ?" → Aube interroge SQLite + répond avec contexte
- "Fais-moi un rapport de stock" → Analyse complète

**Mode Offline** (Aube Lite) :
- "Stock Colis A ?" → Requête SQL directe → "Aube (Offline) : Il reste 25 pcs"
- "Liste inventaire" → Affichage complet de la base de données
- Conversations basiques sans connexion

## 🔧 Configuration

### Clé API Gemini
1. Obtenez une clé sur [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Dans l'app : Paramètres → Clé API Gemini
3. Enregistrer

Sans clé API, Aube fonctionne en mode Lite (offline uniquement).

### Structure de la Base de Données

```sql
-- Table inventory
CREATE TABLE inventory (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    unit TEXT,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Table notes
CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT NOT NULL,
    date DATETIME DEFAULT CURRENT_TIMESTAMP,
    category TEXT
);
```

## 📂 Structure du Projet

```
u-auben-inventory-app/
├── www/                          # Web assets
│   ├── index.html               # App principale
│   ├── manifest.json            # PWA manifest
│   ├── tailwind.min.css         # CSS local
│   ├── lucide.min.js           # Icônes local
│   ├── marked.min.js           # Markdown parser
│   └── fonts/                   # Polices locales
│       ├── inter.css
│       └── *.woff2
├── android/                      # Projet Android natif
├── package.json                 # Dépendances & scripts
├── capacitor.config.json        # Config Capacitor
└── codemagic.yaml              # Config CI/CD
```

## 🎨 Design

Le design respecte **strictement** les spécifications originales :
- Thème rose (#fde7f3)
- Fond avec pattern radial
- Polices : Algerian & Monotype Corsiva
- Icônes Lucide
- Adaptation tablette avec max-width 1024px

## 🚨 Points Importants

1. **NE PAS modifier** l'esthétique du design (couleurs, fonts, structure)
2. **TOUJOURS** tester en mode offline pour valider Aube Lite
3. Les données SQLite sont **locales** et **privées** sur chaque appareil
4. L'export JSON permet de sauvegarder avant réinstallation

## 📊 Workflow Aube IA

```
User Query
    ↓
Is Online + API Key?
    ↓
YES → Gemini API
    ↓ System Prompt injecte SQLite data
    ↓ Response contextuelle
    
NO → Aube Lite (Offline)
    ↓ Pattern Matching
    ↓ Query SQLite directe
    ↓ Response "Aube (Offline): ..."
```

## 🔐 Permissions Android

L'app demande uniquement :
- `INTERNET` (pour Gemini API en mode online)
- `ACCESS_NETWORK_STATE` (détection online/offline)
- Stockage local SQLite (pas de permission spéciale)

## 📞 Support

Pour toute question sur le build ou l'utilisation :
- Vérifiez les logs Codemagic
- Consultez la documentation Capacitor SQLite
- Testez en mode offline d'abord

## 🎯 Roadmap Future

- [ ] Import de fichiers JSON pour restauration
- [ ] Graphiques de suivi d'inventaire
- [ ] Export PDF des rapports
- [ ] Synchronisation multi-appareils (optionnel)

## 📄 Licence

MIT License - U-AUBEN 2024

---

**Développé selon les spécifications strictes U-AUBEN INVENTORY APP**

