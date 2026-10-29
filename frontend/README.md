# eVidyalaya frontend

The Flutter app: one codebase that builds two apps, **Admin** and **User**, with Flutter flavors. It talks only to the [backend](../backend/README.md); back to the [project overview](../README.md).

## How the two apps work

| App | Flavor | Entry point | Who uses it |
| --- | --- | --- | --- |
| **eVidyalaya Admin** | `admin` | `lib/main_admin.dart` | Platform operator |
| **eVidyalaya** | `user` | `lib/main_user.dart` | Director, Teacher, Student |

The two APKs have different application IDs (`…evidyalaya` and `…evidyalaya.admin`), so they install side by side.

- `lib/main_admin.dart` and `lib/main_user.dart` set the `AppFlavor` and call the shared `runEvidyalaya()` in `lib/app.dart`.
- Each entry point passes its own `FlavorModule` (route table, Bloc providers, startup work). `app.dart` only registers the routes it is given.
- The admin build never imports the user module, and vice versa, so the other flavor's screens are not just hidden: they are not registered and are tree-shaken out of the APK. An unregistered route resolves to a "Not found" page (covered by `test/flavor_routes_test.dart`).
- Android flavors (`admin`, `user`) in `android/app/build.gradle.kts` set the application ID suffix and the launcher label.

## Project layout

```
lib/
├── main_admin.dart, main_user.dart   # entry points
├── app.dart                          # shared MaterialApp, theme, route registration
├── core/                             # config (env, flavors), api client, services, utils, widgets
└── features/
    ├── admin/      # institutes (admin flavor only)
    ├── auth/       # login, password flows, profile, role-based home (user flavor)
    ├── director/
    ├── teacher/
    ├── student/
    └── chat/
```

## Setup

Requires Flutter (stable), the Android SDK, and a running backend (see [backend/README.md](../backend/README.md)).

```bash
cd frontend
cp env.example.json env.json   # then fill in your own values
flutter pub get
```

Run every `flutter` command below from `frontend/`.

`env.json` is git-ignored. It holds `API_BASE_URL` and is passed at build time via `--dart-define-from-file`. For a local backend use `http://localhost:3000`; on an Android emulator use `http://10.0.2.2:3000` (plain `http` also needs `android:usesCleartextTraffic="true"` in a debug manifest).

## Run

```bash
flutter run --flavor admin -t lib/main_admin.dart --dart-define-from-file=env.json
flutter run --flavor user  -t lib/main_user.dart  --dart-define-from-file=env.json
```

Flutter flavors (`--flavor`) only exist on Android, iOS and macOS. On Windows and Linux pick the app with the entry point alone:

```bash
flutter run -d windows -t lib/main_admin.dart --dart-define-from-file=env.json
flutter run -d linux   -t lib/main_user.dart  --dart-define-from-file=env.json
```

### VS Code

**Run and Debug** has five configurations: `Backend (API)`, `User (debug)`, `User (release)`, `Admin (debug)` and `Admin (release)`. The app configurations use the Android flavors and read `API_BASE_URL` from `env.json`. Stop any `npm run dev` already using port 3000 before starting `Backend (API)`. For web or desktop, use the `flutter run` commands in the Run section above.

## Build

Release APKs (signed with the debug key unless you add your own signing config):

```bash
flutter build apk --release --flavor admin -t lib/main_admin.dart --dart-define-from-file=env.json
flutter build apk --release --flavor user  -t lib/main_user.dart  --dart-define-from-file=env.json
```

Web (one build per app; deploy the `build/web` folder to any static host, and set `API_BASE_URL` to the public API address):

```bash
flutter build web -t lib/main_user.dart  --dart-define-from-file=env.json -o build/web_user
flutter build web -t lib/main_admin.dart --dart-define-from-file=env.json -o build/web_admin
```

## Platform support

The app runs on Android, iOS, web, macOS, Windows and Linux from one codebase. Every plugin it uses has an implementation on all six, and all data and files go through the backend API (no Firebase, no direct database access).

| Feature | How it works everywhere |
| --- | --- |
| Pick a file | `file_picker` (streams the file, so large videos are not loaded into memory, including on web) |
| Camera photo | Phones only (`image_picker`); other platforms pick an image file instead |
| Open a note | `url_launcher` hands the file URL to the browser or system viewer |
| Chat | Socket.IO for sending and live messages, REST for history; a slow poll catches up after a dropped connection |

- **Web:** the API's CORS is open and uploads are served with `Cross-Origin-Resource-Policy: cross-origin`.
- **iOS:** `Info.plist` has the camera and photo-library descriptions. **Android:** release builds only need `INTERNET`; no storage permissions.
- **macOS:** the runner has the network and file-selection entitlements.
- Windows builds need Developer Mode (symlinks) and the Visual Studio C++ workload; Linux builds need the standard GTK toolchain; iOS and macOS builds need a Mac.
- `flutter analyze`, `flutter test` and both web builds were verified against the current backend; the other platform runners were not built here.

## Layouts

The app uses Material 3 throughout: one theme (`lib/core/config/app_theme.dart`) built from each flavor's seed color in light and dark, no hard-coded colors, filled and tonal buttons, a navigation drawer, and error snack bars colored from the scheme. The same screens fill the window and adapt to its width: sign-in is a two-panel layout from 900 px wide (the form itself stays 440 px wide), lists and forms flow into two or three columns, and the dashboard tiles spread across the row. From 840 px wide (the Material 3 expanded breakpoint) the user app shows its menu as a permanent side panel instead of a drawer. `test/responsive_test.dart` checks these screens from a 320 px phone to a 1440 px desktop, and `test/material3_test.dart` checks the theme, dark mode and the breakpoint.

## Known limitations / next steps

- The admin app has sign-in but no forgot-password screen yet (the backend supports it).
- iOS flavors are not configured yet; only Android flavors exist.
- Chat history from the old Firestore chat is not migrated; conversations start empty.
