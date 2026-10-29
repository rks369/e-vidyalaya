export class FileUrl {

    static #ASSETS_PREFIX = '/assets/';

    static #TEMP_PREFIX = '/temp/';

    static requestBaseUrl({ config, req }) {

        return config.publicBaseUrl || `${req.protocol}://${req.get('host')}`;

    }

    static toStoredPath({ value, base }) {

        try {
            const { origin, pathname } = new URL(value);

            return origin === new URL(base).origin && FileUrl.isLocal({ stored: pathname }) ? pathname : value;
        } catch {
            return value;
        }

    }

    static toPublicUrl({ stored, base }) {

        return stored.startsWith('/') ? `${base}${stored}` : stored;

    }

    static isTemp({ stored }) {

        return stored.startsWith(FileUrl.#TEMP_PREFIX);

    }

    static isLocal({ stored }) {

        return stored.startsWith(FileUrl.#ASSETS_PREFIX) || FileUrl.isTemp({ stored });

    }

}
