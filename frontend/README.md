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
- The admin build never imports the user module, and vice versa, so the other flavor's screens are not just hidden: they are not registered and are tree-shaken out of the build. An unregistered route resolves to a "Not found" page.
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

User site:

```bash
git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter && _flutter/bin/flutter build web --release -t lib/main_user.dart --dart-define=API_BASE_URL=$API_BASE_URL -o build/web_user
```

Admin site:

```bash
git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter && _flutter/bin/flutter build web --release -t lib/main_admin.dart --dart-define=API_BASE_URL=$API_BASE_URL -o build/web_admin
```

The build takes several minutes because Flutter is downloaded each time. The API allows every origin (CORS), so no backend change is needed for the new addresses.