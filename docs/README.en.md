<p align="center">
  <img src="../assets/images/logo.png" width="180" alt="MDFP — MD Free People">
</p>

<h1 align="center">MDFP · MD Free People</h1>

<p align="center">
  <a href="../README.md">Українська</a> ·
  <a href="BUILD.ru.md">Build instructions (Russian)</a> ·
  <a href="ARCHITECTURE.md">Architecture</a>
</p>

An Android application for capturing photos, video and audio directly on the device, verifying cryptographic byte integrity under the **MDFP1** protocol, and submitting signed records and media to MD System services.

**Developed by NGO Center for Digital Trust — ГО “Центр цифрової довіри”.**

Version **1.0.3+4** · Android **8.0+** (target API 35) · package **org.mdsystem.mdfp**.

- **Prebuilt Test APK:** [`MDFP-1.0.3-test.apk`](../MDFP-1.0.3-test.apk) (`73.86 MB`, `77,451,351` bytes)
- **SHA-256:** `ff780ce202649b98cc0b319631da8dc6ff4118413812bbe20500f0d57fd3d78b`

---

## Public Architecture & MDFP1 Protocol Diagram

<p align="center">
  <img src="images/mdfp-architecture-flow.svg" width="100%" alt="MDFP1 Public Architecture & Cryptographic Lifecycle">
</p>

```mermaid
flowchart LR
    subgraph Client["📱 Android Client (org.mdsystem.mdfp)"]
        A["In-App Capture<br/>Photo / Video / Audio + Optional GPS"] --> B["Streaming SHA-256<br/>file_sha256 + file_size"]
        B --> C["Canonical JSON (MDFP1)<br/>record_digest = SHA-256(json)"]
        C --> D["Android Keystore Sign<br/>ECDSA P-256 over 'MDFP1\\n' || json"]
        D --> E["Offline Queue & Local Store<br/>Workmanager (15m)"]
    end

    subgraph Services["☁️ External MD System Services"]
        F["API Aggregator<br/>POST /v1/records"]
        G["Independent Media Vault<br/>POST /vault/upload"]
        H["Solana Blockchain (Devnet)<br/>Merkle Root Anchoring"]
        F --> H
    end

    E -->|"Channel A: Metadata + Signature (Any network)"| F
    E -->|"Channel B: Media File (Wi-Fi+4G/5G | Wi-Fi | Manual)"| G
```

## Features

The app hashes captured media and a canonical record with `SHA-256`, signs records using **Android Keystore** (`ecdsa-p256-sha256`), computes an RFC-6962 domain-separated Merkle leaf (`0x00 || record_digest || signature`), stores an offline-resilient local queue, submits metadata to the API aggregator, and uploads media to an independent Vault. Users can choose connected networks (including cellular 4G/5G), unmetered networks (`Wi-Fi Only`), or manual upload. The UI supports **Ukrainian, English, Russian, Spanish and Japanese** and persists the selected language.

---

## Application Screenshots

| Onboarding & Language Selection | Permission Rationale | System Location Permission |
| :---: | :---: | :---: |
| <img src="screenshots/01-onboarding.jpg" width="250" alt="Onboarding"> | <img src="screenshots/02-permissions-rationale.jpg" width="250" alt="Permission rationale"> | <img src="screenshots/03-system-location-permission.jpg" width="250" alt="System location permission"> |

| Live Capture (Photo / Video / Audio) | Record Details & Public QR Digest | Receipt & Media Export |
| :---: | :---: | :---: |
| <img src="screenshots/04-capture-screen.jpg" width="250" alt="Capture screen"> | <img src="screenshots/05-record-details.jpg" width="250" alt="Record details"> | <img src="screenshots/06-record-receipt-export.jpg" width="250" alt="Receipt export"> |

| Local Integrity Check | Language & Upload Policy | Security & Protocol Info |
| :---: | :---: | :---: |
| <img src="screenshots/07-integrity-check.jpg" width="250" alt="Integrity check"> | <img src="screenshots/08-settings-language-upload.jpg" width="250" alt="Settings language and upload"> | <img src="screenshots/09-settings-security-about.jpg" width="250" alt="Settings security and about"> |

---

## Development

The validated toolchain is Flutter 3.24.5 / Dart 3.5.4, Java 17, Android SDK platform 35 and build-tools 34.0.0. From the repository root:

```sh
flutter pub get && flutter analyze --no-pub && flutter test --no-pub
```

`flutter run` starts the app on an Android device. `flutter build apk --release --no-pub` creates a locally debug-signed test APK unless a release key configuration is supplied. See [build and signing](BUILD.ru.md).

## Scope

Initial registration needs network access. Android may defer uploads. Hashes establish byte integrity, not the truth of an event; hardware key protection depends on the phone. Solana Devnet is a test network. Backend services are separate from this repository.

The baseline passed static analysis and 27 tests; no physical SIM-based 4G test was performed.

## Independent Assessment

1. **Deterministic Cryptographic Protocol (`MDFP1`)**: Canonical JSON (`MdfpRecord`) uses lexicographically sorted keys, zero whitespace, and integer micro-degrees (`lat_e6`, `lon_e6`, `acc_m`) to eliminate cross-platform floating-point drift. Domain separation is enforced both at signing (`"MDFP1\n"`) and at Merkle leaf construction (`0x00` prefix per RFC-6962). `StreamingHasher` hashes media streams without loading large videos into RAM.
2. **Split-Channel Offline-First Delivery (`SyncQueueManager`)**: Lightweight canonical metadata and signatures are dispatched over any available connection (`Channel A`) to secure an immediate timestamp and queue blockchain anchoring, while heavy media files (`Channel B`) are uploaded independently to Vault under user-controlled network policies (`Wi-Fi + 4G/5G`, `Wi-Fi Only`, or `Manual`).
3. **Defense-in-Depth UX & Keystore Isolation**: Gallery import is disabled by design; private keys (`ecdsa-p256-sha256`) stay inside Android Keystore; public QR codes expose only `record_digest` and never leak the private `record_token`.
4. **Transparent Trust Boundaries**: Both the UI and documentation clearly state what cryptographic proofs establish (byte integrity and device key possession at capture time) and what they do not replace (independent verification of physical events).

See [architecture](ARCHITECTURE.md), [independent assessment (RU)](ASSESSMENT.ru.md), [contribution guide](../CONTRIBUTING.md), [security](../SECURITY.md), and [licensing details](LICENSING.md). Original project code is licensed under the [MIT License](../LICENSE). Copyright (c) 2026 NGO Center for Digital Trust; third-party notices are preserved.
