import { createInterface } from 'node:readline/promises';
import { Writable } from 'node:stream';
import { AdminService } from '../src/modules/admin.js';
import { Config } from '../src/util/config.js';
import { DBClient } from '../src/util/db.js';
import { HttpError } from '../src/util/errors.js';

let muted = false;

const output = new Writable({
    write(chunk, _encoding, callback) {

        if (!muted) {
            process.stdout.write(chunk);
        }
        callback();
    },
});

const rl = createInterface({
    input: process.stdin,
    output,
    terminal: Boolean(process.stdin.isTTY),
});

const lines = rl[Symbol.asyncIterator]();

async function ask({ question, hidden = false }) {

    process.stdout.write(question);
    muted = hidden;
    const { value, done } = await lines.next();
    muted = false;

    if (hidden) {
        process.stdout.write('\n');

    }

    if (done) {
        throw new Error('The input ended before every question was answered');
    }

    return value;

}

async function main() {

    const [usernameArg, emailArg, passwordArg,confirmationArg] = process.argv.slice(2);

    const username = usernameArg ?? (await ask({ question: 'Admin username: ' }));
    const email = emailArg ?? (await ask({ question: 'Admin email: ' }));
    const password = passwordArg ?? await ask({ question: 'Password: ', hidden: true })
    const confirmation = confirmationArg ?? await ask({ question: 'Confirm password: ', hidden: true });

    if (password !== confirmation) {
        throw new Error('The passwords do not match');
    }

    const config = new Config();
    DBClient.connect(config.db);

    const admin = await new AdminService({ config }).create({ username, email, password });

    console.log(`Admin "${admin.username}" <${admin.email}> created (id ${admin.id}).`);

}

try {
    await main();
} catch (err) {
    if (err instanceof HttpError) {
        console.error(err.message);
    } else if (err.code === '42P01' || err.code === '3F000') {
        console.error('The admin table does not exist yet. Run "npm run migrate" first.');
    } else {
        console.error(`Could not create the admin: ${err.message}`);
    }
    process.exitCode = 1;
} finally {
    rl.close();
    await DBClient.close();
}
