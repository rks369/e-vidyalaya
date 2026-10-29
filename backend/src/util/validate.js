import { HttpError } from './errors.js';

export class Validate {

    static #INT_MIN = -2147483648;

    static #INT_MAX = 2147483647;

    static #MIN_PASSWORD_LENGTH = 8;

    static str({ value, name, max = 255 }) {

        if (typeof value !== 'string' || value.trim() === '') {
            throw HttpError.badRequest({ message: `${name} is required` });
        }

        const trimmed = value.trim();

        if (trimmed.length > max) {
            throw HttpError.badRequest({ message: `${name} is too long` });
        }

        if (trimmed.includes('\u0000')) {
            throw HttpError.badRequest({ message: `${name} contains invalid characters` });
        }

        return trimmed;

    }

    static optionalStr({ value, name, max = 255 }) {

        if (value === undefined || value === null || value === '') {
            return '';
        }

        return Validate.str({ value, name, max });

    }

    static optionalUrl({ value, name, max = 512 }) {

        const trimmed = Validate.optionalStr({ value, name, max });

        if (trimmed === '') {
            return '';
        }

        let protocol;
        try {
            ({ protocol } = new URL(trimmed));
        } catch {
            protocol = '';
        }

        if (protocol !== 'http:' && protocol !== 'https:') {
            throw HttpError.badRequest({ message: `${name} must be an http(s) URL` });
        }

        return trimmed;

    }

    static password({ value, name = 'password' }) {

        const trimmed = Validate.str({ value, name, max: 128 });

        if (trimmed.length < Validate.#MIN_PASSWORD_LENGTH) {
            throw HttpError.badRequest({
                message: `${name} must be at least ${Validate.#MIN_PASSWORD_LENGTH} characters`,
            });
        }

        return trimmed;

    }

    static int({ value, name }) {

        const number = typeof value === 'string' && value.trim() !== '' ? Number(value) : value;

        if (!Number.isInteger(number)) {
            throw HttpError.badRequest({ message: `${name} must be an integer` });
        }

        if (number < Validate.#INT_MIN || number > Validate.#INT_MAX) {
            throw HttpError.badRequest({ message: `${name} is out of range` });
        }

        return number;

    }

    static email({ value, name = 'email' }) {

        const trimmed = Validate.str({ value, name, max: 128 });

        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(trimmed)) {
            throw HttpError.badRequest({ message: `${name} is invalid` });
        }

        return trimmed;

    }

    static phone({ value, name = 'phone' }) {

        const trimmed = Validate.str({ value, name, max: 15 });

        if (!/^[0-9+\- ]{6,15}$/.test(trimmed)) {
            throw HttpError.badRequest({ message: `${name} is invalid` });
        }

        return trimmed;

    }

    static domain({ value, name = 'domain' }) {

        const lowered = Validate.str({ value, name, max: 30 }).toLowerCase();

        if (!/^[a-z0-9]{2,30}$/.test(lowered)) {
            throw HttpError.badRequest({ message: `${name} must be 2-30 lowercase letters or digits` });
        }

        return lowered;

    }

    static code({ value, name = 'code' }) {

        const upper = Validate.str({ value, name, max: 30 }).toUpperCase();

        if (!/^[A-Z0-9]{2,30}$/.test(upper)) {
            throw HttpError.badRequest({ message: `${name} must be 2-30 letters or digits` });
        }

        return upper;

    }

    static domainOfUsername({ username }) {

        const at = username.indexOf('@');

        return at < 0 ? '' : username.slice(at + 1).split('.')[0];

    }

}
