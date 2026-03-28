# TargetTrail

TargetTrail is an offline-first countdown and milestone tracker built with Flutter for Android and iOS. It helps users track multiple target dates, log daily achievements, receive per-target reminders, and pin countdown widgets to the home screen.

## What The App Does

- Create, edit, and delete multiple countdown targets.
- Track days remaining until each target date.
- Log daily notes or achievements for each target.
- Schedule a separate daily reminder for each target.
- View targets on a calendar.
- Use light, dark, or system theme.
- Show selected targets on Android home screen widgets.
- Work fully offline with local storage only.

## Tech Stack

Core stack used in this project:

- Flutter SDK: `>=3.20.0-1.2.pre`
- Dart SDK: `>=3.4.0-190.0.dev <4.0.0`
- App version: `1.0.0+1`
- State management: `flutter_riverpod 2.6.1`
- Local database: `sqflite 2.3.3+1`
- Preferences: `shared_preferences 2.2.3`
- Notifications: `flutter_local_notifications 18.0.1`
- Timezone handling: `timezone 0.10.1`, `flutter_timezone 1.0.8`
- Home screen widget bridge: `home_widget 0.6.0`
- Calendar UI: `table_calendar 3.2.0`
- Date formatting: `intl 0.20.2`
- IDs/utilities: `uuid 4.5.3`, `path 1.9.0`
- App icons: `flutter_launcher_icons 0.14.4`
- Linting: `flutter_lints 3.0.2`

## Architecture Summary

- `lib/app/`: app shell, theme, startup flow, loading experience
- `lib/core/`: shared constants, utilities, platform services
- `lib/data/`: repositories and local persistence
- `lib/domain/`: core models
- `lib/features/`: countdowns, entries, calendar, home, settings, shared orchestration
- `android/app/src/main/`: Android-specific widget and native integration

The app is offline-first. UI writes to local repositories, then notification and widget sync are refreshed from local state. No backend is required.

## Installation

### Prerequisites

- Flutter SDK installed and available in `PATH`
- Android Studio with Android SDK for Android builds
- Xcode for iOS builds and testing on macOS
- A connected Android device or running Android emulator

Check your environment:

```bash
flutter doctor
```

### Setup

1. Open the project folder.
2. Install dependencies:

```bash
flutter pub get
```

3. Check connected devices:

```bash
flutter devices
```

4. Run the app:

```bash
flutter run
```

To run on a specific device:

```bash
flutter run -d <device_id>
```

## Development Commands

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Build Android debug APK:

```bash
flutter build apk --debug
```

Build Android release APK:

```bash
flutter build apk --release
```

Build Android App Bundle for Play Store:

```bash
flutter build appbundle --release
```

## Install The APK On Android

To share the app directly without the Play Store, build the release APK:

```bash
flutter build apk --release
```

The APK will be generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

To install it on another Android device:

1. Copy `app-release.apk` to the phone using USB, Drive, WhatsApp, Telegram, or email.
2. Open the APK file on the phone.
3. If Android asks, allow installs from that source.
4. Tap `Install`.

For updates to work correctly later, keep using the same signing key for future builds.

## Platform Notes

### Android

- Android home screen widget support is implemented.
- Widget target selection is handled through Android widget configuration.
- Per-target reminders use local notifications and Android scheduling support.

### iOS

- Core app functionality is supported through Flutter.
- iOS home screen widgets still require WidgetKit setup in Xcode if you want widget support on iPhone.
- iOS release signing and store submission must be completed on macOS with Xcode.

## Production Notes

- The app uses local-only persistence and does not require a backend.
- Reminder scheduling is per target rather than a single global reminder.
- Startup is optimized to render Flutter UI quickly and move heavier setup behind the first frame.
- Android widget behavior is native where needed to support proper launcher integration.

## Verified In This Workspace

- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`

## Branding

- App name: `TargetTrail`
- Positioning: track milestones, stay focused, finish strong
