# ContactQR Flutter Rebuild

ContactQR is a privacy-first mobile utility for transferring a selected group of contacts between nearby devices through a QR-assisted local session. This project is implemented in **Flutter + Dart**, matching the technology stack specified in the product requirements document.

## Implemented prototype flows

The current Flutter prototype includes the branded home screen, sender contact search and multi-select, a sender review checkpoint, QR generation using `qr_flutter`, a receiver scanner-style screen, received-contact review and deselection, an explicit save confirmation sheet, and an import result screen. The receiver cannot add contacts outside the offered dataset in the current state model, and no contact is saved silently.

## PRD-aligned dependencies

The project declares `flutter_contacts` for native contact read/write integration, `mobile_scanner` for camera QR scanning, `qr_flutter` for QR generation, `flutter_riverpod` for the planned state-management layer, and `shared_preferences` for non-sensitive local metadata. The current UI uses deterministic demo contact data so the flows can be reviewed without requesting device permissions in a simulator or browser.

## Validation

`dart format`, `flutter analyze`, and the Flutter widget test suite pass. A debug Android APK was not produced in the sandbox because no Android SDK is installed. Native contacts, camera scanning, local transfer transport, duplicate detection, and device import are intentionally the next integration layer; the corresponding production-shaped screens and dependency choices are already in place.

## Run locally

Install Flutter with Android and/or iOS tooling, then run:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

For the native MVP, replace the deterministic demo repository with `flutter_contacts`, connect `mobile_scanner` to `ScannerScreen`, and add the encrypted local transport behind the QR session handshake.
