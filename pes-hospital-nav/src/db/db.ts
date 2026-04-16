import Database from "better-sqlite3";
import path from "path";
import fs from "fs";
import { env } from "../config/env";

const dbPath = env.DB_PATH || "./hospital.db";
const resolvedPath = path.resolve(dbPath);

// Ensure directory exists
const dir = path.dirname(resolvedPath);

if (!fs.existsSync(dir)) {
  fs.mkdirSync(dir, { recursive: true });
}

const db = new Database(resolvedPath);

db.pragma("journal_mode = WAL");

export default db;