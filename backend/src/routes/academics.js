import { Router } from 'express';
import { AuthMiddleware } from '../middleware/auth.js';
import { AcademicsService } from '../modules/academics.js';
import { UploadService } from '../modules/upload.js';
import { Role } from '../util/constants.js';
import { FileUrl } from '../util/fileUrl.js';
import { sendResponse } from '../util/response.js';

export function academicsRouter({ mailer, config }) {

    const router = Router();
    
    const academicsService = new AcademicsService({ mailer, uploads: new UploadService({ config }) });

    router.get('/classes', AuthMiddleware.requireRole({ roles: [Role.DIRECTOR] }), async (req, res) => {

        const data = await academicsService.listClasses({
            db: req.db 
        });
        sendResponse({ res, data });

    });

    router.post('/classes', AuthMiddleware.requireRole({ roles: [Role.DIRECTOR] }), async (req, res) => {

        const data = await academicsService.addClass({
            db: req.db,
            className: req.body.className,
            teacherId: req.body.teacherId,
        });
        sendResponse({ res, code: 201, message: 'Class created', data });

    });

    router.get('/classes/:classId/subjects', async (req, res) => {

        const data = await academicsService.listClassSubjects({
            db: req.db,
            role: req.user.role,
            userId: req.user.id,
            classId: req.params.classId,
        });
        sendResponse({ res, data });

    });

    router.get('/subjects', AuthMiddleware.requireRole({ roles: [Role.DIRECTOR] }), async (req, res) => {

        const data = await academicsService.listSubjects({ 
            db: req.db 
        });
        sendResponse({ res, data });

    });

    router.post('/subjects', AuthMiddleware.requireRole({ roles: [Role.DIRECTOR] }), async (req, res) => {

        const data = await academicsService.addSubject({
            db: req.db,
            subjectName: req.body.subjectName,
            classId: req.body.classId,
            teacherId: req.body.teacherId,
        });
        sendResponse({ res, code: 201, message: 'Subject created', data });

    });

    router.get('/subjects/:subjectId/notes', async (req, res) => {

        const data = await academicsService.listNotes({
            db: req.db,
            role: req.user.role,
            userId: req.user.id,
            subjectId: req.params.subjectId,
            baseUrl: FileUrl.requestBaseUrl({ config, req }),
        });
        sendResponse({ res, data });

    });

    router.post('/notes', AuthMiddleware.requireRole({ roles: [Role.DIRECTOR, Role.TEACHER] }), async (req, res) => {

        const data = await academicsService.addNote({
            db: req.db,
            role: req.user.role,
            userId: req.user.id,
            instituteId: req.user.instituteId,
            subjectId: req.body.subjectId,
            title: req.body.title,
            ext: req.body.ext,
            url: req.body.url,
            baseUrl: FileUrl.requestBaseUrl({ config, req }),
        });
        sendResponse({ res, code: 201, message: 'Note added', data });

    });

    router.get('/teacher/classes', AuthMiddleware.requireRole({ roles: [Role.TEACHER] }), async (req, res) => {

        const data = await academicsService.teacherClasses({ 
            db: req.db, 
            userId: req.user.id 
        });
        sendResponse({ res, data });

    });

    router.get('/teacher/subjects', AuthMiddleware.requireRole({ roles: [Role.TEACHER] }), async (req, res) => {

        const data = await academicsService.teacherSubjects({ 
            db: req.db, 
            userId: req.user.id 
        });
        sendResponse({ res, data });

    });

    router.get('/teacher/students', AuthMiddleware.requireRole({ roles: [Role.TEACHER] }), async (req, res) => {

        const data = await academicsService.teacherStudents({ 
            db: req.db, 
            userId: req.user.id 
        });
        sendResponse({ res, data });

    });

    return router;

}