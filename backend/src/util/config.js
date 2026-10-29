import { fileURLToPath } from 'node:url';

export class Config {

    static #REQUIRED = [
        'DB_HOST',
        'DB_USER',
        'DB_PASSWORD',
        'DB_NAME',
        'JWT_SECRET',
    ];

    constructor({ env = process.env } = {}) {

        const missing = Config.#REQUIRED.filter((key) => !env[key]);

        if (missing.length) {
            throw new Error(`Missing environment variables: ${missing.join(', ')}`);
        }

        const secret = env.JWT_SECRET;

        this.port = Number(env.PORT) || 3000;

        this.db = {
            host: env.DB_HOST,
            port: Number(env.DB_PORT) || 5432,
            user: env.DB_USER,
            password: env.DB_PASSWORD,
            database: env.DB_NAME,
            ssl: env.DB_SSL !== 'false',
        };

        this.uploadDir = env.UPLOAD_DIR || fileURLToPath(new URL('../../public/uploads', import.meta.url));
        this.tempDir = env.TEMP_DIR || fileURLToPath(new URL('../../public/temp', import.meta.url));
        this.tempMaxAgeMs = (Number(env.TEMP_MAX_AGE_HOURS) || 24) * 60 * 60 * 1000;
        this.maxUploadBytes = (Number(env.MAX_UPLOAD_MB) || 50) * 1024 * 1024;
        this.publicBaseUrl = (env.PUBLIC_BASE_URL ?? '').replace(/\/$/, '');

        this.jwtSecret = secret;

        this.limits = {
            ip: { windowMs: 15 * 60 * 1000, max: 3000 },
            login: { windowMs: 15 * 60 * 1000, max: 10 },
            forgot: { windowMs: 15 * 60 * 1000, max: 3 },
            forgotPerUser: { windowMs: 60 * 60 * 1000, max: 5 },
            reset: { windowMs: 15 * 60 * 1000, max: 10 },
            chat: { windowMs: 10 * 1000, max: 20 },
        };

        this.mail = {
            host: env.SMTP_HOST ?? '',
            port: Number(env.SMTP_PORT) || 587,
            secure: env.SMTP_SECURE === 'true',
            user: env.SMTP_USER ?? '',
            pass: env.SMTP_PASS ?? '',
            fromEmail: env.MAIL_FROM ?? '',
            fromName: env.MAIL_FROM_NAME || 'E-Vidyalaya',
        };

    }

}
