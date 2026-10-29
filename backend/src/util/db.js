import pg from 'pg';

export class DBClient {

    static CORE_SCHEMA = 'platform';

    static #NAME = /^[a-z_][a-z0-9_]*$/;

    static pool = null;

    static #tenants = new Map();

    static core = new DBClient({ schema: DBClient.CORE_SCHEMA });

    static identifier({ name }) {

        if (typeof name !== 'string' || !DBClient.#NAME.test(name)) {
            throw new Error(`Invalid name: ${name}`);
        }

        return name;

    }

    static tenant({ schema }) {

        if (!DBClient.#tenants.has(schema)) {
            DBClient.#tenants.set(schema, new DBClient({ schema }));
        }

        return DBClient.#tenants.get(schema);

    }

    static isDuplicate({ err }) {

        return err.code === '23505';

    }

    static connect({
        host,
        port,
        user,
        password,
        database,
        ssl
    }) {
        DBClient.pool = new pg.Pool({
            host: host,
            port: port,
            user: user,
            password: password,
            database: database,
            ssl: ssl ? { rejectUnauthorized: true } : undefined,
            max: 5,
            keepAlive: true,
            connectionTimeoutMillis: 5000,
        });

        DBClient.pool.on('error', (err) => {

            console.error('[db] idle client error', err);

        });
    }

    static usePool({ pool }) {

        DBClient.pool = pool;

    }

    static close() {

        return DBClient.pool?.end();

    }

    static #getPool() {

        if (!DBClient.pool) {
            throw new Error('Database is not connected. Call DBClient.connect() first');
        }

        return DBClient.pool;

    }

    constructor({ schema }) {

        this.schema = DBClient.identifier({ name: schema });

    }

    async query({ sql, params = [] }) {

        const { rows } = await this.#execute({ sql, params });

        return rows;

    }

    async select({ table, columns = '*', where = {}, orderBy, limit }) {

        const values = [];
        let sql = `SELECT ${columns} FROM ${DBClient.identifier({ name: table })}${this.#where({ where, values })}`;

        if (orderBy) {
            sql += ` ORDER BY ${orderBy}`;
        }

        if (limit !== undefined) {
            if (!Number.isInteger(limit) || limit < 0) {
                throw new Error('limit must be a non-negative integer');
            }
            sql += ` LIMIT ${limit}`;
        }

        const { rows } = await this.#execute({ sql, params: values });

        return rows;

    }

    async insert({ table, columns, values, returning }) {

        if (columns.length !== values.length) {
            throw new Error('insert needs one value per column');
        }

        const names = columns.map((column) => DBClient.identifier({ name: column }));
        const marks = values.map((_, i) => `$${i + 1}`);
        let sql = `INSERT INTO ${DBClient.identifier({ name: table })} (${names.join(', ')}) VALUES (${marks.join(', ')})`;

        if (returning) {
            sql += ` RETURNING ${returning}`;
        }

        const { rows } = await this.#execute({ sql, params: values });

        return rows[0];

    }

    async update({ table, data, where }) {

        if (!Object.keys(where).length) {
            throw new Error('update needs a where condition');
        }

        const values = [];
        const assignments = Object.entries(data).map(([key, value]) => {

            values.push(value);
            return `${DBClient.identifier({ name: key })} = $${values.length}`;

        });
        const sql = `UPDATE ${DBClient.identifier({ name: table })} SET ${assignments.join(', ')}${this.#where({ where, values })}`;

        const { rowCount } = await this.#execute({ sql, params: values });

        return rowCount;

    }

    async transaction({ work }) {

        const client = await DBClient.#getPool().connect();
        let broken;

        try {
            await client.query('BEGIN');
            await client.query(`SET LOCAL search_path TO ${this.schema}`);
            const result = await work(client);
            await client.query('COMMIT');
            return result;
        } catch (err) {
            try {
                await client.query('ROLLBACK');
            } catch (rollbackErr) {
                broken = rollbackErr;
            }
            throw err;
        } finally {
            client.release(broken);
        }

    }

    async #execute({ sql, params }) {

        const client = await DBClient.#getPool().connect();

        try {
            await client.query(`SET search_path TO ${this.schema}`);
            return await client.query(sql, params);
        } finally {
            client.release();
        }

    }

    #where({ where, values }) {

        const keys = Object.keys(where);

        if (!keys.length) {
            return '';
        }

        const conditions = keys.map((key) => {

            const name = DBClient.identifier({ name: key });

            if (where[key] === undefined) {
                throw new Error(`Missing value for ${key}`);
            }

            if (where[key] === null) {
                return `${name} IS NULL`;
            }

            values.push(where[key]);
            return `${name} = $${values.length}`;

        });

        return ` WHERE ${conditions.join(' AND ')}`;

    }

}
