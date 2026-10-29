import { DBClient } from '../util/db.js';

export class HealthService {

    live() {

        return { 
            uptime: Math.round(process.uptime())
        };

    }

    async ready() {

        try {
            await DBClient.core.query({ sql: 'SELECT 1 FROM institute LIMIT 1' });
            return true;
        } catch (err) {
            console.error('[ready] database check failed:', err.message);
            return false;
        }

    }

}