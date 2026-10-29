import { Router } from 'express';
import { AdminService } from '../modules/admin.js';
import { InstituteService } from '../modules/institute.js';
import { sendResponse } from '../util/response.js';

export function adminRouter({ mailer, config, requireAdmin }) {

    const router = Router();
    
    const adminService = new AdminService({ config, mailer });
    const instituteService = new InstituteService({ mailer });

    router.post('/login', async (req, res) => {

        const data = await adminService.login({
            username: req.body.username,
            password: req.body.password,
        });
        sendResponse({ res, message: 'Login successful', data });

    });

    router.post('/forgot-password', async (req, res) => {

        await adminService.forgotPassword({ 
            username: req.body.username 
        });
        sendResponse({ res, message: 'If that admin exists, a reset code has been emailed' });

    });

    router.post('/reset-password', async (req, res) => {

        await adminService.resetPassword({
            username: req.body.username,
            code: req.body.code,
            newPassword: req.body.newPassword,
        });
        sendResponse({ res, message: 'Password has been reset' });

    });

    router.get('/me', requireAdmin, (req, res) => {

        sendResponse({ res, data: { admin: req.admin } });

    });

    router.post('/change-password', requireAdmin, async (req, res) => {

        const data = await adminService.changePassword({
            adminId: req.admin.id,
            currentPassword: req.body.currentPassword,
            newPassword: req.body.newPassword,
        });
        sendResponse({ res, message: 'Password changed', data });

    });

    router.get('/institutes', requireAdmin, async (_req, res) => {

        const data = await instituteService.list();
        sendResponse({ res, data });

    });

    router.post('/institutes', requireAdmin, async (req, res) => {

        const data = await instituteService.create({
            code: req.body.code,
            name: req.body.name,
            domain: req.body.domain,
            address: req.body.address,
            mobile: req.body.mobile,
            email: req.body.email,
            logo: req.body.logo,
        });
        sendResponse({ res, code: 201, message: 'Institute created', data });

    });

    return router;

}