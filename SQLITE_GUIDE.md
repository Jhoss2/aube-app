# 💾 Guide d'Intégration SQLite

## Architecture de la Base de Données

### Plugin Utilisé
`@capacitor-community/sqlite` v6.0.1

### Caractéristiques
- ✅ Stockage 100% local sur l'appareil
- ✅ Pas de connexion Internet requise
- ✅ Chiffrement désactivé pour performance maximale
- ✅ Création automatique au premier lancement

## Structure des Tables

### Table `inventory`
```sql
CREATE TABLE inventory (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    unit TEXT,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**Colonnes :**
- `id` : Identifiant unique auto-incrémenté
- `product_name` : Nom du produit (obligatoire)
- `quantity` : Quantité en stock (obligatoire)
- `unit` : Unité de mesure (optionnel : "pcs", "kg", "L", etc.)
- `last_updated` : Date/heure de dernière modification (auto)

**Opérations :**
```javascript
// CREATE
await db.run(`INSERT INTO inventory (product_name, quantity, unit) VALUES (?, ?, ?)`, 
    [name, quantity, unit]);

// READ
const result = await db.query('SELECT * FROM inventory ORDER BY last_updated DESC');

// UPDATE
await db.run(`UPDATE inventory SET quantity = ? WHERE id = ?`, [newQty, id]);

// DELETE
await db.run('DELETE FROM inventory WHERE id = ?', [id]);
```

### Table `notes`
```sql
CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT NOT NULL,
    date DATETIME DEFAULT CURRENT_TIMESTAMP,
    category TEXT
);
```

**Colonnes :**
- `id` : Identifiant unique
- `content` : Contenu de la note (obligatoire)
- `date` : Date de création (auto)
- `category` : Catégorie optionnelle ("Réunion", "Rappel", etc.)

## Initialisation de la Base

### Au Chargement de l'App

```javascript
import { CapacitorSQLite, SQLiteConnection } from '@capacitor-community/sqlite';

let db = null;
let sqliteConnection = null;

async function initDatabase() {
    try {
        // 1. Créer la connexion SQLite
        sqliteConnection = new SQLiteConnection(CapacitorSQLite);
        
        // 2. Créer/ouvrir la base de données
        db = await sqliteConnection.createConnection(
            'u_auben_inventory',  // Nom de la DB
            false,                // Pas de chiffrement
            'no-encryption',      // Mode
            1,                    // Version
            false                 // Mode readonly
        );
        
        // 3. Ouvrir la connexion
        await db.open();
        
        // 4. Créer les tables si elles n'existent pas
        await db.execute(`
            CREATE TABLE IF NOT EXISTS inventory (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                product_name TEXT NOT NULL,
                quantity INTEGER NOT NULL,
                unit TEXT,
                last_updated DATETIME DEFAULT CURRENT_TIMESTAMP
            );
        `);
        
        await db.execute(`
            CREATE TABLE IF NOT EXISTS notes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                content TEXT NOT NULL,
                date DATETIME DEFAULT CURRENT_TIMESTAMP,
                category TEXT
            );
        `);
        
        console.log('✅ Base de données initialisée');
    } catch (error) {
        console.error('❌ Erreur DB:', error);
    }
}

// Appeler au chargement de la page
document.addEventListener('DOMContentLoaded', initDatabase);
```

## Intégration avec l'IA Aube

### Requête de Contexte

Avant chaque requête à l'IA Gemini, on injecte le contenu de l'inventaire :

```javascript
async function getInventoryForAI() {
    try {
        const result = await db.query('SELECT * FROM inventory');
        
        if (!result.values || result.values.length === 0) {
            return "L'inventaire est actuellement vide.";
        }
        
        // Formater pour l'IA
        return result.values.map(item => 
            `${item.product_name}: ${item.quantity} ${item.unit || 'pcs'}`
        ).join(', ');
    } catch (error) {
        return "Erreur de lecture de l'inventaire.";
    }
}

