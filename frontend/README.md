# eVidyalaya frontend

The Flutter app: one codebase that builds two apps, **Admin** and **User**, with Flutter flavors. It talks only to the [backend](../backend/README.md); back to the [project overview](../README.md).

## How the two apps work

| App | Flavor | Entry point | Who uses it |
| --- | --- | --- | --- |
| **eVidyalaya Admin** | `admin` | `lib/main_admin.dart` | Platform operator |
| **eVidyalaya** | `user` | `lib/main_user.dart` | Director, Teacher, Student |

The two Android apps have different application IDs (`com.asyncit.evidyalaya` and `com.asyncit.evidyalaya.admin`), so they install side by side.

- `lib/main_admin.dart` and `lib/main_user.dart` set the `AppFlavor` and call the shared `runEvidyalaya()` in `lib/app.dart`.
- Each entry point passes its own `FlavorModule` (route table, Bloc providers, startup work). `app.dart` only registers the routes it is given.
- The admin build never imports the user module, and vice versa, so the other flavor's screens are not just hidden: they are not registered and are tree-shaken out of the build. An unregistered route resolves to a "Not found" page (covered by `test/flavor_routes_test.dart`).
- The Android flavors (`admin`, `user`) in `android/app/build.gradle.kts` set the application ID suffix and the launcher label.
- The admin app is purple and the user app is blue (`lib/core/config/flavor_config.dart`).

## Project layout

```
lib/
├── main_admin.dart, main_user.dart   # entry points
├── app.dart                          # shared MaterialApp, theme, route registration
├── core/
│   ├── api/                          # ApiClient (HTTP, token, errors, uploads)
│   ├── bloc/                         # ConnectionCubit (online/offline)
│   ├── config/                       # env, flavors, Material 3 theme
│   ├── models/                       # user, class, subject, note, message
│   ├── services/                     # chat socket, file picking, open file, change screen, e-mail validator
│   ├── utils/                        # snack bars, static text
│   └── widgets/                      # shared UI: lists, tiles, forms, avatar, profile card, empty/error states
└── features/
    ├── admin/      # institutes (admin flavor only)
    ├── auth/       # login, password flows, profile, side menu, role-based home (user flavor)
    ├── director/   # classes, subjects, notes, teachers, students
    ├── teacher/    # own classes, subjects, students
    ├── student/    # subjects and notes
    └── chat/       # chat screens, bubbles and the chat service
test/               # 37 widget and unit tests
images/             # dashboard and file-type images
web/                # web index, manifest and icons
```

Each feature folder has `screens/` and, where it talks to the API, `services/` (`admin_service`, `auth_service`, `director_service`, `teacher_service`, `chat_service`). Services only call `ApiClient`; screens decide what to show.

## Setup

Requires Flutter (stable, Dart `^3.13.7`), the Android SDK, and a running backend (see [backend/README.md](../backend/README.md)).

```bash
cd frontend
cp env.example.json env.json   # then fill in your own values
flutter pub get
```

Run every `flutter` command below from `frontend/`.

`env.json` is git-ignored. It holds `API_BASE_URL` and is passed at build time with `--dart-define-from-file`. For a local backend use `http://localhost:3000`; on an Android emulator use `http://10.0.2.2:3000` (plain `http` also needs `android:usesCleartextTraffic="true"`, which only the debug manifest has). The app shows a "Missing configuration" screen if `API_BASE_URL` is empty.

## Run

```bash
flutter run --flavor admin -t lib/main_admin.dart --dart-define-from-file=env.json
flutter run --flavor user  -t lib/main_user.dart  --dart-define-from-file=env.json
```

Flutter flavors (`--flavor`) only exist on Android, iOS and macOS. For the web and for Windows and Linux, pick the app with the entry point alone:

```bash
flutter run -d chrome  -t lib/main_user.dart  --dart-define-from-file=env.json
flutter run -d chrome  -t lib/main_admin.dart --dart-define-from-file=env.json
flutter run -d windows -t lib/main_user.dart  --dart-define-from-file=env.json
```

### VS Code

**Run and Debug** has five configurations: `Backend (API)`, `User (debug)`, `User (release)`, `Admin (debug)` and `Admin (release)`. The app configurations use the Android flavors and read `API_BASE_URL` from `env.json`. Stop any `npm run dev` already using port 3000 before starting `Backend (API)`.

## Test

```bash
flutter analyze
flutter test
```

| Test file | What it checks |
| --- | --- |
| `test/api_client_test.dart` | Replies, errors and the bearer token of `ApiClient` |
| `test/flavor_routes_test.dart` | Each flavor registers only its own routes |
| `test/material3_test.dart` | Light and dark theme, snack bar colors, connection cubit, home layout and breakpoint |
| `test/responsive_test.dart` | Screens do not overflow from a 320 px phone to a 1440 px desktop; dashboard grid, home and sign-in at each size |

## Build

### Android

Release APKs (signed with the debug key until you add your own signing config in `android/app/build.gradle.kts`, which Google Play will not accept):

```bash
flutter build apk --release --flavor admin -t lib/main_admin.dart --dart-define-from-file=env.json
flutter build apk --release --flavor user  -t lib/main_user.dart  --dart-define-from-file=env.json
```

For Google Play build an app bundle instead (`flutter build appbundle`, same flavor and entry point options) and sign it with your own upload key. The application ID in `build.gradle.kts` is still `com.asyncit.evidyalaya`; change it to your own before publishing.

### Web

Build each web app separately. Each one is its own site, so both use the default base path `/`.

```bash
flutter build web --release -t lib/main_user.dart  --dart-define-from-file=env.json -o build/web_user
flutter build web --release -t lib/main_admin.dart --dart-define-from-file=env.json -o build/web_admin
```

