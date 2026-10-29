# Screenshot capture checklist

The README links to every file listed here by exact path, so name files exactly as shown. 64 images in total.

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
- The Camera option on `19_director_note_upload` only appears on Android, so take that one on the emulator.
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
│   ├── mobile/light/  mobile/dark/
│   └── web/light/     web/dark/
└── user/
    ├── mobile/light/  mobile/dark/
    ├── tablet/light/
    └── web/light/     web/dark/
```

Files are numbered in user-flow order: `01` to `09` sign-in, `10` to `19` Director, `20` to `29` Teacher, `30` to `39` Student, `40` to `49` Chat, `50` to `59` side menu and profile, `60` to `69` Admin. The same screen keeps the same file name in every folder.

## Checklist

### `user/mobile/light/` (29)

| Done | File path | App flavor | Log in as | Screen / how to get there | Device size | Theme |
| --- | --- | --- | --- | --- | --- | --- |
| [ ] | `docs/screenshots/user/mobile/light/01_login.png` | user | Signed out | Open the app signed out (log out first). | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/02_forgot_password.png` | user | Signed out | Login, then "Forgot Password ?". | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/10_director_dashboard.png` | user | Director | First screen after login. Tiles: Classes, Teachers, Students, Chat. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/11_director_classes.png` | user | Director | Dashboard, then Classes. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/12_director_class_subjects.png` | user | Director | Classes, tap a class, then Subjects in the bottom sheet. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/13_director_class_students.png` | user | Director | Classes, tap a class, then Students in the bottom sheet. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/14_director_add_class.png` | user | Director | Classes, then the + button. Show the Class Teacher dropdown open or filled. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/15_director_teachers.png` | user | Director | Dashboard, then Teachers. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/16_director_add_teacher.png` | user | Director | Teachers, then the + button. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/17_director_add_student.png` | user | Director | Dashboard, Students, then the + button. Show the Class dropdown filled. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/18_director_notes.png` | user | Director | Classes, a class, Subjects, then one subject. Seed a mix of image, PDF, video and PPT notes so the grid shows different file icons. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/19_director_note_upload.png` | user | Director | Inside a subject's notes, tap +. The Camera option only appears on Android, so use the emulator for this one. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/20_teacher_dashboard.png` | user | Teacher | First screen after login. Tiles: Classes, Subjects, Students, Chat. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/21_teacher_classes.png` | user | Teacher | Dashboard, then Classes. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/22_teacher_subjects.png` | user | Teacher | Dashboard, then Subjects. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/23_teacher_students.png` | user | Teacher | Dashboard, then Students. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/24_teacher_add_student.png` | user | Teacher | Students, then the + button. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/30_student_dashboard.png` | user | Student | First screen after login. Tiles: Subjects, Chat. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/31_student_subjects.png` | user | Student | Dashboard, then Subjects. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/32_student_notes.png` | user | Student | Subjects, then one subject (same notes as 18). | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/40_chat_classes.png` | user | Director | Dashboard, Chat, Classes tab. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/41_chat_subjects.png` | user | Director | Dashboard, Chat, Subjects tab. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/42_chat_teachers.png` | user | Director | Dashboard, Chat, Teachers tab. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/43_chat_students.png` | user | Director | Dashboard, Chat, Students tab. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/44_group_chat.png` | user | Director | Chat, Classes tab, open a class. Pre-send 6 to 8 messages from at least two accounts. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/45_direct_chat.png` | user | Director | Chat, Teachers tab, open a teacher. Pre-send a short conversation. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/50_drawer.png` | user | Director | Dashboard, then the menu button. On desktop it is the permanent left panel. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/51_profile.png` | user | Director | Side menu, then Profile. | Mobile | Light |
| [ ] | `docs/screenshots/user/mobile/light/52_change_password.png` | user | Director | Profile, then Change password. Leave the fields empty. | Mobile | Light |

### `user/mobile/dark/` (9)

