# 📱 ContactQR — Privacy-First Contact Transfer Utility

> **Move the right contacts, not your whole address book.**  
> Select a few people, show a QR code, and let the receiver choose what to save. **No accounts. No cloud. 100% Offline.**

---

## 🌟 Key Features

* 🔒 **Private by Design:** Zero cloud storage, zero telemetry, zero accounts. Contacts stay strictly between the two physical devices.
* ⚡ **Dual-Tier Transport Protocol:**
  * **Tier 1 (Direct QR Mode $\le 5$ contacts):** 100% offline, optical data compression encoded directly in the visual QR code. Works in Airplane Mode.
  * **Tier 2 (Bulk P2P Mode $> 5$ to $500+$ contacts):** High-speed local network stream over local Wi-Fi or Mobile Hotspot with ephemeral 256-bit AES encryption and SHA-256 HMAC authentication tags.
* 📇 **High-Performance Native Address Book Engine:** Reads and writes native OS contacts asynchronously with background Dart `compute()` isolate parsing and alphabetical sorting.
* 🔍 **Smart Duplicate Detection & Normalization:** Standardizes phone numbers to E.164 formats, compares core significant digits, and provides 1-tap **[Skip All]** duplicate resolution before saving.
* 📷 **Live Camera Scanner & Viewfinder:** Integrated `mobile_scanner` with target reticle laser beam animation, torch controls, and haptic feedback.
* 🛡️ **Ephemeral Memory Cleansing:** Automatically wipes session keys, clears in-memory caches, and closes sockets upon transfer completion, cancellation, or a 10-minute timeout.

---

## 🏛️ Clean Architecture Structure

```text
contactqr_flutter/
├── lib/
│   ├── core/
│   │   ├── constants/            # App constants, protocol identifiers
│   │   ├── theme/                # Premium Navy/Teal/Ivory design tokens & Material 3 theme
│   │   ├── utils/                # Phone normalizer, AES/HMAC crypto, QR codec, Network helper
│   │   └── widgets/              # Reusable Shell, Header, CardBox, PrimaryButton, StatusPill
│   ├── data/
│   │   ├── models/               # AppContact & TransferSession domain models
│   │   └── repositories/         # ContactRepository (native contacts & isolate parsing)
│   ├── features/
│   │   ├── home/                 # HomeScreen & ActionTiles (Send / Receive)
│   │   ├── contacts/             # SendScreen, ReviewScreen, ContactRow, SenderProvider
│   │   ├── qr/                   # QrScreen (sender) & ScannerScreen (receiver)
│   │   ├── transfer/             # LocalTransferServer, LocalTransferClient, TransferProvider
│   │   └── import/               # ReceivedScreen, SaveSheet modal, ResultScreen, ReceiverProvider
│   └── main.dart                 # Root ProviderScope entry point
├── test/
│   ├── crypto_utils_test.dart            # Encryption & HMAC tampering tests
│   ├── phone_normalizer_test.dart        # E.164 & fuzzy duplicate detection tests
│   ├── qr_codec_test.dart                # Protocol encoding/decoding tests
│   ├── receiver_import_test.dart         # Duplicate resolution & batch writing tests
│   ├── scalability_benchmark_test.dart   # 1 to 500 contacts transfer scalability tests
│   ├── session_resilience_test.dart      # Ephemeral wipe & connection error tests
│   ├── transfer_server_client_test.dart  # P2P Server/Client integration tests
│   └── widget_test.dart                  # UI Widget tests
└── pubspec.yaml
```

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK 3.13+](https://flutter.dev)
* Android SDK (API 34+) / Android Studio Emulator (or physical device)

### Quick Run
```bash
cd contactqr_flutter

# 1. Install dependencies
flutter pub get

# 2. Run static analysis
flutter analyze

# 3. Run all unit, integration, and benchmark tests
flutter test

# 4. Launch app on connected device / emulator
flutter run
```

---

## 🧪 Test Suite & Quality Assurance

The codebase includes comprehensive unit, widget, integration, and benchmark tests:

```bash
flutter test
```
* **Crypto Tests:** AES authenticated encryption, SHA-256 checksums, tampering detection.
* **Normalizer Tests:** E.164 formatting, core digit fuzzy comparison, email matching.
* **Protocol Codec Tests:** QR schema encode/decode, 10-minute expiry detection, legacy parsing.
* **Importer Tests:** Selective contact saving, duplicate skipping, error recovery.
* **Server/Client Tests:** Ephemeral HTTP server lifecycle, token authentication, socket teardown.
* **Scalability Benchmarks:** Transfers 1, 5, 20, 100, and 500 contacts in $< 2$ seconds.

---

## 📄 License & Privacy

* **Privacy Policy:** Read our complete [PRIVACY.md](PRIVACY.md).
* **PRD & Roadmap:** Check [PRD.md](PRD.md) and [PHASES.md](PHASES.md).
