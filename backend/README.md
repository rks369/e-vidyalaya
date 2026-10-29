# eVidyalaya backend

The Node.js (Express) API behind both apps. It owns the PostgreSQL database, sends e-mail and runs the live chat. Back to the [project overview](../README.md).

Requires Node.js 20 or newer and a PostgreSQL database.

## Quick start

```bash
cd backend
cp .env.example .env   # fill in the database, JWT_SECRET and SMTP settings
npm install
npm run migrate        # creates/updates the platform schema and every institute schema
npm run create-admin   # creates an admin account (asks for username, email and password)
npm run dev            # starts the API with auto-restart on http://localhost:3000
```

| Script | What it does |
| --- | --- |
| `npm start` | Runs the API (`node server.js`) |
| `npm run dev` | Runs the API and restarts it when files change |
| `npm run migrate` | Applies `migrations/` to the `platform` schema and every institute schema |
| `npm run create-admin` | Creates an admin account (see [Administrators](#administrators)) |
| `npm run clean-temp` | Deletes unattached uploads older than `TEMP_MAX_AGE_HOURS` from the temp folder |

## Configuration

All settings are environment variables (a `.env` file locally, the hosting dashboard in production). `.env.example` lists them. The server refuses to start if a required variable is missing.

| Variable | Required | Default | Meaning |
| --- | --- | --- | --- |
| `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` | yes | | PostgreSQL connection |
| `DB_PORT` | no | `5432` | |
| `DB_SSL` | no | `true` | Set to `false` for a local database without SSL |
| `JWT_SECRET` | yes | | Signs every login token. Use at least 32 random characters, for example `node -e "console.log(require('crypto').randomBytes(48).toString('hex'))"`. Never use a placeholder. |
| `PORT` | no | `3000` | |
| `SMTP_HOST`, `SMTP_USER`, `SMTP_PASS` | for e-mail | | Leave `SMTP_HOST` empty to skip sending e-mail |
| `SMTP_PORT` | no | `587` | Port 587 uses STARTTLS; port 465 needs `SMTP_SECURE=true` |
| `SMTP_SECURE` | no | `false` | |
| `MAIL_FROM`, `MAIL_FROM_NAME` | for e-mail | `E-Vidyalaya` (name) | Sender address and name. The address must be one your SMTP provider lets you send from. |
| `UPLOAD_DIR` | no | `backend/public/uploads` | Where attached files are stored |
| `TEMP_DIR` | no | `backend/public/temp` | Where new uploads wait until they are attached |
| `TEMP_MAX_AGE_HOURS` | no | `24` | Age after which `npm run clean-temp` deletes an unattached upload |
| `MAX_UPLOAD_MB` | no | `50` | Largest allowed upload |
| `PUBLIC_BASE_URL` | no | the request's host | Used to build file URLs, for example `https://api.example.com` |

Passwords for new institutes and users are sent only by e-mail and are never returned by the API, so SMTP must work before anyone but the admin can sign in. Reset codes are also delivered only by e-mail.

## How it is built

```
server.js              entry point: starts HTTP + Socket.IO, handles shutdown
src/app.js             Express app: security headers, CORS, rate limits, routes, error handling
src/routes/            thin routers: read the request, call a service, send the response
src/modules/           one service class per feature: auth, admin, institute, people, academics, chat, upload, health
src/middleware/        token checks (auth), rate limiter, file uploader
src/sockets/chat.js    live chat over Socket.IO
src/util/              DBClient, config, migrations runner, mailer, passwords, reset codes, validation, errors, response
migrations/core/       SQL for the shared platform schema
migrations/tenant/     SQL applied to every institute schema
scripts/               migrate, create-admin, clean-temp
```

- **Plain SQL, no ORM.** Database access is the `DBClient` class in `src/util/db.js` (plain `pg`). `DBClient.core` is the `platform` schema and `DBClient.tenant({ schema })` (or `req.db` inside a route) is one institute's schema; both offer `select`, `insert`, `update`, `query` and `transaction`. Table and column names are validated and values are always passed as parameters.
- **One schema per institute.** Each institute gets a PostgreSQL schema named `inst_<id>_<code>` (for example `inst_1_demo`); no query ever filters by institute. The institute `code` (2-30 letters or digits, given when the admin creates the institute) can never be changed, and Postgres generates the `schema_name` column from it.
- **Migrations are plain SQL files.** Add the next-numbered file to `migrations/core/` or `migrations/tenant/` and run `npm run migrate`, which applies it to `platform` and every existing institute. New institutes get every migration automatically.
- **Common response format.** Every response is `{ status, message?, data? }` through `sendResponse`, including errors (`status: false`).
- **Every table** has `creation_ts` and `modify_ts` columns kept by triggers.
- **Data rules inside an institute:** foreign keys (a class needs a real teacher, a subject a real class, a note a real subject, a message a real sender) and `designation` is a database enum of `DIRECTOR`, `TEACHER` and `STUDENT`. The same uppercase values are returned by the API and carried in the login token as `role`; the code refers to them through the `Role` class in `src/util/constants.js`.
- **Profile pictures** are stored as a URL and default to an empty string. The app shows the person's initials when there is no picture.

## Endpoints

Send the login token as `Authorization: Bearer <token>`. Errors use `400` (invalid input), `401` (not signed in), `403` (not allowed), `404`, `409` (already exists), `413` (too large), `429` (too many attempts) and `500`.

**Health** (no sign-in)

| Method and path | Purpose |
| --- | --- |
| `GET /health` | Liveness: always `200` while the process runs, with `data.uptime` |
| `GET /ready` | Readiness: `200` only when the database is reachable and migrated, otherwise `503` |

**Institute users** (director, teacher, student)

| Method and path | Who | Purpose |
| --- | --- | --- |
| `POST /auth/login` | anyone | Sign in with `username` (like `name@domain`) and `password`; returns `{ token, user }` |
| `POST /auth/logout` | signed in | Acknowledges logout (the app discards its token) |
| `GET /auth/me` | signed in | Current profile |
| `POST /auth/change-password` | signed in | `currentPassword`, `newPassword` |
| `POST /auth/forgot-password` | anyone | E-mails a one-time reset code |
| `POST /auth/reset-password` | anyone | `username`, `code`, `newPassword` |
| `GET /teachers`, `POST /teachers` | director | List / add teachers |
| `GET /students` (`?classId=`), `POST /students` | director (add: director or teacher) | List / add students |
| `GET /classes`, `POST /classes` | director | List / add classes |
| `GET /subjects`, `POST /subjects` | director | List / add subjects |
| `GET /classes/:classId/subjects` | members of the class | Subjects of a class |
| `GET /subjects/:subjectId/notes` | members of the class | Notes of a subject |
| `POST /notes` | director, teacher | Add a note (link) to a subject |
| `GET /teacher/classes`, `/teacher/subjects`, `/teacher/students` | teacher | The teacher's own classes, subjects and students |
| `GET /chats/:kind/:id/messages` (`?after=`) | chat members | Message history |
| `POST /uploads` | director, teacher | Upload a file (multipart field `file`) |

"Members of the class" means a director, the class teacher, a teacher of one of its subjects, or a student enrolled in the class. A teacher can only add students to their own class and notes to their own subjects.

**Administrators**

| Method and path | Who | Purpose |
| --- | --- | --- |
| `POST /admin/login` | anyone | `username`, `password`; returns `{ token, admin }` |
| `POST /admin/forgot-password`, `POST /admin/reset-password` | anyone | E-mailed one-time code, then the new password |
| `GET /admin/me` | admin | Current admin |
| `POST /admin/change-password` | admin | Change password |
| `GET /admin/institutes`, `POST /admin/institutes` | admin | List institutes / create one (needs `code`, `name`, `domain`, `address`, `mobile`, `email`, optional `logo`, which must be an http(s) URL) and its director account |

There are no update or delete routes yet: the API only lists and adds.

## Administrators

Admin accounts live in the `platform.admin` table. They can only be created from the command line, never through the API:

```bash
npm run create-admin
```

It asks for a username, an e-mail, and the password twice (the password is not shown). Any of them can be given up front as `npm run create-admin -- <username> <email> <password> <confirmation>`, and the script only asks for what is missing; a password typed on the command line stays in your shell history. Usernames are 3-64 lowercase letters, digits, dots, dashes or underscores. The e-mail must be unique, is stored in lower case and is where reset codes go. Passwords need at least 8 characters. The script says so if the username or e-mail is taken or `npm run migrate` has not been run.

Admin tokens last 12 hours, are rejected by every institute route and by the chat socket (and institute tokens are rejected by the admin routes), and stop working as soon as the admin's row is deleted. Changing a password does not end other sessions; they expire after 12 hours. There is no shared admin key.

## Passwords and sign-in

- Passwords are stored as per-user salted `scrypt` hashes. There is no password secret to configure.
- New institutes and users get a generated password that is e-mailed, never shown by the API. The director's User ID is `director@<domain>.evidalaya.in`.
- **Forgotten password** (institute users and admins work the same way): `forgot-password` e-mails an 8-character one-time code and changes nothing yet. The answer is identical whether or not the account exists, so nobody can probe for usernames or lock someone out. `reset-password` then sets the new password. The code works once (even if two requests use it at the same moment), expires after 15 minutes, and allows 5 tries in total; asking for a new code starts over.
- New passwords need at least 8 characters.
- Institute-user tokens last 30 days.

## Rate limits

The API answers `429` with a `Retry-After` header when a client tries a sensitive action too often. The limits are applied in `src/app.js` to the sign-in, forgot-password and reset-password routes of both institute users and admins:

| Action | Limit |
| --- | --- |
| Sign in | 10 tries per 15 minutes for each IP address and username |
| Forgot password | 3 per 15 minutes for each IP address and username, and 5 per hour for each username |
| Reset password | 10 per 15 minutes for each IP address and username |
| All of the above together | 3000 requests per 15 minutes per IP address (high enough for a whole institute behind one address) |
| Chat messages | 20 per 10 seconds per user |

The counters live in memory, so they reset when the server restarts and are not shared between several server instances. The numbers are in `src/util/config.js`. The API trusts one proxy hop for the client address, which is right behind a single reverse proxy or host load balancer; exposed directly without a proxy, a client could fake its address to dodge the per-IP limits.

## Uploads

Files are sent to `POST /uploads` and first stored in a private temp folder, `public/temp/<instituteId>/` (`TEMP_DIR`), which is not served. The response's `url` is only a handle for attaching the file: when `POST /notes` receives it, the file is moved to `public/uploads/<instituteId>/` (`UPLOAD_DIR`) and the note stores the path `/assets/<instituteId>/<file>`; the server URL is added when notes are listed, so only the host changes if storage moves. A file that is never attached stays in temp until `npm run clean-temp` deletes everything older than `TEMP_MAX_AGE_HOURS` (default 24); schedule it daily (for example with cron).

Accepted types: images (`.jpg .jpeg .png .gif .webp`), video (`.mp4 .mkv .mpg .mpeg .webm .mov`), audio (`.mp3 .m4a .aac .wav .wma .flac .ogg`) and documents (`.pdf .doc .docx .ppt .pptx .xls .xlsx .txt .zip`). HTML, SVG and scripts are refused. File names are random, so URLs cannot be guessed, but anyone with a URL can read the file. CORS is open so the web builds can call the API.

## Chat

Chat runs over Socket.IO on the same port as the API (`src/sockets/chat.js`). Connect with `io(apiUrl, { auth: { token } })` using the login token; a bad token fails with `connect_error: Please log in again`. Every event takes an optional acknowledgement callback that receives `{ status, message?, data? }`.

| Event (client sends) | Payload | What it does |
| --- | --- | --- |
| `chat:join` | `{ kind, id }` | Joins that chat's room if the user is a member (`kind` is `user`, `class` or `subject`). Acks `{ key }`. |
| `chat:send` | `{ kind, id, body }` | Saves the message, then broadcasts it to everyone in the room. Acks `{ key, message }`. |
| `chat:leave` | `{ kind, id }` | Leaves the room. |

The server pushes `chat:message` with `{ key, message }` to every member in the room, including the sender's other devices. Room names include the institute's schema, so two institutes with the same chat key never see each other's messages. Messages are stored in PostgreSQL; `GET /chats/:kind/:id/messages` (with an optional `?after=<id>`) returns the history for loading a screen or catching up after a dropped connection.

## Health and shutdown

`/health` always answers while the process runs, and `/ready` also needs the database, so a database outage does not make a host restart the service when it health-checks `/health`. Point a load balancer or a deploy gate at `/ready`.

On SIGTERM or Ctrl+C the server stops taking new connections, answers `/ready` with `503`, lets open requests finish (up to 10 seconds), closes the chat sockets and the database pool, then exits.
