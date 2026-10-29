import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import multer from 'multer';
import { AuthMiddleware } from './middleware/auth.js';
import { RateLimit } from './middleware/rateLimit.js';
import { academicsRouter } from './routes/academics.js';
import { adminRouter } from './routes/admin.js';
import { authRouter } from './routes/auth.js';
import { chatRouter } from './routes/chat.js';
import { healthRouter } from './routes/health.js';
import { peopleRouter } from './routes/people.js';
import { uploadsRouter } from './routes/uploads.js';
import { HttpError } from './util/errors.js';
import { sendResponse } from './util/response.js';

export function createApp({ mailer, config }) {

    const app = express();
    app.set('trust proxy', 1);
    app.use(helmet());
    app.use(cors());
    app.use(express.json({ limit: '100kb' }));

    app.use((req, _res, next) => {

        req.body ??= {};
        next();

    });

    const authenticateRequest = AuthMiddleware.authenticate({ secret: config.jwtSecret });
    const deps = {
        mailer,
        config,
        authenticate: authenticateRequest,
        requireAdmin: AuthMiddleware.requireAdmin({ secret: config.jwtSecret }),
    };

    app.use(healthRouter());

    app.use(
        '/assets',
        express.static(config.uploadDir, {
            index: false,
            setHeaders: (res) => res.set('Cross-Origin-Resource-Policy', 'cross-origin'),
        }),
    );

    const { limits } = config;
    const perIp = RateLimit.create({ ...limits.ip, key: RateLimit.byIp });
    const loginLimit = RateLimit.create({ ...limits.login, key: RateLimit.byIpAndUsername });
    const forgotLimit = RateLimit.create({ ...limits.forgot, key: RateLimit.byIpAndUsername });
    const forgotPerUserLimit = RateLimit.create({ ...limits.forgotPerUser, key: RateLimit.byUsername });
    const resetLimit = RateLimit.create({ ...limits.reset, key: RateLimit.byIpAndUsername });

    app.post(['/auth/login', '/admin/login'], perIp, loginLimit);
    app.post(['/auth/forgot-password', '/admin/forgot-password'], perIp, forgotLimit, forgotPerUserLimit);
    app.post(['/auth/reset-password', '/admin/reset-password'], perIp, resetLimit);

    app.use('/auth', authRouter(deps));
    app.use('/admin', adminRouter(deps));

    app.use(authenticateRequest);

    app.use(uploadsRouter(deps));
    app.use(chatRouter(deps));
    app.use(peopleRouter(deps));
    app.use(academicsRouter(deps));

    app.use((_req, _res, next) => next(new HttpError({ status: 404, message: 'Not found' })));

    app.use((err, _req, res, _next) => {

        if (err instanceof HttpError) {
            return sendResponse({ res, status: false, code: err.status, message: err.message });
        }

        if (err instanceof multer.MulterError) {
            const tooLarge = err.code === 'LIMIT_FILE_SIZE';
            return sendResponse({
                res,
                status: false,
                code: tooLarge ? 413 : 400,
                message: tooLarge ? 'File is too large' : err.message,
            });
        }

        if (err.type === 'entity.parse.failed') {
            return sendResponse({ res, status: false, code: 400, message: 'Invalid JSON' });
        }

        if (err.type === 'entity.too.large') {
            return sendResponse({ res, status: false, code: 413, message: 'Request body is too large' });
        }

        if (Number.isInteger(err.status) && err.status >= 400 && err.status < 500 && err.expose) {
            return sendResponse({ res, status: false, code: err.status, message: err.message });
        }

        console.error(err);
        return sendResponse({ res, status: false, code: 500, message: 'Something went wrong' });

    });

    return app;

}
