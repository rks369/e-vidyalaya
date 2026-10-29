import { copyFile, mkdir, rename, unlink } from 'node:fs/promises';
import path from 'node:path';
import { HttpError } from '../util/errors.js';

export class UploadService {

    static #TEMP_PATH = /^\/temp\/(\d+)\/([a-f0-9]{24}\.[a-z0-9]+)$/;

    constructor({ config }) {

        this.config = config;

    }

    describe({ file, protocol, host, instituteId }) {

        if (!file) {
            throw HttpError.badRequest({ message: 'file is required' });
        }

        const base = this.config.publicBaseUrl || `${protocol}://${host}`;
        const storedPath = `/temp/${instituteId}/${file.filename}`;

        return {
            path: storedPath,
            url: `${base}${storedPath}`,
            name: file.originalname,
            ext: path.extname(file.originalname).toLowerCase(),
            size: file.size,
        };

    }

    async promote({ stored, instituteId }) {

        const match = UploadService.#TEMP_PATH.exec(stored);

        if (!match || Number(match[1]) !== instituteId) {
            throw HttpError.badRequest({ message: 'Uploaded file not found' });
        }

        const [, , filename] = match;
        const from = path.join(this.config.tempDir, String(instituteId), filename);
        const targetDir = path.join(this.config.uploadDir, String(instituteId));
        const to = path.join(targetDir, filename);

        await mkdir(targetDir, { recursive: true });

        try {
            await rename(from, to);
        } catch (err) {
            if (err.code === 'ENOENT') {
                throw HttpError.badRequest({ message: 'Uploaded file expired, please upload it again' });
            }
            if (err.code !== 'EXDEV') {
                throw err;
            }

            await copyFile(from, to);
            await unlink(from);
        }

        return `/assets/${instituteId}/${filename}`;

    }

}