| Done | File path | App flavor | Log in as | Screen / how to get there | Device size | Theme |
| --- | --- | --- | --- | --- | --- | --- |
| [ ] | `docs/screenshots/user/mobile/dark/01_login.png` | user | Signed out | Open the app signed out (log out first). | Mobile | Dark |
| [ ] | `docs/screenshots/user/mobile/dark/10_director_dashboard.png` | user | Director | First screen after login. Tiles: Classes, Teachers, Students, Chat. | Mobile | Dark |
| [ ] | `docs/screenshots/user/mobile/dark/11_director_classes.png` | user | Director | Dashboard, then Classes. | Mobile | Dark |
| [ ] | `docs/screenshots/user/mobile/dark/14_director_add_class.png` | user | Director | Classes, then the + button. Show the Class Teacher dropdown open or filled. | Mobile | Dark |
| [ ] | `docs/screenshots/user/mobile/dark/18_director_notes.png` | user | Director | Classes, a class, Subjects, then one subject. Seed a mix of image, PDF, video and PPT notes so the grid shows different file icons. | Mobile | Dark |
| [ ] | `docs/screenshots/user/mobile/dark/30_student_dashboard.png` | user | Student | First screen after login. Tiles: Subjects, Chat. | Mobile | Dark |
| [ ] | `docs/screenshots/user/mobile/dark/40_chat_classes.png` | user | Director | Dashboard, Chat, Classes tab. | Mobile | Dark |
| [ ] | `docs/screenshots/user/mobile/dark/44_group_chat.png` | user | Director | Chat, Classes tab, open a class. Pre-send 6 to 8 messages from at least two accounts. | Mobile | Dark |
| [ ] | `docs/screenshots/user/mobile/dark/50_drawer.png` | user | Director | Dashboard, then the menu button. On desktop it is the permanent left panel. | Mobile | Dark |

### `user/tablet/light/` (1)

| Done | File path | App flavor | Log in as | Screen / how to get there | Device size | Theme |
| --- | --- | --- | --- | --- | --- | --- |
| [ ] | `docs/screenshots/user/tablet/light/10_director_dashboard.png` | user | Director | First screen after login. Tiles: Classes, Teachers, Students, Chat. | Tablet 834×1194 | Light |

### `user/web/light/` (5)

| Done | File path | App flavor | Log in as | Screen / how to get there | Device size | Theme |
| --- | --- | --- | --- | --- | --- | --- |
| [ ] | `docs/screenshots/user/web/light/01_login.png` | user | Signed out | Open the app signed out (log out first). | Desktop 1440×900 | Light |
| [ ] | `docs/screenshots/user/web/light/10_director_dashboard.png` | user | Director | First screen after login. Tiles: Classes, Teachers, Students, Chat. | Desktop 1440×900 | Light |
| [ ] | `docs/screenshots/user/web/light/11_director_classes.png` | user | Director | Dashboard, then Classes. | Desktop 1440×900 | Light |
| [ ] | `docs/screenshots/user/web/light/18_director_notes.png` | user | Director | Classes, a class, Subjects, then one subject. Seed a mix of image, PDF, video and PPT notes so the grid shows different file icons. | Desktop 1440×900 | Light |
| [ ] | `docs/screenshots/user/web/light/44_group_chat.png` | user | Director | Chat, Classes tab, open a class. Pre-send 6 to 8 messages from at least two accounts. | Desktop 1440×900 | Light |

### `user/web/dark/` (5)

| Done | File path | App flavor | Log in as | Screen / how to get there | Device size | Theme |
| --- | --- | --- | --- | --- | --- | --- |
| [ ] | `docs/screenshots/user/web/dark/01_login.png` | user | Signed out | Open the app signed out (log out first). | Desktop 1440×900 | Dark |
| [ ] | `docs/screenshots/user/web/dark/10_director_dashboard.png` | user | Director | First screen after login. Tiles: Classes, Teachers, Students, Chat. | Desktop 1440×900 | Dark |
| [ ] | `docs/screenshots/user/web/dark/11_director_classes.png` | user | Director | Dashboard, then Classes. | Desktop 1440×900 | Dark |
| [ ] | `docs/screenshots/user/web/dark/18_director_notes.png` | user | Director | Classes, a class, Subjects, then one subject. Seed a mix of image, PDF, video and PPT notes so the grid shows different file icons. | Desktop 1440×900 | Dark |
| [ ] | `docs/screenshots/user/web/dark/44_group_chat.png` | user | Director | Chat, Classes tab, open a class. Pre-send 6 to 8 messages from at least two accounts. | Desktop 1440×900 | Dark |

