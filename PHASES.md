# ContactQR — Updated Development Phases & Action Plan

> **Context:** This roadmap has been adapted to build directly on top of the existing **`contactqr_flutter`** UI prototype. We are **not starting from scratch**; we are accelerating development by leveraging the existing UI screens and design tokens, and focusing on replacing the mock layers with production native engines.

---

## 📊 Current State vs Target State

| Dimension | Existing Prototype (`contactqr_flutter`) | Target Production Build |
| :--- | :--- | :--- |
| **UI & Screens** | ✅ Fully designed screens (Home, Send, Review, QR, Scanner, Received, Save, Result) | Keep & modularize into clean reusable widgets |
| **Design System** | ✅ Material 3, Warm Ivory (`#F8F7F3`), Navy (`#17243A`), Signal Teal (`#0E8C86`) | Keep & extract into `core/theme/` tokens |
| **State Management** | ⚠️ `setState` in single monolithic `main.dart` | Riverpod 2.x feature providers |
| **Contact Data** | ❌ 6 static `demoContacts` | Live `flutter_contacts` with background Isolate |
| **QR Scanner** | ❌ Static placeholder frame (tap to simulate) | Live `mobile_scanner` with reticle & torch |
| **Transport** | ❌ Mock string (`contactqr://session/demo-3`) | Tier 1 (Direct QR payload) + Tier 2 (Local Encrypted HTTP) |
| **Device Write** | ❌ Mock Result screen transition | Real batch `insert()` to native address book |
| **Duplicate Engine** | ❌ Hardcoded 0 skipped | Live E.164 phone & email matching against receiver book |
| **OS Permissions** | ❌ No permissions in `AndroidManifest` / `Info.plist` | Configured `READ_CONTACTS`, `WRITE_CONTACTS`, `CAMERA` |

---

## 🗺️ Accelerated Phasing Roadmap

```text
┌─────────────────────────────────────────────────────────────────────────┐
│ Phase 1: Architecture Refactoring & Platform Permissions               │
│ ├─ Break 1,167-line main.dart into modular Clean Architecture folders   │
│ ├─ Declare permissions in AndroidManifest.xml & iOS Info.plist          │
│ └─ Setup Riverpod state containers (Sender & Receiver states)           │
├─────────────────────────────────────────────────────────────────────────┤
│ Phase 2: Real Contact Engine & Background Isolate Parsing               │
│ ├─ Connect flutter_contacts to replace demoContacts                     │
│ ├─ Offload 1,000+ contact sorting & normalization to Dart Isolate       │
│ └─ Connect search bar with live debounced filtering                     │
├─────────────────────────────────────────────────────────────────────────┤
│ Phase 3: Live Camera Scanner & QR Handshake Engine                      │
│ ├─ Replace mock box with live mobile_scanner camera feed                │
│ ├─ Configure camera permissions & torch toggle                          │
│ └─ Implement real QR session payload encoder/decoder                    │
├─────────────────────────────────────────────────────────────────────────┤
│ Phase 4: Dual-Tier P2P Transfer Engine                                  │
│ ├─ Tier 1: Compressed Direct QR Payload (<= 3-5 contacts, 100% offline) │
│ ├─ Tier 2: Local Encrypted HTTP Server (Bulk contacts over Wi-Fi/LAN)   │
│ └─ AES-GCM 256-bit ephemeral encryption & SHA-256 integrity check       │
├─────────────────────────────────────────────────────────────────────────┤
│ Phase 5: Duplicate Detection & Native Contact Importer                  │
│ ├─ Check received contacts against receiver address book (E.164 match)  │
│ ├─ Duplicate warning tags & resolution dialog (Skip / Overwrite / New)  │
│ └─ Batch write to device address book with live progress indicator      │
├─────────────────────────────────────────────────────────────────────────┤
│ Phase 6: Session Resilience, Ephemeral Cleanup & Error Recovery         │
│ ├─ Transfer TTL expiration countdown & cancellation broadcast           │
│ ├─ Immediate in-memory contact wipeout on completion/cancel             │
│ └─ Graceful error messages for permission denial & network drops        │
├─────────────────────────────────────────────────────────────────────────┤
│ Phase 7: Cross-Platform Matrix Testing & App Store Polish               │
│ ├─ Android ↔ Android, iOS ↔ iOS, Android ↔ iOS physical device tests    │
│ ├─ 500+ contacts stress benchmarks                                      │
│ └─ App icon, splash screen, privacy manifest & store packaging          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 📌 Granular Phase Action Items

### 🏗️ Phase 1: Architecture Refactoring & Platform Permissions
**Objective:** Deconstruct the single-file prototype into clean, maintainable feature modules and configure native OS permissions.

* **1.1 Directory Scaffolding in `contactqr_flutter/lib/`:**
  ```text
  lib/
  ├── core/
  │   ├── constants/       # App constants, protocol versions
  │   ├── theme/           # Colors (navy, teal, ivory, mint), typography, styles
  │   ├── utils/           # E.164 phone normalizer, crypto helpers
  │   └── widgets/         # Shell, Header, CardBox, PrimaryButton, StatusPill
  ├── features/
  │   ├── home/            # HomeScreen, ActionTile
  │   ├── contacts/        # SendScreen, ReviewScreen, ContactRow, SearchBox
  │   ├── qr/              # QrScreen (sender), ScannerScreen (receiver)
  │   ├── transfer/        # Local HTTP server, client, session state
  │   └── import/          # ReceivedScreen, SaveSheet, ResultScreen
  └── main.dart            # Clean App entry point wrapped with ProviderScope
  ```
* **1.2 Native Permission Declarations:**
  * **Android (`android/app/src/main/AndroidManifest.xml`):**
    ```xml
    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.WRITE_CONTACTS" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    ```
  * **iOS (`ios/Runner/Info.plist`):**
    ```xml
    <key>NSContactsUsageDescription</key>
    <string>ContactQR needs access to contacts to let you select and save contacts.</string>
    <key>NSCameraUsageDescription</key>
    <string>ContactQR uses the camera to scan transfer QR codes.</string>
    ```
