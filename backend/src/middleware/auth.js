import jwt from 'jsonwebtoken';
import { ADMIN_ROLE } from '../util/constants.js';
import { HttpError } from '../util/errors.js';
import { DBClient } from '../util/db.js';

export class AuthMiddleware {

    static verifyToken({ token, secret }) {

        const claims = jwt.verify(token, secret);

        return {
            user: {
                id: claims.sub,
                instituteId: claims.inst,
                domain: claims.dom,
                role: claims.role,
                schema: claims.sch,
            },
            db: DBClient.tenant({ schema: claims.sch }),
        };

    }

    static authenticate({ secret }) {

        return (req, _res, next) => {

            const header = req.get('authorization') ?? '';
            const token = header.startsWith('Bearer ') ? header.slice(7) : '';

            try {
                const { user, db } = AuthMiddleware.verifyToken({ token, secret });
                req.user = user;
                req.db = db;
            } catch {
                next(HttpError.unauthorized({ message: 'Please log in again' }));
                return;
            }

            next();

        };

    }

    static requireRole({ roles }) {

        return (req, _res, next) => {

            if (!roles.includes(req.user.role)) {
                next(HttpError.forbidden());
                return;
            }

            next();

        };

    }

    static requireAdmin({ secret }) {

        return async (req, _res, next) => {

            const header = req.get('authorization') ?? '';
            const token = header.startsWith('Bearer ') ? header.slice(7) : '';

            let claims;
            try {
                claims = jwt.verify(token, secret);
            } catch {
                next(HttpError.unauthorized({ message: 'Please log in again' }));
                return;
            }

            if (claims.role !== ADMIN_ROLE) {
                next(HttpError.unauthorized({ message: 'Please log in again' }));
                return;
            }

            const [admin] = await DBClient.core.select({
                table: 'admin',
                columns: 'id, username, email',
                where: { id: claims.sub },
            });
            if (!admin) {
                next(HttpError.unauthorized({ message: 'Please log in again' }));
                return;
            }

            req.admin = { id: admin.id, username: admin.username, email: admin.email };
            next();

        };

    }

}
