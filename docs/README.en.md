# MDFP · MD Free People

[Українська](../README.md) · [Build instructions (Russian)](BUILD.ru.md)

An Android application for capturing photos, video and audio, checking local file integrity, and submitting records and media to MD System services.

**Developed by NGO Center for Digital Trust — ГО “Центр цифрової довіри”.**

Version **1.0.3+4** · Android **8.0+** · package **org.mdsystem.mdfp**.

## Features

The app hashes captured media and a canonical record with SHA-256, signs records using Android Keystore, stores a local queue, submits metadata to the API, and uploads media to Vault. Users can choose connected networks (including cellular), unmetered networks, or manual upload. The UI supports Ukrainian, English, Russian, Spanish and Japanese and remembers the selected language.

## Development

The validated toolchain is Flutter 3.24.5 / Dart 3.5.4, Java 17, Android SDK platform 35 and build-tools 34.0.0. From the repository root:

```sh
flutter pub get && flutter analyze --no-pub && flutter test --no-pub
```

`flutter run` starts the app on an Android device. `flutter build apk --release --no-pub` creates a locally debug-signed test APK unless a release key configuration is supplied. See [build and signing](BUILD.ru.md).

## Scope

Initial registration needs network access. Android may defer uploads. Hashes establish byte integrity, not the truth of an event; hardware key protection depends on the phone. Solana Devnet is a test network. Backend services are separate from this repository.

The baseline passed static analysis and 27 tests; no physical SIM-based 4G test was performed. The supplied workflow has not run on GitHub yet.

See [architecture](ARCHITECTURE.md), [contribution guide](../CONTRIBUTING.md), [security](../SECURITY.md), and [licensing details](LICENSING.md). Original project code is licensed under the [MIT License](../LICENSE). Copyright (c) 2026 NGO Center for Digital Trust; third-party notices are preserved.
