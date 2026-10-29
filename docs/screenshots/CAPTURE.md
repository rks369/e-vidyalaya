# Screenshot capture checklist

The README links to every file listed here by exact path, so name files exactly as shown. 23 images in total.

## Before you start

1. Run the API locally (`npm run dev` in `backend/`) against a database used only for screenshots.
2. Use a mail sandbox (for example Mailtrap) as SMTP so passwords can be read while every address on screen stays fake.
3. Seed the same demo data for every shot. Suggested set:

| Item | Demo value |
| --- | --- |
| Institute | Demo Public School, code `demo`, domain `demo`, e-mail `office@example.com`, mobile `9000000001` |
| Classes | Class 8-A, Class 9-B, Class 10-A |
| Subjects | Mathematics, Science, English per class |
| People | 3 Teachers, 6 Students with `@example.com` e-mails and mobiles `90000000NN` |
| Notes | 6 to 8 per subject: mix of image, PDF, PPT, video and audio |
| Chat | A class chat and a one-to-one chat with 6 to 8 messages between 2 or 3 accounts |

4. Log in once per role (Director, Teacher, Student, Admin) and note the User IDs. Do not show real names, e-mails or phone numbers of real people in any shot.
5. Run the admin app as a **release** build (`--release`, or `flutter build web`). Debug builds draw an `ADMIN` banner in the corner (`showBanner: kDebugMode` in `frontend/lib/core/config/flavor_config.dart`).

## Capture settings

| Target | Setting |
| --- | --- |
| Mobile | Pixel 7 emulator, or Chrome DevTools device toolbar at 390×844, device pixel ratio 3. Pick one and use it for every `mobile/` image. |
| Tablet | 834×1194 (add it as a custom device in DevTools). Only `tablet/` images. |
| Desktop | Chrome window at 1440×900, device pixel ratio 1 or 2. Used for every `web/` image and both hero composites. |
| Format | PNG, viewport only, no browser chrome or device frame. |
| Data | Identical demo data in light, dark, mobile and web shots of the same screen. |
| Status bar | On the emulator, turn on System UI demo mode (or just keep the clock and battery plausible). |

Notes:
- At 834 px the app is still below its 840 px breakpoint, so the tablet shot shows the slide-out menu, not the permanent side panel. That is expected.
- Breakpoints are in `frontend/lib/core/widgets/responsive.dart`: 840 px for the permanent side menu, 900 px for the login brand panel.

## Switching theme

There is no theme switch inside the app. `MaterialApp` gets `theme` and `darkTheme` and no `themeMode`, so it follows the system (`frontend/lib/app.dart`).

| Where | How |
| --- | --- |
| Android emulator | Settings, Display, Dark theme, or `adb shell "cmd uimode night yes"` (use `no` to go back) |
| Chrome (web build) | DevTools, three-dot menu, More tools, Rendering, "Emulate CSS media feature prefers-color-scheme", choose `dark` |
| Windows / Linux desktop | Switch the OS to dark mode |

## Folder and naming convention

```text
docs/screenshots/
├── hero-light.png
├── hero-dark.png
├── CAPTURE.md
├── admin/
│   ├── mobile/light/
│   └── web/light/
└── user/
    ├── mobile/light/  mobile/dark/
    ├── tablet/light/
    └── web/light/
```

Files are numbered in user-flow order: `01` to `09` sign-in, `10` to `19` Director, `20` to `29` Teacher, `30` to `39` Student, `40` to `49` Chat, `50` to `59` side menu and profile, `60` to `69` Admin. The same screen keeps the same file name in every folder. Only the files in the checklist are linked from the README.

## Checklist

### Must-have (11)

These show without expanding anything, so the README looks broken without them. They need only 4 screens: dashboard, classes, notes and group chat. Take each on a phone in light and dark, the dashboard on a tablet and a desktop, then build the two hero images.

