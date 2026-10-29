import { HttpError } from '../util/errors.js';
import { Role } from '../util/constants.js';
import { Validate } from '../util/validate.js';

export class ChatService {

    static #PAGE_SIZE = 100;
    static #MESSAGE_COLUMNS = 'id, sender_id, sender_name, body, creation_ts AS created_at';

    async messages({ db, userId, role, kind, targetId, after }) {

        const { key } = await this.#openChat({ db, userId, role, kind, targetId });

        if (after !== undefined) {
            return db.query({
                sql: `SELECT ${ChatService.#MESSAGE_COLUMNS} FROM messages
                      WHERE chat_key = $1 AND id > $2
                      ORDER BY id ASC LIMIT $3`,
                params: [key, Validate.int({ value: after, name: 'after' }), ChatService.#PAGE_SIZE],
            });
        }

        const latest = await db.select({
            table: 'messages',
            columns: ChatService.#MESSAGE_COLUMNS,
            where: { chat_key: key },
            orderBy: 'id DESC',
            limit: ChatService.#PAGE_SIZE,
        });

        return latest.reverse();

    }

    async join({ db, userId, role, kind, targetId }) {

        const { key } = await this.#openChat({ db, userId, role, kind, targetId });

        return { key };

    }

    async send({ db, userId, role, kind, targetId, body }) {

        const text = Validate.str({ value: body, name: 'body', max: 2000 });
        const { key, me } = await this.#openChat({ db, userId, role, kind, targetId });

        const message = await db.insert({
            table: 'messages',
            columns: ['chat_key', 'sender_id', 'sender_name', 'body'],
            values: [key, userId, me.name, text],
            returning: ChatService.#MESSAGE_COLUMNS,
        });

        return { key, message };

    }

    async #openChat({ db, userId, role, kind, targetId }) {

        const target = Validate.int({ value: targetId, name: 'id' });

        const [me] = await db.select({
            table: 'users',
            columns: 'name, current_class',
            where: { id: userId },
        });
        if (!me) {
            throw HttpError.forbidden({ message: 'Please log in again' });
        }

        let classId;
        let subject;

        switch (kind) {
            case 'user': {
                if (target === userId) {
                    throw HttpError.badRequest({ message: 'You cannot chat with yourself' });
                }

                const [other] = await db.select({
                    table: 'users',
                    columns: 'id',
                    where: { id: target },
                });
                if (!other) {
                    throw HttpError.notFound({ message: 'User not found' });
                }

                return { key: `user:${Math.min(userId, target)}:${Math.max(userId, target)}`, me };
            }
            case 'class':
                classId = target;
                break;
            case 'subject':
                [subject] = await db.select({
                    table: 'subject_list',
                    columns: 'class_id, subject_teacher_id',
                    where: { subject_id: target },
                });
                if (!subject) {
                    throw HttpError.notFound({ message: 'Subject not found' });
                }
                classId = subject.class_id;
                break;
            default:
                throw HttpError.badRequest({ message: 'Unknown chat type' });
        }

        const [cls] = await db.select({
            table: 'class_list',
            columns: 'class_teacher_id',
            where: { class_id: classId },
        });
        if (!cls) {
            throw HttpError.notFound({ message: 'Class not found' });
        }

        const isMember =
            role === Role.DIRECTOR ||
            cls.class_teacher_id === userId ||
            subject?.subject_teacher_id === userId ||
            (role === Role.STUDENT && me.current_class === classId);
        if (!isMember) {
            throw HttpError.forbidden({ message: 'You are not part of this chat' });
        }

        return { key: `${kind}:${target}`, me };

    }

}