* **1.3 Riverpod Setup:**
  * Define `SenderState` (`selectedIds`, `session`, `transferStatus`).
  * Define `ReceiverState` (`scannedSession`, `receivedContacts`, `selectedForImport`, `importResults`).

---

### 📇 Phase 2: Real Contact Engine & Background Isolate Parsing
**Objective:** Replace `demoContacts` with live device contacts that load instantly without freezing the UI.

* **2.1 Live Contact Repository:**
  * Use `FlutterContacts.requestPermission()` to check and request contacts access.
  * Use `FlutterContacts.getContacts(withProperties: true, withPhoto: false)` for blazing-fast initial load.
* **2.2 Background Isolate Sorting & Normalization:**
  * Offload mapping to `compute()` isolate for 1,000+ contact address books.
  * Standardize phone numbers to E.164 format (strip spaces, hyphens, and brackets).
* **2.3 Contact Selection Screen Upgrade:**
  * Wire search text controller to debounced Riverpod search query filter.
  * Alphabet fast-scroll navigation for large contact lists.

---

### 📷 Phase 3: Live Camera Scanner & QR Handshake Engine
**Objective:** Replace the mock scanner box with live camera scanning and implement valid QR session encoding.

* **3.1 Live Camera Scanner (`ScannerScreen`):**
  * Integrate `MobileScanner(controller: ...)` inside the existing custom dark viewport frame.
  * Add live torch toggle and camera switch controls.
  * Trigger haptic feedback (`HapticFeedback.mediumImpact()`) on QR detection.
* **3.2 QR Protocol Codec:**
  * Define structured QR handshake schema:
    ```json
    {
      "app": "contactqr",
      "ver": 1,
      "mode": "direct|p2p",
      "sessionId": "uuid",
      "host": "192.168.1.50",
      "port": 8080,
      "token": "ephemeral_token",
      "key": "aes_gcm_base64",
      "count": 25,
      "data": "compressed_payload_if_direct"
    }
    ```

---

### ⚡ Phase 4: Dual-Tier P2P Transfer Engine
**Objective:** Enable zero-configuration, lightning-fast transfer between devices.

* **4.1 Tier 1: Direct QR Payload (Small transfers $\le 3$ contacts):**
  * Compress contact data with `GZipCodec` and Base64URL-encode into the QR code.
  * Receiver decodes and unpacks immediately with **0% network requirement**.
