# Chaos Wheel Party Game

Chaos Wheel Party Game is a Flutter party game built around player selection,
truth/dare style prompts, chaos effects, audio feedback, sharing, and optional
premium content.

## Current Development Status

This repository is not ready for public release yet. The app can be developed
locally, but store publishing requires product, store, signing, and purchase
configuration decisions.

Active working branch for technical cleanup:

```bash
git switch muhammedBranch
```

## Requirements

Use the Flutter/Dart versions currently verified for this project:

- Flutter 3.38.9
- Dart 3.10.8
- Java 17 for Android builds

Check your local toolchain:

```bash
flutter --version
flutter doctor
```

## Setup

Install dependencies:

```bash
flutter pub get
```

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Run the app locally:

```bash
flutter run
```

For a specific target:

```bash
flutter devices
flutter run -d chrome
flutter run -d android
```

## Build Commands

Android debug APK:

```bash
flutter build apk --debug
```

Android release APK:

```bash
flutter build apk --release
```

Android App Bundle for Play Store:

```bash
flutter build appbundle --release
```

Web build:

```bash
flutter build web
```

## Important Release Notes

Do not treat a successful local build as release readiness. Before publishing,
the items in `docs/RELEASE_CHECKLIST.md` must be reviewed and completed.

Known release blockers include:

- Android application ID still uses the Flutter template namespace.
- Android release build is still configured with the debug signing config.
- In-app purchase product IDs, store setup, testing, and verification strategy
  are not documented.
- App store metadata, privacy details, screenshots, and production app naming
  need final decisions.

## Dependency Maintenance

Check outdated dependencies:

```bash
flutter pub outdated
```

Upgrade only after testing the affected flows:

```bash
flutter pub upgrade
flutter analyze
flutter test
```

## Project Structure

- `lib/main.dart` - app entry point and routes
- `lib/providers/` - game state provider
- `lib/models/` - game/player/prompt models
- `lib/services/` - game logic, prompts, audio, sharing, purchases
- `lib/screens/` - app screens
- `lib/widgets/` - reusable UI components
- `assets/audio/` - bundled audio assets
- `android/`, `ios/`, `web/` - platform projects
