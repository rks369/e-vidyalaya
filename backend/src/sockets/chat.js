import { AuthMiddleware } from '../middleware/auth.js';
import { ChatService } from '../modules/chat.js';
import { HttpError } from '../util/errors.js';

export class ChatSocket {

    constructor({ io, config }) {

        this.io = io;
        this.config = config;
        this.chatService = new ChatService();
        this.recentSends = new Map();

    }

    register() {

        this.io.use((socket, next) => {

            try {
                const { user, db } = AuthMiddleware.verifyToken({
                    token: socket.handshake.auth?.token,
                    secret: this.config.jwtSecret,
                });
                socket.data.user = user;
                socket.data.db = db;
            } catch {
                next(new Error('Please log in again'));
                return;
            }

            next();

        });

        this.io.on('connection', (socket) => {

            socket.on('chat:join', (payload, ack) => {

                this.#handle({ ack, work: () => this.#join({ socket, payload }) });

            });

            socket.on('chat:leave', (payload, ack) => {

                this.#handle({ ack, work: () => this.#leave({ socket, payload }) });

            });

            socket.on('chat:send', (payload, ack) => {

                this.#handle({ ack, work: () => this.#send({ socket, payload }) });

            });

        });

    }

    async #join({ socket, payload }) {

        const { key } = await this.#access({ socket, payload });
        
        await socket.join(this.#room({ socket, key }));

        return { key };

    }

    async #leave({ socket, payload }) {

        const { key } = await this.#access({ socket, payload });
        await socket.leave(this.#room({ socket, key }));

        return { key };

    }

    async #send({ socket, payload }) {

        const { kind, id, body } = payload ?? {};
        const { user, db } = socket.data;

        this.#throttle({ user });

        const { key, message } = await this.chatService.send({
            db,
            userId: user.id,
            role: user.role,
            kind,
            targetId: id,
            body,
        });

        const room = this.#room({ socket, key });
        await socket.join(room);
        this.io.to(room).emit('chat:message', { key, message });

        return { key, message };

    }

    #throttle({ user }) {

        const { windowMs, max } = this.config.limits.chat;
        const key = `${user.schema}|${user.id}`;
        const now = Date.now();
        const recent = (this.recentSends.get(key) ?? []).filter((time) => now - time < windowMs);

        if (recent.length >= max) {
            this.recentSends.set(key, recent);
            throw new HttpError({ status: 429, message: 'You are sending messages too fast' });
        }

        recent.push(now);
        this.recentSends.set(key, recent);

    }

    #access({ socket, payload }) {

        const { kind, id } = payload ?? {};
        const { user, db } = socket.data;

        return this.chatService.join({
            db,
            userId: user.id,
            role: user.role,
            kind,
            targetId: id,
        });

    }

    #room({ socket, key }) {

        return `${socket.data.user.schema}|${key}`;

    }

    async #handle({ ack, work }) {

        const reply = typeof ack === 'function' ? ack : () => {};

        try {
            reply({ status: true, data: await work() });
        } catch (err) {
            if (err instanceof HttpError) {
                reply({ status: false, message: err.message });
                return;
            }

            console.error(err);
            reply({ status: false, message: 'Something went wrong' });
        }

    }

}