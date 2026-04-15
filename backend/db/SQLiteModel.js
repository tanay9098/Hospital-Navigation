/**
 * SQLiteModel – a thin Mongoose-compatible wrapper around better-sqlite3.
 *
 * Implements the subset of the Mongoose/MongoDB API used by this project:
 *   find, findOne, findById, create, insertMany, deleteMany,
 *   findOneAndUpdate, findByIdAndUpdate, and instance .save().
 *
 * Each model is configured with:
 *   table       – SQLite table name
 *   columns     – mapping of JS field name → SQL column name
 *   jsonColumns – columns stored as JSON strings (arrays / objects)
 *   textColumns – columns searched when $text: { $search } is used
 *   pk          – primary-key JS field (default 'id')
 */

const { getDB } = require('./sqlite');
const { v4: uuidv4 } = require('uuid');

// ── helpers ───────────────────────────────────────────────────────────────────

/** Serialize a value: JSON-encode arrays/objects, pass scalars through. */
function serialize(val) {
  if (val === null || val === undefined) return null;
  if (typeof val === 'object') return JSON.stringify(val);
  return val;
}

/** Deserialize a value from a DB row, JSON-parsing the jsonColumns. */
function deserialize(val, isJson) {
  if (val === null || val === undefined) return null;
  if (isJson) {
    try { return JSON.parse(val); } catch { return val; }
  }
  return val;
}

/**
 * Convert a raw DB row into a plain JS document.
 * Handles JSON columns and maps snake_case SQL columns back to camelCase JS fields.
 */
function rowToDoc(row, columns, jsonColumns, reverseCols) {
  if (!row) return null;
  const doc = {};
  for (const [col, val] of Object.entries(row)) {
    const field = reverseCols[col] || col;
    doc[field]  = deserialize(val, jsonColumns.has(col));
  }
  return doc;
}

/**
 * Build a SQL WHERE clause from a query object.
 * Supports: equality, $in, $ne, $exists, $or, $and, and $text (regex fallback).
 *
 * Returns { where: string, params: any[] }
 */
function buildWhere(query, columns, jsonColumns, textColumns) {
  const parts  = [];
  const params = [];

  for (const [field, condition] of Object.entries(query)) {
    if (field === '$text') {
      // Full-text search → LIKE across text columns
      const words = (condition.$search || '').trim().split(/\s+/).filter(Boolean);
      if (words.length && textColumns.length) {
        const wordClauses = words.map((word) => {
          const colClauses = textColumns.map((col) => {
            params.push(`%${word}%`);
            return `${col} LIKE ?`;
          });
          return `(${colClauses.join(' OR ')})`;
        });
        parts.push(`(${wordClauses.join(' AND ')})`);
      }
      continue;
    }

    if (field === '$or') {
      const orParts = condition.map((subQ) => {
        const sub = buildWhere(subQ, columns, jsonColumns, textColumns);
        params.push(...sub.params);
        return `(${sub.where || '1=1'})`;
      });
      parts.push(`(${orParts.join(' OR ')})`);
      continue;
    }

    if (field === '$and') {
      const andParts = condition.map((subQ) => {
        const sub = buildWhere(subQ, columns, jsonColumns, textColumns);
        params.push(...sub.params);
        return `(${sub.where || '1=1'})`;
      });
      parts.push(`(${andParts.join(' AND ')})`);
      continue;
    }

    const col = columns[field] || field;

    if (condition !== null && typeof condition === 'object' && !Array.isArray(condition)) {
      if ('$in' in condition) {
        const vals = condition.$in;
        if (vals.length === 0) { parts.push('0=1'); continue; }
        parts.push(`${col} IN (${vals.map(() => '?').join(',')})`);
        params.push(...vals);
        continue;
      }
      if ('$ne' in condition) {
        if (condition.$ne === null) {
          parts.push(`${col} IS NOT NULL`);
        } else {
          parts.push(`${col} != ?`);
          params.push(condition.$ne);
        }
        continue;
      }
      if ('$exists' in condition) {
        parts.push(condition.$exists ? `${col} IS NOT NULL` : `${col} IS NULL`);
        continue;
      }
      if ('$gt' in condition)  { parts.push(`${col} > ?`);  params.push(condition.$gt);  continue; }
      if ('$gte' in condition) { parts.push(`${col} >= ?`); params.push(condition.$gte); continue; }
      if ('$lt' in condition)  { parts.push(`${col} < ?`);  params.push(condition.$lt);  continue; }
      if ('$lte' in condition) { parts.push(`${col} <= ?`); params.push(condition.$lte); continue; }
    }

    // Equality (handles null → IS NULL)
    if (condition === null) {
      parts.push(`${col} IS NULL`);
    } else {
      parts.push(`${col} = ?`);
      params.push(typeof condition === 'boolean' ? (condition ? 1 : 0) : condition);
    }
  }

  return { where: parts.length ? parts.join(' AND ') : '1=1', params };
}

