import { HttpError } from '../util/errors.js';
import { Password } from '../util/password.js';
import { DBClient } from '../util/db.js';
import { Migrator } from '../util/migrate.js';
import { DEFAULT_PROFILE_PICTURE, Role } from '../util/constants.js';
import { Validate } from '../util/validate.js';

export class InstituteService {

    constructor({ mailer }) {

        this.mailer = mailer;

    }

    list() {

        return DBClient.core.select({
            table: 'institute',
            columns: 'id, code, name, domain, address, mobile, email, logo',
            orderBy: 'id',
        });

    }

    async create({ code, name, domain, address, mobile, email, logo }) {

        const institute = {
            code: Validate.code({ value: code }),
            name: Validate.str({ value: name, name: 'name', max: 128 }),
            domain: Validate.domain({ value: domain }),
            address: Validate.str({ value: address, name: 'address' }),
            mobile: Validate.phone({ value: mobile, name: 'mobile' }),
            email: Validate.email({ value: email }),
            logo: Validate.optionalUrl({ value: logo, name: 'logo', max: 512 }),
        };
        const userName = `director@${institute.domain}.evidyalaya.in`;
        const password = Password.randomPassword();
        const passwordHash = await Password.hash({ password });

        try {
            await DBClient.core.transaction({
                work: (client) =>
                    this.#createWithDirector({ client, institute, userName, passwordHash }),
            });
        } catch (err) {
            if (DBClient.isDuplicate({ err })) {
                const field = err.constraint?.includes('code') ? 'code' : 'domain';
                throw new HttpError({ status: 409, message: `That institute ${field} already exists` });
            }
            throw err;
        }

        const emailed = await this.mailer.send({
            to: institute.email,
            subject: 'Director Login Credentials',
            text: `Welcome To E-Vidyalaya.\nDirector Login Credentials. \n\n\nUser Id  : ${userName}  \nPassword : ${password}`,
        });

        return { userName, emailed };

    }

    async #createWithDirector({ client, institute, userName, passwordHash }) {

        const { rows } = await client.query(
            `INSERT INTO institute (code, name, domain, address, mobile, email, logo)
             VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING schema_name`,
            [
                institute.code,
                institute.name,
                institute.domain,
                institute.address,
                institute.mobile,
                institute.email,
                institute.logo,
            ],
        );
        const schema = DBClient.identifier({ name: rows[0].schema_name });

        await Migrator.schema({ client, schema, folder: 'tenant' });
        await client.query(
            `INSERT INTO ${schema}.users
                (name, email, phone, password, username, designation, profile_picture, current_class)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
            [
                'Director',
                institute.email,
                institute.mobile,
                passwordHash,
                userName,
                Role.DIRECTOR,
                DEFAULT_PROFILE_PICTURE,
                -1,
            ],
        );

    }

}