import fs from "fs";
import path from "path";
import db from "./db";

const migrationsDir = path.join(__dirname, "migrations");

function ensureMigrationsTable() {
  db.prepare(`
    CREATE TABLE IF NOT EXISTS migrations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      applied_at TEXT NOT NULL
    )
  `).run();
}

function getAppliedMigrations(): string[] {
  const rows = db.prepare(`SELECT name FROM migrations`).all() as { name: string }[];
  return rows.map((r) => r.name);
}

function runMigrations() {
  ensureMigrationsTable();

  const applied = new Set(getAppliedMigrations());

  const files = fs
    .readdirSync(migrationsDir)
    .filter((f) => f.endsWith(".sql"))
    .sort();

  for (const file of files) {
    if (applied.has(file)) {
      continue;
    }

    const filePath = path.join(migrationsDir, file);
    const sql = fs.readFileSync(filePath, "utf-8");

    const transaction = db.transaction(() => {
      db.exec(sql);

      db.prepare(`
        INSERT INTO migrations (name, applied_at)
        VALUES (?, datetime('now'))
      `).run(file);
    });

    transaction();

    console.log(`Applied migration: ${file}`);
  }
}

runMigrations();