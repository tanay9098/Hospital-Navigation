import Database, { Database as DatabaseType } from "better-sqlite3";
import path from "path";
import fs from "fs";
import { env } from "../config/env";

const dbPath = env.DB_PATH || "./hospital.db";
const resolvedPath = path.resolve(dbPath);

const dir = path.dirname(resolvedPath);
if (!fs.existsSync(dir)) {
  fs.mkdirSync(dir, { recursive: true });
}

const db: DatabaseType = new Database(resolvedPath);
db.pragma("journal_mode = WAL");

export default db;