// Utilisation avec Gemini
const systemPrompt = `Tu es Aube, l'assistant IA pour la gestion d'inventaire U-AUBEN. 
Inventaire actuel: ${await getInventoryForAI()}
Réponds de manière concise et utile.`;
```

### Mode Offline (Aube Lite)

Requêtes SQL directes basées sur le pattern matching :

```javascript
async function processOfflineMode(message, inventoryData) {
    const lowerMsg = message.toLowerCase();
    
    // Exemple : "Combien de Colis A ?"
    if (lowerMsg.includes('combien') || lowerMsg.includes('stock')) {
        const result = await db.query('SELECT * FROM inventory');
        
        // Chercher le produit mentionné
        const productMatch = result.values.find(item => 
            lowerMsg.includes(item.product_name.toLowerCase())
        );
        
        if (productMatch) {
            return `🔵 Aube (Offline): Il reste ${productMatch.quantity} ${productMatch.unit || 'pcs'} de ${productMatch.product_name}.`;
        }
    }
    
    // Exemple : "Liste inventaire"
    if (lowerMsg.includes('liste') || lowerMsg.includes('inventaire')) {
        return `🔵 Aube (Offline): ${inventoryData}`;
    }
    
    return "🔵 Aube (Offline): Je peux vous aider avec votre inventaire local.";
}
```

## Export / Import

### Export JSON

```javascript
async function exportDB() {
    const inventory = await db.query('SELECT * FROM inventory');
    const notes = await db.query('SELECT * FROM notes');
    
    const exportData = {
        inventory: inventory.values || [],
        notes: notes.values || [],
        exportDate: new Date().toISOString()
    };
    
    const dataStr = JSON.stringify(exportData, null, 2);
    const dataBlob = new Blob([dataStr], { type: 'application/json' });
    
    // Télécharger
    const url = URL.createObjectURL(dataBlob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `u-auben-backup-${Date.now()}.json`;
    link.click();
}
```

### Import JSON (Future)

```javascript
async function importDB(jsonData) {
    const data = JSON.parse(jsonData);
    
    // Importer inventaire
    for (const item of data.inventory) {
        await db.run(
            `INSERT INTO inventory (product_name, quantity, unit) VALUES (?, ?, ?)`,
            [item.product_name, item.quantity, item.unit]
        );
    }
    
    // Importer notes
    for (const note of data.notes) {
        await db.run(
            `INSERT INTO notes (content, category) VALUES (?, ?)`,
            [note.content, note.category]
        );
    }
}
```

## Performance & Best Practices

### ✅ À Faire
- Utiliser des requêtes préparées (avec `?` placeholders)
- Fermer proprement la connexion en cas d'erreur
- Gérer les transactions pour les opérations multiples
- Indexer les colonnes fréquemment recherchées

### ❌ À Éviter
- Requêtes SQL construites par concaténation de strings (risque d'injection)
- Ouvrir plusieurs connexions simultanées
- Effectuer des requêtes lourdes dans la boucle principale UI

### Optimisation

```javascript
// Transaction pour plusieurs insertions
await db.execute('BEGIN TRANSACTION');
try {
    for (const item of items) {
        await db.run('INSERT INTO inventory (product_name, quantity, unit) VALUES (?, ?, ?)',
            [item.name, item.qty, item.unit]);
    }
    await db.execute('COMMIT');
} catch (error) {
    await db.execute('ROLLBACK');
    console.error('Transaction failed:', error);
}
```

## Débogage

### Vérifier l'État de la DB

```javascript
// Lister toutes les tables
const tables = await db.query(`SELECT name FROM sqlite_master WHERE type='table'`);
console.log('Tables:', tables.values);

// Compter les enregistrements
const count = await db.query('SELECT COUNT(*) as total FROM inventory');
console.log('Total produits:', count.values[0].total);
```

### Logs Capacitor

```bash
# Android
adb logcat | grep -i sqlite

# Ou depuis Android Studio
Logcat → Filter: "SQLite"
```

## Migration de Version

Si vous ajoutez des colonnes plus tard :

```javascript
// Version 1 → 2
async function migrateToV2() {
    await db.execute(`ALTER TABLE inventory ADD COLUMN location TEXT`);
}

// Gérer les versions
const DB_VERSION = 2;
db = await sqliteConnection.createConnection(
    'u_auben_inventory',
    false,
    'no-encryption',
    DB_VERSION,  // Version incrémentée
    false
);
```

## Résolution de Problèmes

### Problème : "Database not found"
**Solution :** S'assurer que `await db.open()` est appelé après `createConnection()`

### Problème : "Table already exists"
**Solution :** Utiliser `CREATE TABLE IF NOT EXISTS`

### Problème : "No such column"
**Solution :** Vérifier l'orthographe des colonnes dans les requêtes

### Problème : Données perdues après redémarrage
**Solution :** Vérifier que la DB n'est pas en mode in-memory (utiliser un nom de fichier)

## Sécurité

### Chiffrement (Optionnel)

Si vous souhaitez activer le chiffrement :

```javascript
db = await sqliteConnection.createConnection(
    'u_auben_inventory',
    true,                    // Activer chiffrement
    'secret',                // Mode chiffrement
    1,
    false
);
```

⚠️ **Note :** Le chiffrement réduit les performances. Pour U-AUBEN, il est désactivé car les données ne sont pas sensibles.

## Ressources

- [Documentation Capacitor SQLite](https://github.com/capacitor-community/sqlite)
- [SQLite Syntax](https://www.sqlite.org/lang.html)
- [Capacitor Docs](https://capacitorjs.com/docs)

---

**Dernière mise à jour :** 2024
