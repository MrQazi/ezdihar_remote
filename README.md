# ezdihar_remote

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Download the app

- **Latest main build (for testing):**
  https://github.com/MrQazi/ezdihar_remote/releases/tag/main-latest
  — one pre-release, replaced by every push to `main` that passes analyze + test.
- **Numbered releases:** https://github.com/MrQazi/ezdihar_remote/releases
  (`v<version>-build<run>`, published from the `release` branch).

Every APK (local, `main`, `release`) is signed with the same debug key
(`android/app/debug.keystore`; the app is never published to a store), so any build
installs over any other.

## CI builds

`.github/workflows/android.yml` runs analyze, test and a release-mode APK build on every
push to `main`, every PR into `main` and every push to `release`. The APK is named
`ezdihar_remote_v<version>_build<run>_<sha>.apk`.

- `main`: the APK replaces the `main-latest` pre-release (link above).
- `release`: publishes a GitHub Release tagged `v<version>-build<run>`, only for a commit
  whose `main` run passed. To release: push to `main`, wait for it to pass, then
  fast-forward `release` to that commit and push it.
- Pull requests only build (the APK is attached to the run).

Bump `version:` in `pubspec.yaml` to change the version part; the run number is the
Android build number.
