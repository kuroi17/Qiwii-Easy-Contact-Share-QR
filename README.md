<div align="center">

<img src="./docs/QiwiiLogo.png" alt="Qiwii Logo" width="80" height="80" />

# Qiwii

**Fast, Private & Seamless Contact Sharing**

*A privacy-first, offline-capable contact transfer utility built to move specific contacts instantly with zero cloud storage, 4-digit PIN security, and optical/P2P transfer.*

[![Flutter](https://img.shields.io/badge/Flutter-3.13+-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev/)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.6-385072?style=flat-square)](https://riverpod.dev/)
[![Material 3](https://img.shields.io/badge/UI-Material_3_Ember-FF7A1A?style=flat-square)](https://m3.material.io/)
[![Zero Cloud](https://img.shields.io/badge/Storage-100%25_Offline-10B981?style=flat-square)](./PRIVACY.md)
[![Security](https://img.shields.io/badge/Security-AES_GCM_256_+_PBKDF2-blue?style=flat-square)](./PRIVACY.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](./LICENSE)

</div>

---

## Project Status

> **Active Open-Source Project** — Qiwii is built with a modern Warm Almond & Orange Ember design system, featuring offline transfers, PIN encryption, Android deep linking, live camera scanning, gallery image decoding, and an automated web redirector.

---

## Overview

**Qiwii** is a cross-platform Flutter utility designed to solve a fundamental mobile pain point: sharing specific contacts between devices quickly, privately, and without syncing entire address books to third-party cloud servers.

With Qiwii, users select the exact contacts they wish to share, set an optional 4-digit security PIN, and generate either a high-density direct QR code or an ultra-compact encrypted transfer link. The receiver simply scans the QR code or opens the link, enters the PIN, and reviews/imports the contacts with built-in duplicate detection.

---

## The Problem

Traditional contact sharing is clunky, invasive, or insecure:

- **All-or-Nothing Cloud Syncing:** Syncing contacts requires Google or iCloud accounts, uploading entire address books to remote databases.
- **Fragmented vCard Files:** Exporting `.vcf` files through messaging apps produces messy attachments that require multiple steps to import and clutter file managers.
- **Privacy Leaks in Public Transfers:** Sharing contact details in groups or public spaces leaves numbers exposed without PIN protection or expiration limits.
- **Duplicate Clutter:** Importing contacts often creates duplicate entries with inconsistent formatting and broken country codes.

---

## The Solution

Qiwii provides a frictionless, zero-cloud transfer workflow that keeps data strictly between the two communicating devices:

1. **Selective Sharing:** Pick 1 or 500+ contacts—only what you choose leaves your screen.
2. **End-to-End PIN Protection:** Encrypt payloads using PBKDF2 HMAC-SHA256 and AES-GCM-256 with a 4-digit PIN.
3. **Dual-Tier Transport Protocol:** Direct optical QR compression for small batches (works in Airplane Mode) and encrypted local P2P hotspot streams for large batches.
4. **Smart Duplicate Resolution:** Automatically normalizes phone numbers to E.164, detects existing contacts, and provides 1-tap duplicate skipping.
5. **Universal Deep Linking & Web Bridge:** Clicking a shared link in Messenger or WhatsApp seamlessly redirects into the app via GitHub Pages with auto-clipboard detection.

---

## Key Features

### 4-Digit PIN Security & Compact Encryption
- **PBKDF2 Key Derivation:** Derives 256-bit AES keys using HMAC-SHA256 with 10,000 iterations and cryptographic salts.
- **Ultra-Compact Binary Packing:** Formats ciphertext into `[IV (16B) + HMAC Tag (32B) + CipherText (NB)]`, dropping link length by **>70%** (~300 chars for 14 contacts).
- **Brute-Force Lockout:** Prevents unauthorized guessing with a 5-attempt threshold, visual shake animations, and error lockout modals.

### Dual-Tier Transfer Protocol
- **Tier 1 (Direct QR Mode $\le 5$ contacts):** Encodes compressed contact payloads directly into the visual QR matrix. 100% offline with zero network connectivity needed.
- **Tier 2 (Bulk P2P Mode $> 5$ to $500+$ contacts):** Spawns an ephemeral encrypted local HTTP server over local Wi-Fi or Mobile Hotspot for instant high-speed transfers.

### Multi-Channel Scanner & Gallery Decoder
- **Live Camera Scanner:** High-performance viewfinder with target reticle laser beam animation, torch toggle, and haptic feedback.
- **Gallery & Screenshot Picker:** Upload QR images from device photos or file managers, powered by `qr_code_dart_decoder` for cross-platform web and mobile decoding.
- **Auto-Clipboard Detection:** Automatically detects Qiwii transfer codes in the clipboard on app launch or resume, prompting an instant **Unlock & Import Contacts** sheet.

### Intelligent Address Book Engine
- **Duplicate Prevention:** Compares normalized E.164 phone numbers and case-insensitive emails against existing device contacts.
- **Selective Batch Import:** Review contacts before saving with a 1-tap **Skip All Duplicates** resolution filter.
- **Background Isolate Processing:** Parses and sorts hundreds of contacts off the UI thread via background Dart `compute()` isolates.

### Smart Web Redirector Bridge
- **GitHub Pages Landing Page (`docs/index.html`):** Resolves in-app browser DNS blocks in Messenger/WhatsApp, launching the app instantly via custom `qiwii://` URL scheme with manual clipboard fallback.

---

## Technical Architecture

```text
contactqr_flutter/
├── lib/
│   ├── core/
│   │   ├── constants/            # Protocol identifiers, timeouts, and limits
│   │   ├── theme/                # Material 3 Warm Almond & Orange Ember design system
│   │   ├── utils/                # CryptoUtils, QrCodec, PhoneNormalizer, NetworkHelper
│   │   └── widgets/              # Shell, Header, ActionTile, StatusPill, ErrorDialog
│   ├── data/
│   │   ├── models/               # AppContact, TransferSession, TransferMode domain models
│   │   └── repositories/         # ContactRepository (Native OS contact isolate parsing)
│   ├── features/
│   │   ├── home/                 # HomeScreen, deep link stream listeners, clipboard watcher
│   │   ├── contacts/             # SendScreen, ReviewScreen, search & multi-select state
│   │   ├── qr/                   # QrScreen, ScannerScreen, SetPinModal, EnterPinModal
│   │   ├── transfer/             # LocalTransferServer, LocalTransferClient, TransferProvider
│   │   ├── import/               # ReceivedScreen, SaveSheet, duplicate resolution filter
│   │   └── info/                 # PrivacyPolicyScreen, LicensesScreen
│   └── main.dart                 # Root ProviderScope application entry
├── test/                         # Comprehensive unit, widget, and scalability benchmarks
└── docs/                         # Live GitHub Pages redirector and assets
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.13+ (Dart 3.0+) |
| **State Management** | Flutter Riverpod 2.6 |
| **Design System** | Custom Material 3 (Warm Almond `#FAF1E8` & Orange Ember `#FF7A1A`) |
| **Camera & Barcode** | `mobile_scanner` + `qr_flutter` |
| **Image & QR Decoding** | `image_picker` + `qr_code_dart_decoder` |
| **Cryptography** | AES-GCM-256 + PBKDF2 HMAC-SHA256 (`crypto`) |
| **Deep Linking** | `app_links` (`qiwii://`, `contactqr://`, GitHub Pages) |
| **Native Contacts** | `flutter_contacts` with background isolates |

---

## Getting Started

### Prerequisites

- [Flutter SDK 3.13+](https://flutter.dev)
- Android SDK (API 21+) / Physical Device / Chrome for Web
- Git

Verify your Flutter environment:

```bash
flutter doctor
```

### 1. Clone the Repository

```bash
git clone https://github.com/kuroi17/Qiwii-Easy-Contact-Share-QR.git
cd Qiwii-Easy-Contact-Share-QR/contactqr_flutter
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run Static Analysis & Tests

```bash
# Verify 0 analysis issues
flutter analyze

# Run all 30 unit, integration, and benchmark tests
flutter test
```

### 4. Run the Application

```bash
# Launch on Android Device / Emulator
flutter run

# Launch on Chrome Web Browser
flutter run -d chrome
```

---

## Test Suite & Benchmarks

The project includes an automated test suite verifying correctness, cryptography, and scalability:

```bash
flutter test
```

- **Crypto Tests:** AES authenticated encryption, PBKDF2 key derivation, tampering resistance.
- **Normalizer Tests:** E.164 standardization, fuzzy phone comparison, case-insensitive email matching.
- **Protocol Codec Tests:** URL encoding/decoding, binary cipher unpacking, 10-minute expiry validation.
- **Importer Tests:** Selective contact saving, duplicate flags, metrics calculation.
- **Scalability Benchmarks:** Transfers 1, 5, 20, 100, and 500 contacts in $< 2$ seconds.

---

## Privacy & Security Policy

Qiwii is built on a **Zero-Cloud Guarantee**:
- No user accounts or registrations.
- No analytics, telemetry, or tracker SDKs.
- No remote servers—all transfers occur peer-to-peer or optically.
- Ephemeral memory cleansing wipes keys and sockets after transfer completion.

Read the full [PRIVACY.md](PRIVACY.md) document for details.

---

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/MyFeature`).
3. Ensure all tests pass (`flutter test` and `flutter analyze`).
4. Commit your changes (`git commit -m 'feat: add some feature'`).
5. Push to the branch (`git push origin feature/MyFeature`).
6. Open a Pull Request.

---

## License

This project is licensed under the [MIT License](./LICENSE).

---

<div align="center">

Built for seamless, private contact sharing · **Qiwii**

[GitHub Repository](https://github.com/kuroi17/Qiwii-Easy-Contact-Share-QR) · [Report an Issue](https://github.com/kuroi17/Qiwii-Easy-Contact-Share-QR/issues) · [Web Redirector](https://kuroi17.github.io/Qiwii-Easy-Contact-Share-QR/)

</div>
