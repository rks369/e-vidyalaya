import { DBClient } from '../util/db.js';
import { HttpError } from '../util/errors.js';
import { Role, USER_COLUMNS } from '../util/constants.js';
import { FileUrl } from '../util/fileUrl.js';
import { Validate } from '../util/validate.js';

export class AcademicsService {

    static #CLASS_COLUMNS = 'class_id, class_name, class_teacher_id';
    static #SUBJECT_COLUMNS = 'subject_id, class_id, subject_name, subject_teacher_id';

    constructor({ mailer, uploads }) {

        this.mailer = mailer;
        this.uploads = uploads;

    }

    listClasses({ db }) {

        return db.select({ table: 'class_list', columns: AcademicsService.#CLASS_COLUMNS });

    }

    async addClass({ db, className, teacherId }) {

        const name = Validate.str({ value: className, name: 'className', max: 64 });
        const teacher = await this.#findTeacher({ db, teacherId: Validate.int({ value: teacherId, name: 'teacherId' }) });

        const created = await this.#insertUnique({
            db,
            message: 'That class already exists',
            insert: {
                table: 'class_list',
                columns: ['class_name', 'class_teacher_id'],
                values: [name, teacher.id],
                returning: 'class_id',
            },
        });

        const emailed = await this.mailer.send({
            to: teacher.email,
            subject: `You Are Now Class In-charger Of ${name}`,
            text: `Welcome To E-Vidyalaya.\nYou Are Now Class In-charger Of ${name}`,
        });

        return { classId: created.class_id, emailed };

    }

    async listClassSubjects({ db, role, userId, classId }) {

        const classKey = Validate.int({ value: classId, name: 'classId' });
        await this.#assertCanViewClass({ db, role, userId, classId: classKey });

        return db.select({
            table: 'subject_list',
            columns: AcademicsService.#SUBJECT_COLUMNS,
            where: { class_id: classKey },
        });

    }

    listSubjects({ db }) {

        return db.query({
            sql: `SELECT s.subject_id, s.class_id, s.subject_name, s.subject_teacher_id, c.class_name
                  FROM subject_list s
                  JOIN class_list c ON c.class_id = s.class_id`,
        });

    }

