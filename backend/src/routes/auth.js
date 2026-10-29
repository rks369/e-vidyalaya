import { Router } from 'express';
import { AuthService } from '../modules/auth.js';
import { sendResponse } from '../util/response.js';

export function authRouter({ mailer, config, authenticate }) {

    const router = Router();
    
    const authService = new AuthService({ config, mailer });

    router.post('/login', async (req, res) => {

        const data = await authService.login({
            username: req.body.username,
            password: req.body.password,
        });
        sendResponse({ res, message: 'Login successful', data });

    });

    router.post('/logout', authenticate, (_req, res) => {

        authService.logout();
        sendResponse({ res, message: 'Logged out successfully' });

    });

    router.get('/me', authenticate, async (req, res) => {

        const data = await authService.me({ 
            db: req.db,
            userId: req.user.id 
        });
        sendResponse({ res, data });

    });

    router.post('/change-password', authenticate, async (req, res) => {

        await authService.changePassword({
            db: req.db,
            userId: req.user.id,
            currentPassword: req.body.currentPassword,
            newPassword: req.body.newPassword,
        });
        sendResponse({ res, message: 'Password changed successfully' });

    });

    router.post('/forgot-password', async (req, res) => {

        await authService.forgotPassword({ 
            username: req.body.username 
        });
        sendResponse({ res, message: 'If that user exists, a reset code has been emailed' });

    });

    router.post('/reset-password', async (req, res) => {

        await authService.resetPassword({
            username: req.body.username,
            code: req.body.code,
            newPassword: req.body.newPassword,
        });
        sendResponse({ res, message: 'Password has been reset' });

    });

    return router;

}