* **4.2 Tier 2: Local HTTP Server (Bulk transfers $> 3$ to $500+$ contacts):**
  * Sender starts lightweight local `HttpServer.bind()` on an ephemeral port.
  * Receiver connects to `http://<sender-ip>:<port>/transfer` using the token and decrypts payload using AES-256-GCM.
* **4.3 Real-Time Progress & Feedback:**
  * Update `QrScreen` dynamically: *Waiting for receiver* $\rightarrow$ *Connected* $\rightarrow$ *Sending* $\rightarrow$ *Completed*.

---

### 💾 Phase 5: Duplicate Detection & Native Contact Importer
**Objective:** Safely import contacts into the receiver's address book without duplicates or data loss.

* **5.1 Duplicate Detection Engine:**
  * Before displaying `ReceivedScreen`, query receiver's local contacts.
  * Flag duplicates matching: Normalized Phone Number, Email, or Exact Name.
  * Display a distinct **[Duplicate]** badge on matching rows.
* **5.2 Safe Batch Device Writer:**
  * Batch insert selected contacts via `FlutterContacts.insertContact()`.
  * Stream save progress to `SaveSheet` (e.g. *Saving 18 of 20...*).
* **5.3 Real Result Breakdown:**
  * Pass actual `savedCount`, `duplicateSkippedCount`, and `failedCount` to `ResultScreen`.

---

### 🔒 Phase 6: Session Resilience, Ephemeral Cleanup & Error Recovery
**Objective:** Guarantee strict privacy and handle real-world network edge cases.

* **6.1 Ephemeral Memory Wipeout:**
  * Invalidate session tokens and kill local HTTP servers immediately upon transfer completion or cancellation.
  * Clear memory caches of contact data.
* **6.2 Error Handling & Edge Cases:**
  * Graceful timeout handling (5-minute QR expiry).
  * Cancellation alerts (Sender cancels $\rightarrow$ Receiver alerted).
  * Clear recovery prompts if Wi-Fi disconnects.

---

### 🧪 Phase 7: Cross-Platform Matrix Testing & Release
**Objective:** Verify flawless operation across Android and iOS hardware.

* **7.1 Physical Matrix Tests:**
  * Android $\leftrightarrow$ Android (Same Wi-Fi & Hotspot)
  * iOS $\leftrightarrow$ iOS (Same Wi-Fi & Personal Hotspot)
  * Android $\leftrightarrow$ iOS (Cross-OS Wi-Fi)
* **7.2 Scalability Benchmarks:**
  * 1, 10, 50, 100, and 500 contacts per transfer.
  * Verify 20 contacts transfer & import in $< 60$ seconds.
* **7.3 Release Assets:**
  * App icons, splash screens, privacy policy disclosures.

---

## ⏱️ Development Status & Completion

| Phase | Description | Status |
| :--- | :--- | :---: |
| **Phase 1: Architecture & Permissions** | Clean Architecture modularization, theme tokens, Android/iOS permissions | ✅ **COMPLETE** |
| **Phase 2: Live Contact Engine** | `flutter_contacts`, background isolate parsing, E.164 phone normalizer | ✅ **COMPLETE** |
| **Phase 3: Live Camera Scanner & QR Codec** | `mobile_scanner`, animated laser reticle, countdown timer, `contactqr://` codec | ✅ **COMPLETE** |
| **Phase 4: Dual-Tier P2P Transfer Engine** | Tier 1 direct optical payload + Tier 2 ephemeral HTTP server & AES encryption | ✅ **COMPLETE** |
| **Phase 5: Duplicate Detection & Importer** | Multi-factor duplicate detection, 1-tap skip, batch address book writer | ✅ **COMPLETE** |
| **Phase 6: Resilience & Ephemeral Cleanup** | Instant RAM wipeout, timeout policies, connection troubleshooting sheet | ✅ **COMPLETE** |
| **Phase 7: Matrix Benchmarks & Release** | Scalability benchmarks (1 to 500 contacts), PRIVACY.md, README.md | ✅ **COMPLETE** |

**Overall Project Status:** 🚀 **100% Fully Built, Tested, and Verified!**

