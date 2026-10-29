import nodemailer from 'nodemailer';

export class Mailer {

    constructor({ host, port, secure, user, pass, fromEmail, fromName, transport }) {

        this.from = { name: fromName, address: fromEmail };
        this.transport = transport ?? null;

        if (!this.transport && host) {
            this.transport = nodemailer.createTransport({
                host: host,
                port: port,
                secure: secure,
                auth: user ? { user: user, pass: pass } : undefined,
                connectionTimeout: 10000,
                greetingTimeout: 10000,
                socketTimeout: 20000,
            });
        }

    }

    async send({ to, subject, text }) {

        if (!this.transport) {
            console.warn(`[mail] SMTP_HOST not set, not sending "${subject}" to ${to}`);
            return false;
        }

        try {
            await this.transport.sendMail({ from: this.from, to, subject, text });
            return true;
        } catch (err) {
            console.error('[mail] send failed', err);
            return false;
        }

    }

}
