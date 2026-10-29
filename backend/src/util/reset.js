import { DBClient } from './db.js';
import { Password } from './password.js';

export class ResetCode {

    static MINUTES = 15;

    static MAX_ATTEMPTS = 5;

    static FAILED_MESSAGE = 'That reset code is invalid or has expired';

    static CLEAR = 'reset_code = NULL, reset_expires = NULL, reset_attempts = 0';

    static async issue({ db, table, id }) {

        const code = Password.randomCode();
        const codeHash = await Password.hash({ password: code });

        const issued = await db.query({
            sql: `UPDATE ${DBClient.identifier({ name: table })}
                  SET reset_code = $1,
                      reset_expires = now() + interval '${ResetCode.MINUTES} minutes',
                      reset_attempts = 0
                  WHERE id = $2
                    AND (reset_code IS NULL
                         OR reset_expires <= now()
                         OR reset_attempts >= ${ResetCode.MAX_ATTEMPTS})
                  RETURNING id`,
            params: [codeHash, id],
        });

        return issued.length ? code : null;

    }

    static async verify({ db, table, username, code }) {

        const [claimed] = await db.query({
            sql: `UPDATE ${DBClient.identifier({ name: table })}
                  SET reset_attempts = reset_attempts + 1
                  WHERE username = $1
                    AND reset_code IS NOT NULL
                    AND reset_expires > now()
                    AND reset_attempts < ${ResetCode.MAX_ATTEMPTS}
                  RETURNING id, reset_code`,
            params: [username],
        });

        if (!claimed) {
            return null;
        }

        const matches = await Password.matches({ password: code, storedHash: claimed.reset_code });

        return matches ? { id: claimed.id, hash: claimed.reset_code } : null;

    }

}
