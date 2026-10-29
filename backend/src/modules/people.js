import { HttpError } from '../util/errors.js';
import { Password } from '../util/password.js';
import { DBClient } from '../util/db.js';
import { DEFAULT_PROFILE_PICTURE, Role, USER_COLUMNS } from '../util/constants.js';
import { Validate } from '../util/validate.js';

export class PeopleService {

    constructor({ mailer }) {

        this.mailer = mailer;

    }

    listTeachers({ db }) {

        return db.select({
            table: 'users',
            columns: USER_COLUMNS,
            where: { designation: Role.TEACHER },
        });

    }

    listStudents({ db, classId }) {

        const where = { designation: Role.STUDENT };

        if (classId !== undefined) {
            where.current_class = Validate.int({ value: classId, name: 'classId' });
        }

        return db.select({ table: 'users', columns: USER_COLUMNS, where });

    }

    createTeacher({ db, domain, name, email, phone, userName }) {

        return this.#createUser({
            db,
            domain,
            name,
            email,
            phone,
            userName,
            designation: Role.TEACHER,
            currentClass: -1,
        });

    }

    async createStudent({ db, domain, role, userId, name, email, phone, userName, currentClass }) {

        const classId = Validate.int({ value: currentClass, name: 'currentClass' });

        const [cls] = await db.select({
            table: 'class_list',
            columns: 'class_teacher_id',
            where: { class_id: classId },
        });
        if (!cls) {
            throw HttpError.badRequest({ message: 'Class not found' });
        }
        if (role === Role.TEACHER && cls.class_teacher_id !== userId) {
            throw HttpError.forbidden({ message: 'You can only add students to your own class' });
        }

        return this.#createUser({
            db,
            domain,
            name,
            email,
            phone,
            userName,
            designation: Role.STUDENT,
            currentClass: classId,
        });

    }

    async #createUser({ db, domain, name, email, phone, userName, designation, currentClass }) {

        const fullName = Validate.str({ value: name, name: 'name', max: 128 });
        const userEmail = Validate.email({ value: email });
        const userPhone = Validate.phone({ value: phone });
        const username = Validate.str({ value: userName, name: 'userName', max: 128 }).toLowerCase();

        if (Validate.domainOfUsername({ username }) !== domain || /^@|\s/.test(username)) {
            throw HttpError.badRequest({ message: `userName must be of the form name@${domain}` });
        }

        const password = Password.randomPassword();

        try {
            await db.insert({
                table: 'users',
                columns: [
                    'name',
                    'email',
                    'phone',
                    'password',
                    'username',
                    'designation',
                    'profile_picture',
                    'current_class',
                ],
                values: [
                    fullName,
                    userEmail,
                    userPhone,
                    await Password.hash({ password }),
                    username,
                    designation,
                    DEFAULT_PROFILE_PICTURE,
                    currentClass,
                ],
            });
        } catch (err) {
            if (DBClient.isDuplicate({ err })) {
                throw new HttpError({ status: 409, message: 'That user id already exists' });
            }
            throw err;
        }

        const emailed = await this.mailer.send({
            to: userEmail,
            subject: `${designation} Login Credentials`,
            text: `Welcome To E-Vidyalaya.\n${designation} Login Credentials. \n\n\nUser Id  : ${username}  \nPassword : ${password}`,
        });

        return { userName: username, emailed };

    }

}