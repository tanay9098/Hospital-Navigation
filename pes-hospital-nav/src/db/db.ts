import Database from "better-sqlite3";
import path from "path";
import {env} from "../config/env";

const dbPath = env.DB_PATH || "./hospital.db";

const resolvedPath = path.resolve(dbPath);

const db = new Database(resolvedPath);

db.pragma("journal_mode = WAL");

export default db;