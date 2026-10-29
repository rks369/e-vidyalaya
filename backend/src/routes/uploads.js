import { Router } from 'express';
import { AuthMiddleware } from '../middleware/auth.js';
import { UploadService } from '../modules/upload.js';
import { Uploader } from '../middleware/uploader.js';
import { Role } from '../util/constants.js';
import { sendResponse } from '../util/response.js';

export function uploadsRouter({ config }) {

    const router = Router();
    
    const uploadService = new UploadService({ config });

    const uploader = Uploader.create({ 
        dir: config.tempDir,
        maxBytes: config.maxUploadBytes 
    });

    router.post(
        '/uploads',
        AuthMiddleware.requireRole({ roles: [Role.DIRECTOR, Role.TEACHER] }),
        uploader.single('file'),
        (req, res) => {

            const data = uploadService.describe({
                file: req.file,
                protocol: req.protocol,
                host: req.get('host'),
                instituteId: req.user.instituteId,
            });
            sendResponse({ res, code: 201, message: 'File uploaded', data });

        },
    );

    return router;

}