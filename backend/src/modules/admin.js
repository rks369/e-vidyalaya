import jwt from 'jsonwebtoken';
import { HttpError } from '../util/errors.js';
import { ADMIN_ROLE } from '../util/constants.js';
import { DBClient } from '../util/db.js';
import { Password } from '../util/password.js';
import { ResetCode } from '../util/reset.js';
import { Validate } from '../util/validate.js';

export class AdminService {

    static #USERNAME = /^[a-z0-9._-]{3,64}$/;

    constructor({ config, mailer }) {

        this.config = config;
        this.mailer = mailer;

    }

    async create({ username, email, password }) {

        const name = this.#username({ value: username });
        const address = Validate.email({ value: email }).toLowerCase();
        const secret = Validate.password({ value: password });

        try {
            return await DBClient.core.insert({
                table: 'admin',
                columns: ['username', 'email', 'password'],
                values: [name, address, await Password.hash({ password: secret })],
                returning: 'id, username, email',
            });
        } catch (err) {
            if (DBClient.isDuplicate({ err })) {
                const field = err.constraint?.includes('email') ? 'email' : 'username';
                throw new HttpError({ status: 409, message: `That admin ${field} already exists` });
            }
            throw err;
        }

    }

    async login({ username, password }) {

        const name = Validate.str({ value: username, name: 'username', max: 64 }).toLowerCase();
        const secret = Validate.str({ value: password, name: 'password', max: 128 });

        const [found] = await DBClient.core.select({
            table: 'admin',
            columns: 'id, username, email, password',
            where: { username: name },
        });
        if (!found) {
            throw HttpError.unauthorized({ message: 'Invalid username or password' });
        }

        const matches = await Password.matches({ password: secret, storedHash: found.password });
        if (!matches) {
            throw HttpError.unauthorized({ message: 'Invalid username or password' });
        }

        return {
            token: this.#signToken({ admin: found }),
            admin: { id: found.id, username: found.username, email: found.email },
        };

    }

    async forgotPassword({ username }) {

        const name = Validate.str({ value: username, name: 'username', max: 64 }).toLowerCase();

        const [admin] = await DBClient.core.select({
            table: 'admin',
            columns: 'id, username, email',
            where: { username: name },
        });
        if (!admin) {
            return;
        }

        const code = await ResetCode.issue({ db: DBClient.core, table: 'admin', id: admin.id });
        if (!code) {
            return;
        }

        void this.mailer.send({
            to: admin.email,
            subject: 'E-Vidyalaya Admin Password Reset',
            text:
                `Welcome To E-Vidyalaya.\nAdmin Password Reset.\n\n\n` +
                `User Id    : ${admin.username}\nReset code : ${code}\n\n` +
                `The code works once and expires in ${ResetCode.MINUTES} minutes. ` +
                `If you did not ask for it, you can ignore this email.`,
        });

    }

    async resetPassword({ username, code, newPassword }) {

        const name = Validate.str({ value: username, name: 'username', max: 64 }).toLowerCase();
        const submitted = Validate.str({ value: code, name: 'code', max: 32 }).toUpperCase();
        const password = Validate.password({ value: newPassword, name: 'newPassword' });

        const claimed = await ResetCode.verify({
            db: DBClient.core,
            table: 'admin',
            username: name,
            code: submitted,
        });
        if (!claimed) {
            throw HttpError.badRequest({ message: ResetCode.FAILED_MESSAGE });
        }

        const saved = await this.#savePassword({
            adminId: claimed.id,
            password,
            resetHash: claimed.hash,
        });
        if (!saved) {
            throw HttpError.badRequest({ message: ResetCode.FAILED_MESSAGE });
        }

    }

    async changePassword({ adminId, currentPassword, newPassword }) {

        const current = Validate.str({ value: currentPassword, name: 'currentPassword', max: 128 });
        const password = Validate.password({ value: newPassword, name: 'newPassword' });

        const [admin] = await DBClient.core.select({
            table: 'admin',
            columns: 'id, username, password',
            where: { id: adminId },
        });
        if (!admin) {
            throw HttpError.unauthorized({ message: 'Please log in again' });
        }

        const matches = await Password.matches({ password: current, storedHash: admin.password });
        if (!matches) {
            throw new HttpError({ status: 403, message: 'Current password is wrong' });
        }

        await this.#savePassword({ adminId: admin.id, password, resetHash: null });

        return { ok: true };

    }

    async #savePassword({ adminId, password, resetHash }) {

        const [saved] = await DBClient.core.query({
            sql: `UPDATE admin
                  SET password = $1, ${ResetCode.CLEAR}
                  WHERE id = $2 AND ($3::text IS NULL OR reset_code = $3)
                  RETURNING id`,
            params: [await Password.hash({ password }), adminId, resetHash],
        });

        return Boolean(saved);

    }

    #username({ value }) {

        const name = Validate.str({ value, name: 'username', max: 64 }).toLowerCase();

        if (!AdminService.#USERNAME.test(name)) {
            throw HttpError.badRequest({
                message: 'username must be 3-64 letters, digits, dots, dashes or underscores',
            });
        }

        return name;

    }

    #signToken({ admin }) {

        return jwt.sign(
            { sub: admin.id, role: ADMIN_ROLE, username: admin.username },
            this.config.jwtSecret,
            { expiresIn: '12h' },
        );

    }

}