### `admin/mobile/light/` (4)

| Done | File path | App flavor | Log in as | Screen / how to get there | Device size | Theme |
| --- | --- | --- | --- | --- | --- | --- |
| [ ] | `docs/screenshots/admin/mobile/light/60_admin_login.png` | admin | Signed out | Open the admin app signed out. | Mobile | Light |
| [ ] | `docs/screenshots/admin/mobile/light/61_institutes.png` | admin | Admin | Sign in. Seed 3 or 4 institutes first. | Mobile | Light |
| [ ] | `docs/screenshots/admin/mobile/light/62_add_institute.png` | admin | Admin | Institutes, then the + button. | Mobile | Light |
| [ ] | `docs/screenshots/admin/mobile/light/63_director_credentials.png` | admin | Admin | Submit Add Institute with valid demo data; the dialog appears on success. | Mobile | Light |

### `admin/mobile/dark/` (3)

| Done | File path | App flavor | Log in as | Screen / how to get there | Device size | Theme |
| --- | --- | --- | --- | --- | --- | --- |
| [ ] | `docs/screenshots/admin/mobile/dark/60_admin_login.png` | admin | Signed out | Open the admin app signed out. | Mobile | Dark |
| [ ] | `docs/screenshots/admin/mobile/dark/61_institutes.png` | admin | Admin | Sign in. Seed 3 or 4 institutes first. | Mobile | Dark |
| [ ] | `docs/screenshots/admin/mobile/dark/62_add_institute.png` | admin | Admin | Institutes, then the + button. | Mobile | Dark |

### `admin/web/light/` (3)

| Done | File path | App flavor | Log in as | Screen / how to get there | Device size | Theme |
| --- | --- | --- | --- | --- | --- | --- |
| [ ] | `docs/screenshots/admin/web/light/60_admin_login.png` | admin | Signed out | Open the admin app signed out. | Desktop 1440×900 | Light |
| [ ] | `docs/screenshots/admin/web/light/61_institutes.png` | admin | Admin | Sign in. Seed 3 or 4 institutes first. | Desktop 1440×900 | Light |
| [ ] | `docs/screenshots/admin/web/light/62_add_institute.png` | admin | Admin | Institutes, then the + button. | Desktop 1440×900 | Light |

### `admin/web/dark/` (3)

| Done | File path | App flavor | Log in as | Screen / how to get there | Device size | Theme |
| --- | --- | --- | --- | --- | --- | --- |
| [ ] | `docs/screenshots/admin/web/dark/60_admin_login.png` | admin | Signed out | Open the admin app signed out. | Desktop 1440×900 | Dark |
| [ ] | `docs/screenshots/admin/web/dark/61_institutes.png` | admin | Admin | Sign in. Seed 3 or 4 institutes first. | Desktop 1440×900 | Dark |
| [ ] | `docs/screenshots/admin/web/dark/62_add_institute.png` | admin | Admin | Institutes, then the + button. | Desktop 1440×900 | Dark |

## Hero images

Compose each hero from existing captures, so take those first. Suggested layout (about 2400×1350, neutral background, soft shadow, device frames optional):

- Desktop: `user/web/<theme>/10_director_dashboard.png`, large, centre-right.
- Phones, overlapping on the left: `user/mobile/<theme>/10_director_dashboard.png` and `user/mobile/<theme>/44_group_chat.png`.
- `<theme>` is `light` for `hero-light.png` and `dark` for `hero-dark.png`.

| Done | File path | App flavor | Log in as | Screen / how to get there | Device size | Theme |
| --- | --- | --- | --- | --- | --- | --- |
| [ ] | `docs/screenshots/hero-light.png` | both | n/a | Composite, see [Hero images](#hero-images) | Any (about 2400×1350) | Light |
| [ ] | `docs/screenshots/hero-dark.png` | both | n/a | Same composite built from the dark captures | Any (about 2400×1350) | Dark |

## Keep the repo small

Compress every PNG before committing, for example `find docs/screenshots -name "*.png" -exec pngquant --quality=70-90 --ext .png --force {} +`, or drop the files into TinyPNG. Aim for under 300 KB per mobile shot and under 600 KB per desktop shot.
