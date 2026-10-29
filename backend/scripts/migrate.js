import { Config } from '../src/util/config.js';
import { DBClient } from '../src/util/db.js';
import { Migrator } from '../src/util/migrate.js';

DBClient.connect(new Config().db);
await Migrator.all();
await DBClient.close();

console.log('Core and institute schemas are up to date.');
