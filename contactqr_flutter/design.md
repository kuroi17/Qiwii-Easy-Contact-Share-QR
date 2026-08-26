# ContactQR Flutter Design Plan

## Brand direction

ContactQR uses a warm ivory canvas, deep navy typography, and signal teal actions. The interface is deliberately restrained: large titles, 44-point-or-larger touch targets, explicit consent before imports, and no account or cloud language that would imply hidden retention.

## Screens

| Screen | Responsibility |
|---|---|
| Home | Establish the privacy promise and offer the two primary actions: send or receive contacts. |
| Send contacts | Search and select multiple contacts from the sender dataset. |
| Review selection | Show the exact sender-controlled dataset before a QR session is created. |
| Transfer | Display a QR handshake/session payload and waiting state. |
| Receive scanner | Provide the camera-scanning surface and nearby-device instructions. |
| Received contacts | Let the receiver review, search, select, and deselect only the offered contacts. |
| Save confirmation | Explain the exact import count and state that existing contacts are not silently overwritten. |
| Transfer complete | Report saved and skipped counts and return to Home. |

## Planned Flutter architecture

The prototype currently keeps the screens in `lib/main.dart` to make review straightforward. The production pass should split this into feature-based modules aligned with the PRD: `features/home`, `features/contacts`, `features/qr`, `features/transfer`, `features/import`, and `features/permissions`. Riverpod should own separate sender and receiver state providers, while repositories should isolate native contacts, QR scanning/generation, local transport, and import behavior from presentation widgets.

## Native integration boundary

The next implementation layer should replace demo contacts with `flutter_contacts`, replace the scanner simulation with `mobile_scanner`, and retain `qr_flutter` for the handshake QR. The QR must carry a short, expiring session identifier rather than the full dataset. A platform-aware encrypted local transport should then move the selected contact payload after the handshake. Temporary payloads should be deleted on completion, cancellation, expiry, or failure.
