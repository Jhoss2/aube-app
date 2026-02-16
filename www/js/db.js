// Configuration SQLite pour Capacitor
const setupDatabase = async () => {
    const { CapacitorSQLite, SQLiteConnection } = window.CapacitorSQLite;
    const sqlite = new SQLiteConnection(CapacitorSQLite);

    try {
        // 1. Créer ou ouvrir la base de données
        const db = await sqlite.createConnection("inventory_db", false, "no-encryption", 1);
        await db.open();

        // 2. Créer la table des produits (si elle n'existe pas)
        const schema = `
            CREATE TABLE IF NOT EXISTS items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                nom TEXT NOT NULL,
                quantite INTEGER NOT NULL DEFAULT 0,
                categorie TEXT,
                prix REAL
            );
        `;
        await db.execute(schema);
        
        console.log("SQLite initialisé avec succès");
        return db;
    } catch (e) {
        console.error("Erreur SQLite :", e);
        return null;
    }
};

// Fonctions d'accès aux données (CRUD)
const dbActions = {
    async addProduct(db, nom, quantite, categorie, prix) {
        const sql = "INSERT INTO items (nom, quantite, categorie, prix) VALUES (?, ?, ?, ?);";
        return await db.run(sql, [nom, quantite, categorie, prix]);
    },
    async getAllProducts(db) {
        const res = await db.query("SELECT * FROM items ORDER BY nom ASC;");
        return res.values;
    },
    async updateStock(db, id, nouvelleQuantite) {
        const sql = "UPDATE items SET quantite = ? WHERE id = ?;";
        return await db.run(sql, [nouvelleQuantite, id]);
    }
};
