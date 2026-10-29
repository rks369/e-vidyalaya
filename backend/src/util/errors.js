export class HttpError extends Error {

    constructor({ status, message }) {

        super(message);
        this.status = status;

    }

    static badRequest({ message }) {

        return new HttpError({
            status: 400,
            message: message,
        });

    }

    static unauthorized({ message = 'Unauthorized' } = {}) {

        return new HttpError({
            status: 401,
            message: message,
        });

    }

    static forbidden({ message = 'Forbidden' } = {}) {

        return new HttpError({
            status: 403,
            message: message,
        });

    }

    static notFound({ message = 'Not found' } = {}) {

        return new HttpError({
            status: 404,
            message: message,
        });

    }

}
