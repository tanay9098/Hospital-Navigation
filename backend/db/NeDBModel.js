/**
 * NeDBModel – a thin Mongoose-compatible wrapper around a NeDB Datastore.
 *
 * Implements only the subset of the Mongoose/MongoDB API that this project uses:
 *   find, findOne, findById, create, insertMany, deleteMany,
 *   findOneAndUpdate, findByIdAndUpdate,
 *   and the instance .save() pattern.
 *
 * Key translation:
 *   $text: { $search: '...' }  →  regex OR across text fields
 *   { score: { $meta } } sort  →  sort by name asc
 *   projection string ('-connections', 'code name floor')  →  NeDB projection obj
 *   .lean()                    →  no-op (NeDB always returns plain objects)
 */

// ── Query / projection helpers ────────────────────────────────────────────────

/**
 * Convert a Mongoose-style projection argument to a NeDB projection object.
 *
 *   '-connections'        → { connections: 0 }
 *   'code name floor'     → { code: 1, name: 1, floor: 1 }
 *   { score:{$meta:'…'} } → null  (text-score projections are unsupported; ignore)
 *   null / undefined      → null
 */
function parseProjection(proj) {
  if (!proj) return null;

  if (typeof proj === 'object') {
    // Ignore MongoDB $meta projections (e.g. { score: { $meta: 'textScore' } })
    if (Object.values(proj).some((v) => v && typeof v === 'object' && v.$meta)) {
      return null;
    }
    return proj;
  }

  if (typeof proj === 'string') {
    const fields = proj.trim().split(/\s+/).filter(Boolean);
    const result = {};
    for (const f of fields) {
      result[f.startsWith('-') ? f.slice(1) : f] = f.startsWith('-') ? 0 : 1;
    }
    return Object.keys(result).length ? result : null;
  }

  return null;
}

/**
 * Convert a Mongoose sort spec to a NeDB sort spec.
 * Maps { score: { $meta: 'textScore' } } → { name: 1 }.
 */
function parseSort(spec) {
  if (!spec) return null;
  const result = {};
  for (const [k, v] of Object.entries(spec)) {
    result[k] = (v && typeof v === 'object' && v.$meta) ? null : v;
    if (result[k] === null) {
      delete result[k];
      result['name'] = 1; // approximate: sort by name when text score is requested
    }
  }
  return Object.keys(result).length ? result : null;
}

/**
 * Convert a MongoDB query that contains $text search to a NeDB-compatible
 * regex query that searches across the supplied text fields.
 */
function convertTextSearch(query, textFields) {
  if (!query || !query.$text) return query;

  const { $text, ...rest } = query;
  const searchStr = ($text.$search || '').trim();
  if (!searchStr) return rest;

  const words = searchStr.split(/\s+/).filter(Boolean);
  const orClauses = [];

  for (const word of words) {
    // Escape regex metacharacters in the search term
    const escaped = word.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const regex    = new RegExp(escaped, 'i');
    for (const field of textFields) {
      orClauses.push({ [field]: regex });
    }
  }

  if (!orClauses.length) return rest;

  // Merge with any pre-existing $or; otherwise attach directly
  if (rest.$or) {
    return { ...rest, $and: [{ $or: orClauses }, { $or: rest.$or }] };
  }
  return { ...rest, $or: orClauses };
}

/**
 * Apply an inclusion or exclusion projection to a document or array of documents.
 */
function applyProjection(data, proj) {
  if (!proj || !Object.keys(proj).length) return data;

  const isArray = Array.isArray(data);
  const docs    = isArray ? data : [data];

  const includeKeys = Object.entries(proj).filter(([, v]) => v === 1).map(([k]) => k);
  const excludeKeys = Object.entries(proj).filter(([, v]) => v === 0).map(([k]) => k);

  const projected = docs.map((doc) => {
    if (!doc) return doc;

    if (includeKeys.length > 0) {
      // Inclusion: return only the listed fields (always keep _id)
      const out = { _id: doc._id };
      for (const k of includeKeys) {
        if (k in doc) out[k] = doc[k];
      }
      return out;
    }

    // Exclusion: remove listed fields
    const out = { ...doc };
    for (const k of excludeKeys) delete out[k];
    return out;
  });

  return isArray ? projected : projected[0];
}