/**
 * Build ORDER BY clause from a Mongoose sort spec.
 * { floor: 1, name: -1 }  →  "floor ASC, name DESC"
 * { score: { $meta: 'textScore' } }  →  "name ASC"  (approximation)
 */
function buildOrderBy(sort, columns) {
  if (!sort || !Object.keys(sort).length) return '';
  const parts = [];
  for (const [field, dir] of Object.entries(sort)) {
    // $meta sorts (e.g. textScore) → approximate as name ASC
    if (dir && typeof dir === 'object' && dir.$meta) {
      parts.push('name ASC');
      continue;
    }
    const col = columns[field];
    if (!col) continue;   // skip unknown fields rather than generating bad SQL
    parts.push(`${col} ${dir >= 0 ? 'ASC' : 'DESC'}`);
  }
  return parts.length ? `ORDER BY ${parts.join(', ')}` : '';
}

// ── QueryBuilder ──────────────────────────────────────────────────────────────

class QueryBuilder {
  constructor(model, type, query) {
    this._model   = model;
    this._type    = type;   // 'find' | 'findOne'
    this._query   = query;
    this._sort    = null;
    this._limitN  = null;
  }

  sort(spec) { this._sort = spec; return this; }
  limit(n)   { this._limitN = n;  return this; }
  lean()     { return this; }   // no-op — we always return plain objects

  then(onFulfilled, onRejected) {
    return this._execute().then(onFulfilled, onRejected);
  }
  catch(onRejected) {
    return this._execute().catch(onRejected);
  }

  async _execute() {
    return this._type === 'findOne'
      ? this._model._findOne(this._query)
      : this._model._find(this._query, this._sort, this._limitN);
  }
}

// ── SQLiteModel ───────────────────────────────────────────────────────────────

class SQLiteModel {
  /**
   * @param {string}   table        – SQL table name
   * @param {Object}   columns      – { jsField: 'sql_column', ... }
   * @param {string[]} jsonColumns  – JS field names stored as JSON text
   * @param {string[]} textColumns  – SQL column names for $text search
   * @param {string}   pk           – primary key JS field name (default 'id')
   */
  constructor({ table, columns = {}, jsonColumns = [], textColumns = [], pk = 'id' }) {
    this._table       = table;
    this._columns     = columns;          // jsField → sqlCol
    this._jsonCols    = new Set(jsonColumns.map((f) => columns[f] || f));
    this._textCols    = textColumns.map((f) => columns[f] || f);
    this._pk          = pk;
    this._reverseCols = Object.fromEntries(
      Object.entries(columns).map(([js, sql]) => [sql, js])
    );
  }

  // ── Public query API ───────────────────────────────────────────────────────

  find(query = {}, _projection = null) {
    return new QueryBuilder(this, 'find', query);
  }

  findOne(query = {}, _projection = null) {
    return new QueryBuilder(this, 'findOne', query);
  }

  findById(id) {
    return this.findOne({ [this._pk]: id });
  }

  // ── Write operations ───────────────────────────────────────────────────────

  async create(doc) {
    const row = this._docToRow({ id: uuidv4(), ...doc });
    const cols = Object.keys(row);
    const sql  = `INSERT INTO ${this._table} (${cols.join(',')}) VALUES (${cols.map(() => '?').join(',')})`;
    getDB().prepare(sql).run(...Object.values(row));
    return this._attachSave(this._find1ByPk(row[this._columns[this._pk] || this._pk]));
  }

