import jwt from 'jsonwebtoken';
import { HttpError } from '../util/errors.js';
import { Password } from '../util/password.js';
import { DBClient } from '../util/db.js';
import { USER_COLUMNS } from '../util/constants.js';
import { ResetCode } from '../util/reset.js';
import { Validate } from '../util/validate.js';

export class AuthService {

    constructor({ config, mailer }) {

        this.config = config;
        this.mailer = mailer;

    }

    async findInstitute({ domain }) {

        const [institute] = await DBClient.core.select({
            table: 'institute',
            columns: 'id, domain, schema_name',
            where: { domain },
        });

        return institute;

    }

    async login({ username, password }) {

        const userName = Validate.str({ value: username, name: 'username', max: 128 }).toLowerCase();
        const userPassword = Validate.str({ value: password, name: 'password', max: 128 });

        const institute = await this.findInstitute({
            domain: Validate.domainOfUsername({ username: userName }),
        });
        if (!institute) {
            throw HttpError.unauthorized({ message: 'Invalid username or password' });
        }

        const [found] = await DBClient.tenant({ schema: institute.schema_name }).select({
            table: 'users',
            columns: `${USER_COLUMNS}, password`,
            where: { username: userName },
        });
        if (!found) {
            throw HttpError.unauthorized({ message: 'Invalid username or password' });
        }

        const matches = await Password.matches({
            password: userPassword,
            storedHash: found.password,
        });
        if (!matches) {
            throw HttpError.unauthorized({ message: 'Invalid username or password' });
        }

        const { password: _hash, ...user } = found;

        return { token: this.#signToken({ user, institute }), user };

    }

    logout() {

        return { ok: true };

    }

    async me({ db, userId }) {

        const [user] = await db.select({
            table: 'users',
            columns: USER_COLUMNS,
            where: { id: userId },
        });
        if (!user) {
            throw HttpError.unauthorized({ message: 'Please log in again' });
        }

        return { user };

    }

    async changePassword({ db, userId, currentPassword, newPassword }) {

        const current = Validate.str({ value: currentPassword, name: 'currentPassword', max: 128 });
        const next = Validate.password({ value: newPassword, name: 'newPassword' });

        const [user] = await db.select({
            table: 'users',
            columns: 'password',
            where: { id: userId },
        });
        if (!user) {
            throw HttpError.notFound({ message: 'No user exists' });
        }

        const matches = await Password.matches({
            password: current,
            storedHash: user.password,
        });
        if (!matches) {
            throw new HttpError({ status: 403, message: 'Current password is wrong' });
        }

        await db.update({
            table: 'users',
            data: { password: await Password.hash({ password: next }) },
            where: { id: userId },
        });

        return { ok: true };

    }

    async forgotPassword({ username }) {

        const userName = Validate.str({ value: username, name: 'username', max: 128 }).toLowerCase();

        const institute = await this.findInstitute({
            domain: Validate.domainOfUsername({ username: userName }),
        });
        if (!institute) {
            return;
        }

        const db = DBClient.tenant({ schema: institute.schema_name });
        const [user] = await db.select({
            table: 'users',
            columns: 'id, email',
            where: { username: userName },
        });
        if (!user) {
            return;
        }

        const code = await ResetCode.issue({ db, table: 'users', id: user.id });
        if (!code) {
            return;
        }

        void this.mailer.send({
            to: user.email,
            subject: 'E-Vidyalaya Password Reset',
            text:
                `Welcome To E-Vidyalaya.\nPassword Reset.\n\n\n` +
                `User Id    : ${userName}\nReset code : ${code}\n\n` +
                `The code works once and expires in ${ResetCode.MINUTES} minutes. ` +
                `If you did not ask for it, you can ignore this email.`,
        });

    }

    async resetPassword({ username, code, newPassword }) {

        const userName = Validate.str({ value: username, name: 'username', max: 128 }).toLowerCase();
        const submitted = Validate.str({ value: code, name: 'code', max: 32 }).toUpperCase();
        const password = Validate.password({ value: newPassword, name: 'newPassword' });

        const institute = await this.findInstitute({
            domain: Validate.domainOfUsername({ username: userName }),
        });
        if (!institute) {
            throw HttpError.badRequest({ message: ResetCode.FAILED_MESSAGE });
        }

        const db = DBClient.tenant({ schema: institute.schema_name });
        const claimed = await ResetCode.verify({
            db,
            table: 'users',
            username: userName,
            code: submitted,
        });
        if (!claimed) {
            throw HttpError.badRequest({ message: ResetCode.FAILED_MESSAGE });
        }

        const [saved] = await db.query({
            sql: `UPDATE users
                  SET password = $1, ${ResetCode.CLEAR}
                  WHERE id = $2 AND reset_code = $3
                  RETURNING id`,
            params: [await Password.hash({ password }), claimed.id, claimed.hash],
        });
        if (!saved) {
            throw HttpError.badRequest({ message: ResetCode.FAILED_MESSAGE });
        }

    }

    #signToken({ user, institute }) {

        return jwt.sign(
            {
                sub: user.id,
                inst: institute.id,
                dom: institute.domain,
                sch: institute.schema_name,
                role: user.designation,
            },
            this.config.jwtSecret,
            { expiresIn: '30d' },
        );

    }

}