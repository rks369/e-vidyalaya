import { HttpError } from '../util/errors.js';

export class RateLimit {

    static #text(value) {

        return String(value ?? '').toLowerCase().slice(0, 128);

    }

    static byIp(req) {

        return req.ip;

    }

    static byUsername(req) {

        return `user:${RateLimit.#text(req.body.username)}`;

    }

    static byIpAndUsername(req) {

        return `${req.ip}|${RateLimit.#text(req.body.username)}`;

    }

    static create({ windowMs, max, key }) {

        const hits = new Map();

        setInterval(() => {

            const now = Date.now();

            for (const [id, entry] of hits) {
                if (entry.resetAt <= now) {
                    hits.delete(id);
                }
            }

        }, windowMs).unref();

        return (req, res, next) => {

            const id = key(req);
            const now = Date.now();
            const entry = hits.get(id);

            if (!entry || entry.resetAt <= now) {
                hits.set(id, { count: 1, resetAt: now + windowMs });
                next();
                return;
            }

            entry.count += 1;

            if (entry.count > max) {
                res.set('Retry-After', String(Math.ceil((entry.resetAt - now) / 1000)));
                next(new HttpError({ status: 429, message: 'Too many attempts, please try again later' }));
                return;
            }

            next();

        };

    }

}