  async insertMany(docs) {
    const insert = getDB().transaction((items) => {
      for (const doc of items) {
        const row  = this._docToRow({ id: uuidv4(), ...doc });
        const cols = Object.keys(row);
        getDB()
          .prepare(`INSERT INTO ${this._table} (${cols.join(',')}) VALUES (${cols.map(() => '?').join(',')})`)
          .run(...Object.values(row));
      }
    });
    insert(docs);
    return docs;
  }

  async deleteMany(query = {}) {
    const { where, params } = buildWhere(query, this._columns, this._jsonCols, this._textCols);
    const info = getDB().prepare(`DELETE FROM ${this._table} WHERE ${where}`).run(...params);
    return { deletedCount: info.changes };
  }

  async findOneAndUpdate(query, update, options = {}) {
    const doc = await this._findOne(query);
    if (!doc) return null;
    const merged = { ...doc, ...this._flattenUpdate(update) };
    merged.updated_at = new Date().toISOString();
    const row  = this._docToRow(merged);
    const pkCol = this._columns[this._pk] || this._pk;
    const sets  = Object.keys(row).filter((c) => c !== pkCol).map((c) => `${c} = ?`);
    const vals  = Object.entries(row).filter(([c]) => c !== pkCol).map(([, v]) => v);
    getDB().prepare(`UPDATE ${this._table} SET ${sets.join(', ')} WHERE ${pkCol} = ?`)
      .run(...vals, row[pkCol]);
    return options.new ? this._attachSave(this._find1ByPk(row[pkCol])) : null;
  }

  async findByIdAndUpdate(id, update, options = {}) {
    return this.findOneAndUpdate({ [this._pk]: id }, update, options);
  }

  // ── Internal helpers ───────────────────────────────────────────────────────

  _find(query, sort = null, limitN = null) {
    const { where, params } = buildWhere(query, this._columns, this._jsonCols, this._textCols);
    const order  = buildOrderBy(sort, this._columns);
    const limitS = limitN ? `LIMIT ${limitN}` : '';
    const rows   = getDB().prepare(`SELECT * FROM ${this._table} WHERE ${where} ${order} ${limitS}`).all(...params);
    return rows.map((r) => this._attachSave(rowToDoc(r, this._columns, this._jsonCols, this._reverseCols)));
  }

  _findOne(query) {
    const { where, params } = buildWhere(query, this._columns, this._jsonCols, this._textCols);
    const row = getDB().prepare(`SELECT * FROM ${this._table} WHERE ${where} LIMIT 1`).get(...params);
    return this._attachSave(rowToDoc(row, this._columns, this._jsonCols, this._reverseCols));
  }

  _find1ByPk(pkValue) {
    const pkCol = this._columns[this._pk] || this._pk;
    const row   = getDB().prepare(`SELECT * FROM ${this._table} WHERE ${pkCol} = ?`).get(pkValue);
    return rowToDoc(row, this._columns, this._jsonCols, this._reverseCols);
  }

  /** Translate a JS document to a row object with SQL column names. */
  _docToRow(doc) {
    const row = {};
    for (const [field, val] of Object.entries(doc)) {
      if (field === 'save') continue;
      const col   = this._columns[field] || field;
      row[col]    = this._jsonCols.has(col)
        ? serialize(val)
        : (typeof val === 'boolean' ? (val ? 1 : 0) : serialize(val));
    }
    return row;
  }

  /** Flatten a Mongoose-style update ($set / plain) to a plain object. */
  _flattenUpdate(update) {
    if (update.$set) return update.$set;
    const hasOps = Object.keys(update).some((k) => k.startsWith('$'));
    return hasOps ? {} : update;
  }

  /**
   * Attach a non-enumerable .save() to a document instance so callers can do:
   *   session.state = 'DONE';
   *   await session.save();
   */
  _attachSave(doc) {
    if (!doc) return null;
    const model = this;
    Object.defineProperty(doc, 'save', {
      enumerable: false,
      writable:   true,
      value: async function () {
        await model.findOneAndUpdate(
          { [model._pk]: this[model._pk] },
          { ...this },
          { new: false }
        );
        return this;
      },
    });
    return doc;
  }
}

module.exports = SQLiteModel;
