# Experiment 7: Firestore Employee Record Manager

**Name:** Kevin Kattakayam  
**Register number:** URK23CS7081  
**Course:** 24CS2016 - Building Applications using Flutter  
**Date of exercise:** 2026-09-21 (Monday)  
**Repository:** https://github.com/Kevin-Kattakayam/exp7

## Objective

To create a Flutter employee directory that reads employee records from Cloud Firestore and supports adding, searching, filtering, and deleting records.

## Run locally

This repository includes the Dart sources, dependency lockfile and Flutter platform folders. Use a Flutter SDK with Dart 3.11 or later, matching pubspec.yaml. Install the device/platform toolchain first.

```bash
flutter pub get
flutter analyze
flutter run -d chrome
```

Select an emulator or another supported device with `flutter devices` and `flutter run -d <device>`. The original widget tests are retained under `test/`; they have not been run in the preparation environment.

## Firebase setup

The reference contains placeholder values in `lib/firebase_options.dart`. Configure your own Firebase project before expecting live cloud operations:

1. Install/sign in to the Firebase CLI and install the FlutterFire CLI.
2. Run `flutterfire configure` in this repository to generate your platform options.
3. Create a Cloud Firestore database and configure the access rules for your authorized lab environment.
4. Run the app and verify the resulting documents in the Firestore console. Resolve any permission or composite-index errors reported by Firebase.

Official setup: https://firebase.google.com/docs/flutter/setup

The reference code includes an in-memory fallback; this resets when the process restarts and does not verify cloud persistence. Placeholder Firebase settings can initialize before a later network request fails.

## Laboratory record

- [PDF record](record/URK23CS7081_24CS2016_Exp7_2026-09-21.pdf)
- [Editable record](record/record.md)
- [Reference output images](output/)
- [Reference and source credit](ATTRIBUTION.md)

The PDF preserves the supplied reference layout and original page count. The date and repository URL have been updated for this experiment. Screenshots are from the supplied reference record, not newly captured execution evidence.

## Validation

The source imports, package declarations and record layout were checked. Flutter/Dart compilation, widget tests, device execution and live Firebase operations have not been run in the preparation environment.
