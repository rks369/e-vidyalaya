import { createServer } from 'node:http';
import { Server } from 'socket.io';
import { createApp } from './src/app.js';
import { HealthService } from './src/modules/health.js';
import { ChatSocket } from './src/sockets/chat.js';
import { Config } from './src/util/config.js';
import { DBClient } from './src/util/db.js';
import { Mailer } from './src/util/mailer.js';

const SHUTDOWN_TIMEOUT_MS = 10000;

const config = new Config();
DBClient.connect(config.db);

const app = createApp({ mailer: new Mailer(config.mail), config });
const httpServer = createServer(app);
const io = new Server(httpServer, { cors: { origin: '*' } });

new ChatSocket({ io, config }).register();

httpServer.listen(config.port, () => {

    console.log(`API listening on :${config.port}`);

});

let shuttingDown = false;

function shutdown({ signal }) {

    if (shuttingDown) {
        return;
    }
    shuttingDown = true;
    HealthService.draining = true;

    console.log(`${signal} received, finishing open requests`);
    setTimeout(() => process.exit(1), SHUTDOWN_TIMEOUT_MS).unref();

    io.close(async () => {

        await DBClient.close();
        process.exit(0);

    });
    httpServer.closeIdleConnections();

}

process.on('SIGTERM', () => shutdown({ signal: 'SIGTERM' }));
process.on('SIGINT', () => shutdown({ signal: 'SIGINT' }));