    async addSubject({ db, subjectName, classId, teacherId }) {

        const name = Validate.str({ value: subjectName, name: 'subjectName', max: 64 });
        const classKey = Validate.int({ value: classId, name: 'classId' });
        const teacher = await this.#findTeacher({ db, teacherId: Validate.int({ value: teacherId, name: 'teacherId' }) });

        const [cls] = await db.select({
            table: 'class_list',
            columns: 'class_id',
            where: { class_id: classKey },
        });
        if (!cls) {
            throw HttpError.badRequest({ message: 'Class not found' });
        }

        const created = await this.#insertUnique({
            db,
            message: 'That subject already exists in this class',
            insert: {
                table: 'subject_list',
                columns: ['subject_name', 'class_id', 'subject_teacher_id'],
                values: [name, classKey, teacher.id],
                returning: 'subject_id',
            },
        });

        const emailed = await this.mailer.send({
            to: teacher.email,
            subject: `You Are Now Subject Teacher Of ${name}`,
            text: `Welcome To E-Vidyalaya.\nYou Are Now Subject Teacher Of ${name}`,
        });

        return { subjectId: created.subject_id, emailed };

    }

    async listNotes({ db, role, userId, subjectId, baseUrl }) {

        const subjectKey = Validate.int({ value: subjectId, name: 'subjectId' });

        const [subject] = await db.select({
            table: 'subject_list',
            columns: 'class_id',
            where: { subject_id: subjectKey },
        });
        if (!subject) {
            throw HttpError.notFound({ message: 'Subject not found' });
        }

        await this.#assertCanViewClass({ db, role, userId, classId: subject.class_id });

        const notes = await db.select({
            table: 'notes_list',
            columns: 'note_id, note_title, note_ext, note_url',
            where: { subject_id: subjectKey },
        });

        return notes.map((note) => ({
            ...note,
            note_url: FileUrl.toPublicUrl({ stored: note.note_url, base: baseUrl }),
        }));

    }

    async addNote({ db, role, userId, instituteId, subjectId, title, ext, url, baseUrl }) {

        const subjectKey = Validate.int({ value: subjectId, name: 'subjectId' });
        const noteTitle = Validate.str({ value: title, name: 'title' });
        const noteExt = Validate.str({ value: ext, name: 'ext', max: 16 });
        const rawUrl = Validate.str({ value: url, name: 'url', max: 2048 });

        const storedUrl = FileUrl.toStoredPath({ value: rawUrl, base: baseUrl });

        if (!FileUrl.isLocal({ stored: storedUrl }) && !/^https?:\/\//i.test(storedUrl)) {
            throw HttpError.badRequest({ message: 'url must be http(s)' });
        }

        const [subject] = await db.select({
            table: 'subject_list',
            columns: 'subject_teacher_id',
            where: { subject_id: subjectKey },
        });
        if (!subject) {
            throw HttpError.badRequest({ message: 'Subject not found' });
        }
        if (role === Role.TEACHER && subject.subject_teacher_id !== userId) {
            throw HttpError.forbidden({ message: 'You can only add notes to your own subjects' });
        }

        const noteUrl = FileUrl.isTemp({ stored: storedUrl })
            ? await this.uploads.promote({ stored: storedUrl, instituteId })
            : storedUrl;

        const created = await db.insert({
            table: 'notes_list',
            columns: ['subject_id', 'note_title', 'note_ext', 'note_url'],
            values: [subjectKey, noteTitle, noteExt, noteUrl],
            returning: 'note_id',
        });

        return { noteId: created.note_id };

    }

    teacherClasses({ db, userId }) {

        return db.select({
            table: 'class_list',
            columns: AcademicsService.#CLASS_COLUMNS,
            where: { class_teacher_id: userId },
        });

    }

    teacherSubjects({ db, userId }) {

        return db.select({
            table: 'subject_list',
            columns: AcademicsService.#SUBJECT_COLUMNS,
            where: { subject_teacher_id: userId },
        });

    }

    teacherStudents({ db, userId }) {

        const columns = USER_COLUMNS.split(', ').map((column) => `u.${column}`).join(', ');

        return db.query({
            sql: `SELECT ${columns}
                  FROM users u
                  JOIN class_list c ON c.class_id = u.current_class
                  WHERE c.class_teacher_id = $1`,
            params: [userId],
        });

    }

    async #assertCanViewClass({ db, role, userId, classId }) {

        if (role === Role.DIRECTOR) {
            return;
        }

        if (role === Role.STUDENT) {
            const [me] = await db.select({
                table: 'users',
                columns: 'current_class',
                where: { id: userId },
            });
            if (me?.current_class === classId) {
                return;
            }
        }

        if (role === Role.TEACHER) {
            const [asClassTeacher] = await db.select({
                table: 'class_list',
                columns: 'class_id',
                where: { class_id: classId, class_teacher_id: userId },
            });
            if (asClassTeacher) {
                return;
            }

            const [asSubjectTeacher] = await db.select({
                table: 'subject_list',
                columns: 'subject_id',
                where: { class_id: classId, subject_teacher_id: userId },
            });
            if (asSubjectTeacher) {
                return;
            }
        }

        throw HttpError.forbidden({ message: 'You cannot view this class' });

    }

    async #insertUnique({ db, insert, message }) {

        try {
            return await db.insert(insert);
        } catch (err) {
            if (DBClient.isDuplicate({ err })) {
                throw new HttpError({ status: 409, message });
            }
            throw err;
        }

    }

    async #findTeacher({ db, teacherId }) {

        const [teacher] = await db.select({
            table: 'users',
            columns: 'id, email',
            where: { id: teacherId, designation: Role.TEACHER },
        });
        if (!teacher) {
            throw HttpError.badRequest({ message: 'Teacher not found' });
        }

        return teacher;

    }

}