`API_BASE_URL` is baked in at build time, so check it points at your public API first. Serve the sites over HTTPS when the API is. The apps use one page and Flutter's default `#` URLs, so no rewrite rule is needed.

**Into `public_html`.** To collect both builds in `frontend/public_html` (git-ignored) and upload each folder to its own site, run in PowerShell:

```powershell
New-Item -ItemType Directory -Force public_html/web_user
Copy-Item build/web_user/* public_html/web_user -Recurse -Force

New-Item -ItemType Directory -Force public_html/web_admin
Copy-Item build/web_admin/* public_html/web_admin -Recurse -Force
```

**On Render.** Create two **Static Sites** from the repository, with these settings:

| Setting | User site | Admin site |
| --- | --- | --- |
| Root Directory | `frontend` | `frontend` |
| Publish Directory | `build/web_user` | `build/web_admin` |
| Environment variable | `API_BASE_URL` = your API address | `API_BASE_URL` = your API address |

Render has no Flutter, and `env.json` is not in the repository, so the Build Command downloads Flutter and passes the address with `--dart-define`.

User site:

```bash
git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter && _flutter/bin/flutter build web --release -t lib/main_user.dart --dart-define=API_BASE_URL=$API_BASE_URL -o build/web_user
```

Admin site:

```bash
git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter && _flutter/bin/flutter build web --release -t lib/main_admin.dart --dart-define=API_BASE_URL=$API_BASE_URL -o build/web_admin
```

The build takes several minutes because Flutter is downloaded each time. The API allows every origin (CORS), so no backend change is needed for the new addresses.

### Icons

The web favicon and icons in `web/` are made from the Android launcher icon (`android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`). The largest Android icon is 192 px, so the 512 px web icons are an enlargement of it.

## Screens and layouts

**Screens by role** (user app; after sign-in the home screen picks the dashboard from the person's role):

| Role | Dashboard tiles | Opens |
| --- | --- | --- |
| Director | Classes, Teachers, Students, Chat | Class list and actions, subjects, notes upload, add class / subject / teacher / student, chat |
| Teacher | Classes, Subjects, Students, Chat | Own classes, subjects with notes, students, add student |
| Student | Subjects, Chat | Subjects of the class and their notes |

Everyone also has a side menu with Profile, About Us, Contact Us, Privacy, Terms and Logout. The admin app has sign-in, the institute list and an add-institute form.

**Look and feel.** The app uses Material 3 with one theme (`lib/core/config/app_theme.dart`) built from each flavor's seed color, in light and dark (it follows the device or browser setting). Surfaces are flat with outlined cards, filled text fields without borders, rounded buttons and snack bars colored from the scheme. People without a profile picture get a colored circle with their initials.

**Responsive.** Screens fill the window and adapt to its width:

| Width | What changes |
| --- | --- |
| Below 840 px | Menu is a drawer, lists are one column, forms are one column |
| 840 px and up | The user app shows its menu as a permanent side panel (the Material 3 expanded breakpoint) |
| 900 px and up | Sign-in becomes two panels: a brand panel and the form (the form stays 440 px wide) |
| Wider windows | Lists and forms flow into two or three columns, dashboard tiles spread across the row |

Profile and change-password cards stay phone-width (440 px) and centered.

## Code style

- Every function and method takes **named arguments** (`changeScreen(context: context, screen: ...)`), except overrides and callbacks that Flutter or a plugin calls with positional arguments.
- **Braces on every** `if`, `else`, `for` and `while`, never a one-line body.
- A blank line after the opening `{` and before the closing `}` of class, method and callback bodies, and one argument or parameter per line when there are two or more.
- No code comments.
- Indentation is Dart's 2 spaces. **Do not run `dart format`** or turn on format-on-save: it removes the blank lines described above.

## Platform support

The app runs on Android, web, Windows, Linux, iOS and macOS from one codebase. Every plugin it uses has an implementation on all six, and all data and files go through the backend API (no Firebase, no direct database access).

| Feature | How it works everywhere |
| --- | --- |
| Pick a file | `file_picker` (streams the file, so large videos are not loaded into memory, including on web) |
| Camera photo | Phones only (`image_picker`); other platforms pick an image file instead |
| Open a note | `url_launcher` hands the file URL to the browser or system viewer |
| Chat | Socket.IO for sending and live messages, REST for history; a slow poll catches up after a dropped connection |
| Saved login | `shared_preferences` (browser storage on the web) |

- **Web:** the API's CORS is open and uploads are served with `Cross-Origin-Resource-Policy: cross-origin`. Images from other sites may not load in the browser if those sites do not allow it.
- **iOS:** `Info.plist` has the camera and photo-library descriptions. **Android:** release builds only need `INTERNET` and `ACCESS_NETWORK_STATE`; no storage permissions.
- **macOS:** the runner has the network and file-selection entitlements.
- Windows builds need Developer Mode (symlinks) and the Visual Studio C++ workload; Linux builds need the standard GTK toolchain; iOS and macOS builds need a Mac.
- `flutter analyze`, `flutter test` and both web builds pass; the other platform runners were not built here.

## Known limitations / next steps

- Chat only works for the director: the chat tabs load their lists from director-only API routes, so they are empty for teachers and students.
- No edit or delete screens, and the backend has no update or delete routes yet.
- The admin app has no forgot-password or change-password screen (the backend supports both).
- The privacy policy and terms text in `lib/core/utils/constants.dart` is placeholder text.
- The login token is kept in plain `shared_preferences`; use `flutter_secure_storage` on mobile for stronger protection.
- A failed list request shows an empty list instead of an error in the director and teacher services.
- iOS flavors are not configured; only the Android flavors exist.
- Chat history from the old Firestore chat is not migrated; conversations start empty.
