import { readFile, readdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { DBClient } from './db.js';

export class Migrator {

    static #folderOf({ folder }) {

        return fileURLToPath(new URL(`../../migrations/${folder}/`, import.meta.url));

    }

    static async schema({ client, schema, folder }) {

        DBClient.identifier({ name: schema });

        await client.query(`CREATE SCHEMA IF NOT EXISTS ${schema}`);
        await client.query(`SET LOCAL search_path TO ${schema}`);
        await client.query('CREATE TABLE IF NOT EXISTS schema_migrations (name varchar(255) PRIMARY KEY)');

        const { rows } = await client.query('SELECT name FROM schema_migrations');
        const applied = rows.map((row) => row.name);
        const directory = Migrator.#folderOf({ folder });
        const files = (await readdir(directory)).filter((file) => file.endsWith('.sql')).sort();

        for (const file of files) {
            if (applied.includes(file)) {
                continue;
            }

            await client.query(await readFile(directory + file, 'utf8'));
            await client.query('INSERT INTO schema_migrations (name) VALUES ($1)', [file]);
        }

    }

    static async all() {

        await DBClient.core.transaction({
            work: (client) => {

                return Migrator.schema({ client, schema: DBClient.CORE_SCHEMA, folder: 'core' });

            },
        });

        const institutes = await DBClient.core.select({
            table: 'institute',
            columns: 'schema_name',
            orderBy: 'id',
        });

        for (const { schema_name } of institutes) {
            await DBClient.tenant({ schema: schema_name }).transaction({
                work: (client) => {

                    return Migrator.schema({ client, schema: schema_name, folder: 'tenant' });

                },
            });
        }

    }

}
