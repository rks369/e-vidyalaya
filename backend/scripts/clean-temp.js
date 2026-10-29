import { Config } from '../src/util/config.js';
import { TempFiles } from '../src/util/tempFiles.js';

const config = new Config();
const removed = await TempFiles.clean({ dir: config.tempDir, maxAgeMs: config.tempMaxAgeMs });

console.log(`Removed ${removed} unattached upload(s) older than ${config.tempMaxAgeMs / 3600000} hour(s).`);
