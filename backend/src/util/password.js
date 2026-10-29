import { randomBytes, randomInt, scrypt, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';

export class Password {

    static #scryptAsync = promisify(scrypt);

    static #KEY_LENGTH = 64;

    static #CODE_ALPHABET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

    static #LOWER = 'abcdefghijklmnopqrstuvwxyz';

    static #UPPER = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    static #DIGITS = '0123456789';

    static async hash({ password }) {

        const salt = randomBytes(16).toString('hex');
        const key = await Password.#scryptAsync(password, salt, Password.#KEY_LENGTH);

        return `${salt}:${key.toString('hex')}`;

    }

    static async matches({ password, storedHash }) {

        const [salt, hash] = String(storedHash).split(':');
        const expected = Buffer.from(hash ?? '', 'hex');

        if (!salt || expected.length !== Password.#KEY_LENGTH) {
            return false;
        }

        const actual = await Password.#scryptAsync(password, salt, Password.#KEY_LENGTH);

        return timingSafeEqual(expected, actual);

    }

    static randomCode({ length = 8 } = {}) {

        let code = '';

        for (let i = 0; i < length; i++) {
            code += Password.#CODE_ALPHABET[randomInt(Password.#CODE_ALPHABET.length)];
        }

        return code;

    }

    static randomPassword({ length = 10 } = {}) {

        const all = Password.#LOWER + Password.#UPPER + Password.#DIGITS;
        const pick = (set) => {

            return set[randomInt(set.length)];

        };
        const chars = [pick(Password.#LOWER), pick(Password.#UPPER), pick(Password.#DIGITS)];

        while (chars.length < length) {
            chars.push(pick(all));
        }

        for (let i = chars.length - 1; i > 0; i--) {
            const j = randomInt(i + 1);
            [chars[i], chars[j]] = [chars[j], chars[i]];
        }

        return chars.join('');

    }

}