| Done | File path | App flavor | Log in as | Screen / how to get there | Device size | Theme |
| --- | --- | --- | --- | --- | --- | --- |
| [ ] | `docs/screenshots/hero-light.png` | both | n/a | Composite, see [Hero images](#hero-images) | About 2400×1350 | Light |
| [ ] | `docs/screenshots/hero-dark.png` | both | n/a | Same composite from the dark captures | About 2400×1350 | Dark |
| [ ] | `docs/screenshots/user/mobile/light/10_director_dashboard.png` | user | Director | First screen after login. Tiles: Classes, Teachers, Students, Chat. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/11_director_classes.png` | user | Director | Dashboard, then Classes. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/18_director_notes.png` | user | Director | Classes, a class, Subjects, then one subject. Seed a mix of image, PDF, video and PPT notes so the grid shows different file icons. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/44_group_chat.png` | user | Director | Chat, Classes tab, open a class. Pre-send 6 to 8 messages from at least two accounts. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/dark/10_director_dashboard.png` | user | Director | First screen after login. Tiles: Classes, Teachers, Students, Chat. | Mobile | Dark |
| [ ] | `docs/screenshots/user/mobile/dark/18_director_notes.png` | user | Director | Classes, a class, Subjects, then one subject. Seed a mix of image, PDF, video and PPT notes so the grid shows different file icons. | Mobile | Dark |
| [ ] | `docs/screenshots/user/mobile/dark/44_group_chat.png` | user | Director | Chat, Classes tab, open a class. Pre-send 6 to 8 messages from at least two accounts. | Mobile | Dark |
| [ ] | `docs/screenshots/user/tablet/light/10_director_dashboard.png` | user | Director | First screen after login. Tiles: Classes, Teachers, Students, Chat. | Tablet 834×1194 | Light |
| [ ] | `docs/screenshots/user/web/light/10_director_dashboard.png` | user | Director | First screen after login. Tiles: Classes, Teachers, Students, Chat. | Desktop 1440×900 | Light |

### Recommended (12)

These fill the collapsed gallery: every role, both apps, one or two screens each.

| Done | File path | App flavor | Log in as | Screen / how to get there | Device size | Theme |
| --- | --- | --- | --- | --- | --- | --- |
| [ ] | `docs/screenshots/user/mobile/light/01_login.png` | user | Signed out | Open the app signed out (log out first). | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/13_director_class_students.png` | user | Director | Classes, tap a class, then Students in the bottom sheet. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/15_director_teachers.png` | user | Director | Dashboard, then Teachers. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/20_teacher_dashboard.png` | user | Teacher | First screen after login. Tiles: Classes, Subjects, Students, Chat. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/21_teacher_classes.png` | user | Teacher | Dashboard, then Classes. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/30_student_dashboard.png` | user | Student | First screen after login. Tiles: Subjects, Chat. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/32_student_notes.png` | user | Student | Subjects, then one subject (same notes as 18). | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/45_direct_chat.png` | user | Director | Chat, Teachers tab, open a teacher. Pre-send a short conversation. | Mobile | Light |
| [ ] | `docs/screenshots/admin/mobile/light/60_admin_login.png` | admin | Signed out | Open the admin app signed out. | Mobile | Light |
| [ ] | `docs/screenshots/admin/mobile/light/61_institutes.png` | admin | Admin | Sign in. Seed 3 or 4 institutes first. | Mobile | Light |
| [ ] | `docs/screenshots/admin/mobile/light/62_add_institute.png` | admin | Admin | Institutes, then the + button. | Mobile | Light |
| [ ] | `docs/screenshots/admin/web/light/61_institutes.png` | admin | Admin | Sign in. Seed 3 or 4 institutes first. | Desktop 1440×900 | Light |

## Hero images

Compose each hero from existing captures, so take those first. Suggested layout (about 2400×1350, neutral background, soft shadow, device frames optional):

- Desktop: the Director dashboard at 1440×900, large, centre-right. `hero-light.png` uses `user/web/light/10_director_dashboard.png`. `hero-dark.png` needs the same shot in dark theme; take it as source material only, since the README does not link a `web/dark` image.
- Phones, overlapping on the left: `user/mobile/<theme>/10_director_dashboard.png` and `user/mobile/<theme>/44_group_chat.png` (both exist in light and dark).
- `<theme>` is `light` for `hero-light.png` and `dark` for `hero-dark.png`.

## Skipped on purpose

Not linked from the README, so do not capture them unless you want extras: dark and web copies of screens already covered, the form screens (add class, teacher, student, subject), forgot password, change password, side menu and profile, and the per-tab chat lists.

If you ever capture `63_director_credentials.png`, use a fake institute. The dialog shows the new director's User ID; the password itself is only e-mailed, but the User ID still identifies the institute.

## Keep the repo small

Compress every PNG before committing, for example `find docs/screenshots -name "*.png" -exec pngquant --quality=70-90 --ext .png --force {} +`, or drop the files into TinyPNG. Aim for under 300 KB per mobile shot and under 600 KB per desktop shot.