// ── QueryBuilder ──────────────────────────────────────────────────────────────

/**
 * Lazy query object returned by find() / findOne().
 * Supports Mongoose-style chaining: .sort(), .limit(), .lean().
 * Becomes a Promise when awaited (thenable protocol).
 */
class QueryBuilder {
  constructor(store, type, query, rawProjection, textFields) {
    this._store      = store;
    this._type       = type;   // 'find' | 'findOne'
    this._query      = convertTextSearch(query || {}, textFields);
    this._proj       = parseProjection(rawProjection);
    this._sortSpec   = null;
    this._limitVal   = null;
    this._textFields = textFields;
  }

  sort(spec) {
    this._sortSpec = parseSort(spec);
    return this;
  }

  limit(n) {
    this._limitVal = n;
    return this;
  }

  lean() { return this; } // no-op — NeDB always returns plain JS objects

  // Thenable — makes `await queryBuilder` work
  then(onFulfilled, onRejected) {
    return this._execute().then(onFulfilled, onRejected);
  }
  catch(onRejected) {
    return this._execute().catch(onRejected);
  }

  async _execute() {
    let result;

    if (this._type === 'findOne') {
      result = await this._store.findOneAsync(this._query);
    } else {
      let cursor = this._store.find(this._query);
      if (this._sortSpec) cursor = cursor.sort(this._sortSpec);
      if (this._limitVal) cursor = cursor.limit(this._limitVal);
      result = await cursor.execAsync();
    }

    return this._proj ? applyProjection(result, this._proj) : result;
  }
}

// ── NeDBModel ─────────────────────────────────────────────────────────────────

class NeDBModel {
  /**
   * @param {import('@seald-io/nedb')} store  – NeDB Datastore instance
   * @param {string[]} textFields             – fields searched by $text queries
   */
  constructor(store, textFields = []) {
    this._store      = store;
    this._textFields = textFields;
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  find(query = {}, projection = null) {
    return new QueryBuilder(this._store, 'find', query, projection, this._textFields);
  }

  findOne(query = {}, projection = null) {
    return new QueryBuilder(this._store, 'findOne', query, projection, this._textFields);
  }

  findById(id) {
    return this.findOne({ _id: id });
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  async create(doc) {
    const inserted = await this._store.insertAsync(doc);
    return this._attachSave(inserted);
  }

  async insertMany(docs) {
    return Promise.all(docs.map((d) => this._store.insertAsync(d)));
  }

  async deleteMany(query = {}) {
    const n = await this._store.removeAsync(query, { multi: true });
    return { deletedCount: n };
  }

  async findOneAndUpdate(query, update, options = {}) {
    const q = convertTextSearch(query, this._textFields);
    await this._store.updateAsync(q, this._wrapUpdate(update), { multi: false });

    if (options.new) {
      const doc = await this._store.findOneAsync(q);
      return this._attachSave(doc);
    }
    return null;
  }

  async findByIdAndUpdate(id, update, options = {}) {
    return this.findOneAndUpdate({ _id: id }, update, options);
  }

  // ── Instance .save() helper ───────────────────────────────────────────────

  /**
   * Attaches a non-enumerable `.save()` method to a document so callers can
   * do:  session.state = 'DONE';  await session.save();
   */
  _attachSave(doc) {
    if (!doc) return null;
    const store = this._store;

    Object.defineProperty(doc, 'save', {
      enumerable: false,
      writable:   true,
      value: async function () {
        const _id  = this._id;
        const data = { ...this }; // spread skips non-enumerable 'save'
        delete data._id;
        await store.updateAsync({ _id }, { $set: data }, {});
        return this;
      },
    });

    return doc;
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  /** Wrap a plain update object in $set unless it already uses operators. */
  _wrapUpdate(update) {
    const hasOperators = Object.keys(update).some((k) => k.startsWith('$'));
    return hasOperators ? update : { $set: update };
  }
}

module.exports = NeDBModel;
