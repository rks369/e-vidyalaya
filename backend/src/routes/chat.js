import { Router } from 'express';
import { ChatService } from '../modules/chat.js';
import { sendResponse } from '../util/response.js';

export function chatRouter() {

    const router = Router();
    
    const chatService = new ChatService();

    router.get('/chats/:kind/:id/messages', async (req, res) => {

        const data = await chatService.messages({
            db: req.db,
            userId: req.user.id,
            role: req.user.role,
            kind: req.params.kind,
            targetId: req.params.id,
            after: req.query.after,
        });
        sendResponse({ res, data });

    });

    return router;

}