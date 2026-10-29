import { randomBytes } from 'node:crypto';
import { mkdir } from 'node:fs/promises';
import path from 'node:path';
import multer from 'multer';
import { HttpError } from '../util/errors.js';

export class Uploader {

    static #ALLOWED_EXTENSIONS = new Set([
        '.jpg', '.jpeg', '.png', '.gif', '.webp',
        '.mp4', '.mkv', '.mpg', '.mpeg', '.webm', '.mov',
        '.mp3', '.m4a', '.aac', '.wav', '.wma', '.flac', '.ogg',
        '.pdf', '.doc', '.docx', '.ppt', '.pptx', '.xls', '.xlsx', '.txt', '.zip',
    ]);

    static create({ dir, maxBytes }) {

        const storage = multer.diskStorage({
            destination: (req, _file, cb) => {

                const target = path.join(dir, String(req.user.instituteId));
                mkdir(target, { recursive: true }).then(() => cb(null, target), cb);

            },
            filename: (_req, file, cb) => {

                const ext = path.extname(file.originalname).toLowerCase();
                cb(null, `${randomBytes(12).toString('hex')}${ext}`);

            },
        });

        return multer({
            storage,
            limits: { fileSize: maxBytes, files: 1 },
            fileFilter: (_req, file, cb) => {

                const ext = path.extname(file.originalname).toLowerCase();

                if (!Uploader.#ALLOWED_EXTENSIONS.has(ext)) {
                    cb(HttpError.badRequest({ message: `${ext || 'That'} files are not allowed` }), true);
                    return;
                }

                cb(null, true);

            },
        });

    }

}
