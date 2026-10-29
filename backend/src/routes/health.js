import { Router } from 'express';
import { HealthService } from '../modules/health.js';
import { sendResponse } from '../util/response.js';

export function healthRouter() {

    const router = Router();
    
    const healthService = new HealthService();

    router.get('/health', (_req, res) => {

        sendResponse({ res, message: 'Healthy', data: healthService.live() });

    });

    router.get('/ready', async (_req, res) => {

        const ready = await healthService.ready();

        if (!ready) {
            sendResponse({ res, status: false, code: 503, message: 'Not ready' });
            return;
        }

        sendResponse({ res, message: 'Ready' });

    });

    return router;

}