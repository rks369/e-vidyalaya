import { readdir, stat, unlink } from 'node:fs/promises';
import path from 'node:path';

export class TempFiles {

    static async clean({ dir, maxAgeMs }) {

        const cutoff = Date.now() - maxAgeMs;
        let removed = 0;

        let institutes;
        try {
            institutes = await readdir(dir, { withFileTypes: true });
        } catch (err) {
            if (err.code === 'ENOENT') {
                return removed;
            }
            throw err;
        }

        for (const institute of institutes.filter((entry) => entry.isDirectory())) {
            const folder = path.join(dir, institute.name);

            for (const name of await readdir(folder)) {
                const file = path.join(folder, name);
                const info = await stat(file);

                if (info.isFile() && info.mtimeMs < cutoff) {
                    await unlink(file);
                    removed++;
                }
            }
        }

        return removed;

    }

}
