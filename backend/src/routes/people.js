import { Router } from 'express';
import { AuthMiddleware } from '../middleware/auth.js';
import { PeopleService } from '../modules/people.js';
import { Role } from '../util/constants.js';
import { sendResponse } from '../util/response.js';

export function peopleRouter({ mailer }) {

    const router = Router();
    
    const peopleService = new PeopleService({ mailer });

    router.get('/teachers', AuthMiddleware.requireRole({ roles: [Role.DIRECTOR] }), async (req, res) => {

        const data = await peopleService.listTeachers({ db: req.db });
        sendResponse({ res, data });

    });

    router.get('/students', AuthMiddleware.requireRole({ roles: [Role.DIRECTOR] }), async (req, res) => {

        const data = await peopleService.listStudents({ db: req.db, classId: req.query.classId });
        sendResponse({ res, data });

    });

    router.post('/teachers', AuthMiddleware.requireRole({ roles: [Role.DIRECTOR] }), async (req, res) => {

        const data = await peopleService.createTeacher({
            db: req.db,
            domain: req.user.domain,
            name: req.body.name,
            email: req.body.email,
            phone: req.body.phone,
            userName: req.body.userName,
        });
        sendResponse({ res, code: 201, message: 'Teacher created', data });

    });

    router.post('/students', AuthMiddleware.requireRole({ roles: [Role.DIRECTOR, Role.TEACHER] }), async (req, res) => {

        const data = await peopleService.createStudent({
            db: req.db,
            domain: req.user.domain,
            role: req.user.role,
            userId: req.user.id,
            name: req.body.name,
            email: req.body.email,
            phone: req.body.phone,
            userName: req.body.userName,
            currentClass: req.body.currentClass,
        });
        sendResponse({ res, code: 201, message: 'Student created', data });

    });

    return router;

}