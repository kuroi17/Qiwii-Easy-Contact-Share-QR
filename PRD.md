# Product Requirements Document (PRD)

# ContactQR

**Product Type:** Mobile Utility Application
**Status:** Product Definition / Pre-Development
**Version:** 1.0
**Primary Platform:** Android + iOS
**Primary Goal:** Fast, controlled, privacy-first transfer of multiple contacts between devices using QR-assisted local transfer.

---

# 1. Product Overview

## 1.1 Product Summary

ContactQR is a mobile application that allows a user to **select multiple contacts from their device, initiate a QR-assisted transfer, and allow another device to receive, review, selectively import, and save those contacts** without manually entering contact information.

The application is designed around a simple interaction:

```text
SENDER

Select Contacts
      ↓
Generate Transfer QR
      ↓
RECEIVER
Scan QR
      ↓
Review Received Contacts
      ↓
Select / Remove Contacts
      ↓
Save to Device
```

The sender controls **what contacts are offered**, while the receiver controls **which of those offered contacts are ultimately saved**.

The receiver cannot add contacts that were not included in the sender's transfer.

---

# 2. Problem Statement

Transferring multiple contacts between devices can be unnecessarily tedious.

Common approaches include:

- Manually entering phone numbers.
- Manually creating contacts one by one.
- Sending screenshots of phone numbers.
- Sending contacts individually.
- Exporting/importing an entire contact database.
- Using complicated phone migration tools.
- Sharing a contact file without giving the receiver a convenient selection interface.

These approaches create friction when users only want to transfer **a specific subset of contacts**.

## Core Problem

> Users need a fast way to transfer a selected set of contacts from one device to another without manually entering each contact and without forcing the receiver to import the entire contact list.

---

# 3. Proposed Solution

ContactQR introduces a **sender-controlled, receiver-approved contact transfer workflow**.

### Sender

The sender:

1. Opens ContactQR.
2. Grants contact permission.
3. Selects contacts.
4. Reviews the selection.
5. Starts a transfer.
6. Displays a QR code.

### Receiver

The receiver:

1. Opens ContactQR.
2. Scans the sender's QR code.
3. Receives the offered contacts.
4. Reviews the contact list.
5. Removes/deselects unwanted contacts.
6. Saves the remaining contacts directly to the device.

---

# 4. Product Vision

> **Make transferring a group of contacts as easy as scanning a QR code.**

The product should feel:

- Fast
- Simple
- Private
- Offline-friendly
- Understandable to non-technical users
- Safe against accidental imports
- Minimal in configuration

The user should not need to understand networking, file formats, vCards, databases, or device migration.

---

# 5. Goals

## 5.1 Primary Goals

- Enable users to transfer multiple contacts quickly.
- Eliminate manual contact entry.
- Allow sender-side contact selection.
- Allow receiver-side approval.
- Prevent unwanted contacts from being automatically saved.
- Minimize required setup.
- Support offline/local transfers where technically possible.
- Avoid requiring user accounts.
- Avoid cloud storage for contact data.
- Protect transferred contact information.
- Provide clear transfer status and error handling.

---

# 6. Non-Goals

The initial version will **not** attempt to:

- Replace the native Contacts application.
- Synchronize contacts continuously between devices.
- Maintain a cloud address book.
- Provide permanent contact backups.
- Automatically merge entire address books.
- Transfer SMS messages.
- Transfer call history.
- Transfer photos.
- Transfer applications.
- Transfer arbitrary files.
- Require user registration.
- Build a social network around contacts.

These may be considered for future versions.

---

# 7. Target Users

## 7.1 Primary Users

### Users changing phones

Example:

```text
Old Phone
100 contacts

New Phone
0 contacts

User only wants:
30 important contacts
```

ContactQR allows the user to transfer only those 30.

---

### Family members

A parent wants to send several family and emergency contacts to a child's phone.

---

### Students

A student wants to share a group of classmates' contact numbers with another student.

---

### Teams

A team leader wants to distribute a list of team members' contacts.

---

### Small businesses

A business owner wants to share selected employee/customer/business contacts with another device.

---

# 8. Core Product Principles

## 8.1 Sender Controls the Dataset

The sender determines which contacts are available for transfer.

```text
Sender's Contacts
       ↓
Selected Contacts
       ↓
Transfer Dataset
```

Contacts not selected by the sender must never appear on the receiver's device.

---

## 8.2 Receiver Controls Final Import

Scanning must **not automatically save contacts**.

The receiver must see a confirmation screen first.

```text
Scan
 ↓
Preview
 ↓
Selection
 ↓
Save
```

---

## 8.3 No Unexpected Data

The application must never silently import contacts.

---

## 8.4 Privacy First

Contact information is sensitive.

The product should favor:

- Local processing
- Minimal data retention
- No account requirement
- No cloud storage
- No unnecessary analytics containing contact information

---

# 9. Core User Flow

# 9.1 Sender Flow

```text
Open App
   ↓
Home
   ↓
Send Contacts
   ↓
Contacts Permission
   ↓
Contact Selection
   ↓
Select Contacts
   ↓
Review Selection
   ↓
Start Transfer
   ↓
Generate QR
   ↓
Display QR
   ↓
Wait for Receiver
   ↓
Transfer
   ↓
Transfer Complete
```

---

# 9.2 Receiver Flow

```text
Open App
   ↓
Home
   ↓
Receive Contacts
   ↓
Camera Permission
   ↓
QR Scanner
   ↓
Scan QR
   ↓
Connect / Receive
   ↓
Contact Preview
   ↓
Select / Deselect
   ↓
Save Contacts
   ↓
Contacts Permission
   ↓
Import
   ↓
Result
```

---

# 10. Application Screens

## 10.1 Splash Screen

### Purpose

Provide application initialization.

### Requirements

- Application logo.
- Application name.
- Minimal loading time.
- Check basic local state.
- Navigate to Home.

---

# 10.2 Home Screen

The home screen should immediately communicate the two primary actions.

### Primary Actions

```text
ContactQR

Transfer contacts quickly.

[ Send Contacts ]

[ Receive Contacts ]
```

### Optional

- Recent transfer count.
- Help button.
- Privacy information.
- Settings.

---

# 10.3 Send Contacts Screen

Displays contacts from the device.

### Components

- Search bar.
- Contact list.
- Contact avatar/initial.
- Contact name.
- Primary phone number.
- Selection indicator.
- Select All.
- Deselect All.
- Selected count.
- Continue button.

### Example

```text
Send Contacts

[ Search contacts... ]

☑ John Cruz
  +63 9XX XXX XXXX

☑ Maria Santos
  +63 9XX XXX XXXX

☐ Kevin Tan
  +63 9XX XXX XXXX

-------------------

3 contacts selected

[ Continue ]
```

---

# 10.4 Contact Selection Requirements

Users must be able to:

- Select one contact.
- Select multiple contacts.
- Select all contacts.
- Deselect individual contacts.
- Deselect all contacts.
- Search contacts.
- Review selected contacts.

### Validation

If zero contacts are selected:

```text
Please select at least one contact.
```

---

# 10.5 Selection Review Screen

Before creating the transfer, the sender should see the final dataset.

### Example

```text
Review Contacts

3 contacts will be shared.

✓ John Cruz
✓ Maria Santos
✓ Kevin Tan

[ Back ]
[ Generate Transfer ]
```

This provides an additional safety checkpoint.

---

# 10.6 QR Transfer Screen

The sender receives a transfer QR.

### Components

- Large QR code.
- Number of contacts.
- Transfer status.
- Waiting indicator.
- Cancel button.
- Instructions.

Example:

```text
Ready to Transfer

3 contacts

Ask the receiver to scan this QR code.

[ QR CODE ]

Waiting for receiver...

[ Cancel ]
```

---

# 10.7 Receiver Scanner

The receiver sees a camera-based scanner.

### Components

- Camera preview.
- Scanning frame.
- Instructions.
- Flash toggle.
- Cancel button.

Example:

```text
Receive Contacts

Scan the QR code shown
on the sender's device.

[ CAMERA ]

Align QR code inside frame.
```

---

# 10.8 Transfer Connection Screen

After scanning, the receiver may need to establish a local transfer session.

Example:

```text
Connecting...

Connecting to sender
Preparing 25 contacts...

Please keep both devices nearby.
```

---

# 10.9 Received Contacts Preview

This is one of the **most important product screens**.

The receiver must not automatically save anything.

### Components

- Sender/transfer information.
- Number of received contacts.
- Search.
- Select All.
- Deselect All.
- Contact list.
- Save button.

Example:

```text
Received Contacts

25 contacts received

☑ John Cruz
☑ Maria Santos
☐ Kevin Tan
☑ Ana Reyes

-------------------

20 selected

[ Save Selected Contacts ]
```

---

# 10.10 Receiver Restrictions

The receiver:

### CAN

- Select contacts.
- Deselect contacts.
- Remove contacts from the import selection.
- Search received contacts.
- Save selected contacts.

### CANNOT

- Add a new contact that was not included in the transfer.
- Modify the sender's dataset to include external contacts.
- Access the sender's entire address book.

This maintains the sender/receiver data boundary.

---

# 10.11 Save Confirmation

Before importing:

```text
Save Contacts?

20 contacts will be added
to your device.

[ Cancel ]

[ Save Contacts ]
```

---

# 10.12 Contacts Permission

The app must request Contacts write permission only when needed.

Example:

```text
Allow ContactQR to add contacts
to your device?
```

If denied:

```text
Contacts permission is required
to save received contacts.
```

---

# 10.13 Import Result Screen

After saving:

```text
Transfer Complete

✓ 18 contacts saved
⚠ 2 contacts skipped

[ View Details ]

[ Done ]
```

Possible result categories:

- Successfully saved.
- Duplicate detected.
- Failed.
- Missing required information.

---

# 11. Contact Data Model

The application should support, where platform APIs permit:

```text
Contact
├── Name
│   ├── First name
│   ├── Middle name
│   └── Last name
├── Phone numbers
│   ├── Mobile
│   ├── Home
│   ├── Work
│   └── Other
├── Emails
│   ├── Personal
│   ├── Work
│   └── Other
├── Organization
├── Job title
├── Addresses
├── Birthday
├── Notes
├── Photo
└── Other supported contact fields
```

The MVP should prioritize:

1. Name
2. Phone numbers
3. Email addresses

Additional fields should be supported when reliably available.

---

# 12. Contact Normalization

Before transfer, contact information should be normalized where practical.

Examples:

```text
09XXXXXXXXX
```

and

```text
+639XXXXXXXXX
```

may represent the same phone number.

Normalization should help duplicate detection but must avoid destructive modification of the original contact data.

---

# 13. Duplicate Detection

The receiver may already have some of the transferred contacts.

The application should detect likely duplicates.

### Possible matching criteria

- Exact phone number.
- Normalized phone number.
- Exact email.
- Strong name + phone match.

Example:

```text
Possible Duplicate

John Cruz
+63 912 345 6789

Already exists on your device.

[ Skip ]
[ Save Anyway ]
```

The app must **never silently overwrite existing contacts**.

---

# 14. QR Architecture

A critical architectural requirement is recognizing that QR codes have limited storage capacity.

A large contact list should **not simply be placed entirely inside one QR code**.

## Recommended Architecture

Use the QR code primarily as a **transfer handshake/session identifier**.

```text
Sender
   │
   │ Create transfer session
   ↓
Transfer Session
   │
   │ Generate QR
   ↓
QR Code
   │
   │ Scan
   ↓
Receiver
   │
   │ Establish local connection
   ↓
Contact Dataset Transfer
```

---

# 15. QR Payload

The QR payload may contain:

```text
Protocol version
Transfer/session ID
Device/session information
Connection information
Security information
Expiration information
```

Example conceptual payload:

```json
{
  "protocol": "contactqr",
  "version": 1,
  "sessionId": "...",
  "expiresAt": "...",
  "connection": {
    "type": "local"
  }
}
```

The exact implementation should be determined during technical design.

---

# 16. Large Transfer Strategy

For small datasets:

```text
QR
 ↓
Encoded contact payload
 ↓
Receiver
```

For larger datasets:

```text
QR
 ↓
Session handshake
 ↓
Local connection
 ↓
Chunked contact transfer
```

The system should support chunking if necessary.

---

# 17. Transfer Protocol

The transfer protocol should include:

- Protocol version.
- Session identifier.
- Dataset metadata.
- Contact count.
- Transfer chunks.
- Checksum/integrity validation.
- Completion message.
- Cancellation message.
- Timeout handling.

Conceptual flow:

```text
SESSION_CREATED
      ↓
QR_SCANNED
      ↓
RECEIVER_CONNECTED
      ↓
TRANSFER_INITIALIZED
      ↓
CONTACT_CHUNKS_SENT
      ↓
TRANSFER_VALIDATED
      ↓
TRANSFER_COMPLETE
```

---

# 18. Transfer Security

Because contact data is sensitive, transfer security is required.

## Requirements

- Do not transmit contact data through an unnecessary cloud server.
- Use secure local communication.
- Encrypt sensitive transfer payloads when appropriate.
- Use temporary session identifiers.
- Expire sessions.
- Prevent replaying old transfers.
- Reject malformed transfer data.
- Do not expose contact data in logs.

---

# 19. Transfer Session Lifecycle

Each transfer should have a temporary session.

```text
Created
  ↓
Waiting
  ↓
Connected
  ↓
Transferring
  ↓
Completed
```

Alternative termination states:

```text
Cancelled
Expired
Failed
```

After completion:

- Temporary transfer data should be deleted.
- Session should become invalid.
- QR should no longer be usable.

---

# 20. QR Expiration

QR transfer sessions should have a limited lifetime.

Example:

```text
Transfer expired.

Generate a new QR code to continue.
```

This prevents old transfer sessions from remaining usable indefinitely.

---

# 21. Offline Requirements

The core product should aim to work **without requiring internet access**.

Internet connectivity should not be necessary for:

- Reading contacts.
- Selecting contacts.
- Generating QR.
- Scanning QR.
- Local transfer.
- Saving contacts.

If a particular transfer technology requires Wi-Fi infrastructure, the architecture should clearly distinguish:

- Internet connection.
- Local network connection.
- Device-to-device connection.

---

# 22. Permissions

## Contacts Read Permission

Required for sender.

Purpose:

> Read contacts so you can select which contacts to transfer.

---

## Camera Permission

Required for receiver.

Purpose:

> Scan the sender's transfer QR code.

---

## Contacts Write Permission

Required for receiver.

Purpose:

> Save selected received contacts to your device.

---

# 23. Permission Denial Handling

Every permission must have graceful failure behavior.

Example:

```text
Contacts Access Needed

ContactQR needs access to your
contacts so you can choose which
ones to transfer.

[ Open Settings ]
[ Cancel ]
```

The app must not repeatedly request denied permissions without appropriate user interaction.

---

# 24. Privacy Requirements

## No Account Required

The user should not need:

- Email
- Password
- Phone verification
- Social login

---

## No Cloud Contact Database

Contact information should not be uploaded to a centralized database for the core functionality.

---

## Temporary Data

Transfer data should exist only as long as required.

After transfer:

```text
Temporary transfer data
        ↓
Delete
```

---

## Logging

Logs must not contain:

- Phone numbers
- Email addresses
- Full contact names
- Contact notes

Use anonymized identifiers where logging is required.

---

# 25. Error Handling

The application must handle the following cases.

## Sender Errors

- Contacts permission denied.
- No contacts found.
- No contacts selected.
- QR generation failure.
- Local transfer initialization failure.
- Receiver disconnects.
- Transfer timeout.
- Transfer cancelled.

---

## Receiver Errors

- Camera permission denied.
- Invalid QR.
- Expired QR.
- Unsupported QR version.
- Sender unavailable.
- Transfer interrupted.
- Corrupted dataset.
- Contacts permission denied.
- Duplicate contacts.
- Device storage failure.

---

# 26. User-Facing Error Messages

Messages should be understandable.

Avoid:

```text
ERR_SESSION_403
```

Prefer:

```text
This transfer has expired.
Ask the sender to generate a new QR code.
```

---

# 27. Transfer Cancellation

Both users should be able to cancel.

### Sender

```text
[ Cancel Transfer ]
```

### Receiver

```text
[ Cancel ]
```

Cancellation should immediately invalidate the active transfer session where possible.

---

# 28. Transfer Progress

For large transfers:

```text
Transferring Contacts

████████████░░░░

78 / 100 contacts

Keep both devices nearby.
```

---

# 29. Contact Import Rules

The receiver must explicitly approve saving.

### Default behavior

All received contacts may initially be selected.

The receiver can then deselect unwanted contacts.

Example:

```text
Received: 50
Selected: 50

Receiver deselects 7

Selected: 43

43 contacts will be saved.
```

---

# 30. Partial Failure Handling

If some contacts fail:

```text
Transfer Complete

43 contacts selected

✓ 41 saved
⚠ 2 failed
```

The user should be able to view failed contacts and retry where technically possible.

---

# 31. Search

Search should work on:

- First name
- Last name
- Full name
- Phone number
- Email
- Organization

Example:

```text
Search: "John"

→ John Cruz
→ John Santos
→ Johnny Tan
```

---

# 32. Sorting

Default sorting:

```text
Alphabetical by display name
```

Optional future sorting:

- Recently added.
- Organization.
- Selected first.

---

# 33. Contact Photos

Contact photos may be displayed in the UI.

For MVP:

- Photo transfer is optional.
- Contact text information has higher priority.

If photos significantly increase transfer size or complexity, defer photo transfer.

---

# 34. Accessibility

The app should support:

- Screen readers.
- Accessible labels.
- Sufficient touch target sizes.
- Dynamic text scaling where possible.
- High contrast.
- Clear status messages.
- Non-color-only selection indicators.

QR scanning instructions should not rely solely on color.

---

# 35. Internationalization

The architecture should allow future localization.

Initial language:

- English

Potential future:

- Filipino
- Other major supported languages

Phone number handling should support international formats.

---

# 36. Performance Requirements

The app should:

- Load contact lists efficiently.
- Avoid freezing when hundreds/thousands of contacts exist.
- Use virtualized lists.
- Avoid unnecessary re-rendering.
- Process transfers asynchronously.
- Display progress for large transfers.

---

# 37. Scalability

The app should support:

### MVP target

At least:

- 500 contacts per transfer.

### Future target

- 1,000+
- 5,000+

Performance should degrade gracefully rather than crash.

---

# 38. State Management

The application should clearly separate:

### Sender State

```text
contacts
selectedContacts
transferSession
transferStatus
```

### Receiver State

```text
receivedContacts
selectedReceivedContacts
scanStatus
transferStatus
importStatus
```

Temporary transfer state must not become permanent application data unless explicitly required.

---

# 39. Suggested Data Structures

Conceptually:

```typescript
Contact {
  id
  displayName
  firstName
  middleName
  lastName
  phones[]
  emails[]
  organization
  jobTitle
  addresses[]
  notes
}
```

Transfer:

```typescript
TransferSession {
  sessionId
  protocolVersion
  createdAt
  expiresAt
  contactCount
  status
}
```

---

# 40. Navigation

Recommended navigation structure:

```text
Home
├── Send Contacts
│   ├── Contact Selection
│   ├── Review
│   └── QR Transfer
│
└── Receive Contacts
    ├── Scanner
    ├── Connecting
    ├── Received Contacts
    ├── Save Confirmation
    └── Result
```

---

# 41. Settings

Initial settings may include:

- Privacy information.
- App permissions.
- About.
- Version.
- Help.

Future:

- Default contact import behavior.
- Transfer timeout.
- Theme.
- Language.
- Advanced transfer options.

---

# 42. Security Threat Model

The application should consider:

### Malicious QR

A malicious QR should not cause arbitrary code execution or unsafe behavior.

---

### Fake Transfer

The application should validate the protocol and session.

---

### Replay

Expired/completed sessions should not be reusable.

---

### Data Tampering

Transferred data should be validated for integrity.

---

### Unauthorized Access

Only the intended active transfer session should be able to exchange data.

---

### Accidental Import

Prevented through the receiver preview and confirmation flow.

---

# 43. Data Validation

Before saving contacts, validate:

- Contact object structure.
- Phone number format where applicable.
- Email format where applicable.
- String length limits.
- Unexpected/malformed fields.
- Duplicate records.
- Unsupported fields.

Never trust received data blindly.

---

# 44. UX Principles

## Principle 1 — Three Steps

The product should feel close to:

```text
Select
→ Scan
→ Save
```

---

## Principle 2 — No Technical Language

Do not expose:

- Protocol
- Payload
- Endpoint
- Session token
- Packet
- Encryption key

unless displayed in an advanced/debug environment.

---

## Principle 3 — Preview Before Import

Always:

```text
Receive
→ Review
→ Save
```

Never:

```text
Scan
→ Automatically save
```

---

# 45. MVP Feature Set

## P0 — Mandatory

- [ ] Home screen
- [ ] Send Contacts
- [ ] Receive Contacts
- [ ] Read device contacts
- [ ] Contact search
- [ ] Multi-select contacts
- [ ] Select all
- [ ] Deselect all
- [ ] Selection review
- [ ] QR generation
- [ ] QR scanning
- [ ] Transfer session
- [ ] Contact data transfer
- [ ] Received contact preview
- [ ] Receiver selection/deselection
- [ ] Contacts write permission
- [ ] Save selected contacts
- [ ] Duplicate handling
- [ ] Transfer cancellation
- [ ] Transfer expiration
- [ ] Error handling
- [ ] Transfer success screen
- [ ] Local/offline-first operation
- [ ] Temporary transfer data cleanup

---

# 46. P1 Features

- [ ] Large contact transfer optimization
- [ ] Transfer progress
- [ ] Partial failure reporting
- [ ] Advanced duplicate detection
- [ ] Contact field preservation
- [ ] Contact photos
- [ ] Improved accessibility
- [ ] Transfer history
- [ ] Dark mode
- [ ] Localization

---

# 47. P2 Features

- [ ] Wi-Fi Direct optimization
- [ ] Bluetooth fallback
- [ ] Cross-platform transfer improvements
- [ ] Contact groups
- [ ] Saved transfer templates
- [ ] Contact backup
- [ ] vCard import/export
- [ ] QR-only small-data mode
- [ ] Nearby device discovery

---

# 48. Future Product Expansion

The underlying transfer architecture could eventually support more than contacts.

Potential transferable data:

```text
Contacts
   ↓
Wi-Fi Credentials
   ↓
Calendar Events
   ↓
Notes
   ↓
Text
   ↓
Small Files
```

This could evolve ContactQR into a broader **offline device-to-device sharing utility**.

However, the initial product should remain focused on contacts.

---

# 49. Recommended Technical Stack

## Mobile

**Flutter + Dart**

---

## Device Contacts

Use a Flutter-compatible contacts plugin that integrates with the native Android and iOS Contacts APIs.

Recommended options to evaluate:

- `flutter_contacts`
- Native Android Contacts APIs
- Native iOS Contacts framework

The implementation should support:

- Reading contacts for the sender.
- Writing selected contacts for the receiver.
- Accessing supported contact fields such as names, phone numbers, emails, organizations, addresses, notes, and photos where available.

---

## QR

Use mature Flutter packages for QR generation and scanning.

Recommended options to evaluate:

- `mobile_scanner` for QR scanning.
- `qr_flutter` for QR generation.

The QR code should primarily contain a transfer handshake or session identifier rather than the entire contact dataset for large transfers.

---

## Local Transfer

Preferred architecture:

```text
QR
 ↓
Handshake
 ↓
Local device connection
 ↓
Encrypted transfer
```

The exact transport should be selected based on Android and iOS capabilities and Flutter plugin/native integration support.

Potential technologies to evaluate:

- Local Wi-Fi
- Wi-Fi Direct
- Bluetooth/BLE
- Nearby device APIs
- Local HTTP/WebSocket transfer

Platform-specific native code or Flutter plugins may be required for certain Android and iOS transfer technologies.

The technical implementation should not be locked to QR payload storage.

---

## State Management

Recommended:

- Riverpod

The application should separate sender and receiver state clearly.

### Sender State

```text
contacts
selectedContacts
transferSession
transferStatus
```

### Receiver State

```text
receivedContacts
selectedReceivedContacts
scanStatus
transferStatus
importStatus
```

---

## Local Storage

Optional Flutter-compatible storage may be used for non-sensitive app metadata, such as:

- User preferences.
- Onboarding state.
- App settings.
- Temporary session metadata where necessary.

Potential options to evaluate:

- SharedPreferences
- Hive
- SQLite or Drift

Transferred contact data should not be permanently stored unless explicitly required. Temporary transfer data must be deleted after completion, cancellation, expiration, or failure.

---

## Architecture

Recommended:

- Clean Architecture or feature-based architecture.
- Repository pattern.
- Riverpod for dependency injection and state management.
- Separate domain, data, and presentation layers.
- Platform-specific services for contacts, camera, networking, Bluetooth, and device APIs.
- Flutter platform channels or maintained plugins where native functionality is required.

Suggested feature structure:

```text
lib/
├── core/
│   ├── errors/
│   ├── security/
│   ├── networking/
│   └── utilities/
├── features/
│   ├── home/
│   ├── contacts/
│   ├── qr/
│   ├── transfer/
│   ├── import/
│   └── permissions/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
└── presentation/
    ├── widgets/
    ├── themes/
    └── routing/
```

---

## Important Technical Consideration

Flutter is suitable for the ContactQR user interface, contact selection, QR generation, QR scanning, state management, validation, and import workflow.

The primary technical challenge remains the cross-platform local transfer layer, especially Android-to-iOS and iOS-to-Android communication. Flutter can support this through plugins, platform channels, and native Android/iOS implementations where necessary.

---

# 50. Architecture

Conceptual architecture:

```text
┌─────────────────────────────┐
│        ContactQR App        │
├─────────────────────────────┤
│ UI Layer                    │
│                             │
│ Home                        │
│ Contact Selection            │
│ QR Scanner                   │
│ QR Display                   │
│ Contact Preview              │
│ Import Result                │
├─────────────────────────────┤
│ Application Layer           │
│                             │
│ Contact Manager              │
│ Transfer Manager             │
│ QR Manager                   │
│ Permission Manager           │
│ Validation                   │
│ Duplicate Detection          │
├─────────────────────────────┤
│ Transfer Layer              │
│                             │
│ Session Management           │
│ Local Transport              │
│ Encryption                   │
│ Chunking                     │
│ Integrity Verification       │
├─────────────────────────────┤
│ Device APIs                 │
│                             │
│ Contacts                     │
│ Camera                       │
│ Network / Bluetooth          │
└─────────────────────────────┘
```

---

# 51. Analytics

Analytics should be privacy-conscious.

Allowed anonymous events:

```text
app_opened
send_started
receive_started
qr_generated
qr_scanned
transfer_completed
transfer_failed
contacts_saved
```

Do NOT collect:

- Contact names.
- Phone numbers.
- Emails.
- Contact contents.

Analytics should be optional and transparent if implemented.

---

# 52. Success Metrics

## Primary Metric

### Successful Contact Transfer Rate

```text
successful transfers
--------------------
initiated transfers
```

Target:

> ≥ 90% successful transfers under supported conditions.

---

## Secondary Metrics

- Average time from selection to saved contacts.
- Average contacts transferred per session.
- Transfer failure rate.
- QR scan success rate.
- Import success rate.
- Permission abandonment rate.

---

# 53. Product Success Definition

The product is successful if a user can:

> Select 20 contacts → generate QR → another phone scans → receiver removes 3 → saves 17 contacts

in **under one minute** under normal conditions, without manually typing any contact information.

---

# 54. Acceptance Criteria

## Sender

### AC-01

Given Contacts permission is granted, the sender can view device contacts.

### AC-02

The sender can select multiple contacts.

### AC-03

The sender cannot generate a transfer with zero contacts.

### AC-04

The sender can review selected contacts before transfer.

### AC-05

The sender can generate a valid transfer QR.

---

## Receiver

### AC-06

The receiver can scan a valid QR.

### AC-07

The receiver sees the contacts included in the transfer.

### AC-08

The receiver can deselect any received contact.

### AC-09

The receiver cannot add contacts outside the received dataset.

### AC-10

The receiver must explicitly confirm saving.

### AC-11

Only selected contacts are saved.

---

## Security

### AC-12

Expired transfers cannot be reused.

### AC-13

Cancelled transfers cannot continue.

### AC-14

Malformed transfer data is rejected.

### AC-15

Contact information is not permanently stored by the transfer system.

---

## Error Handling

### AC-16

Permission denial results in a clear explanation.

### AC-17

Invalid QR codes produce a clear error.

### AC-18

Interrupted transfers can be cancelled safely.

### AC-19

Partial import failures are reported.

---

# 55. Example Complete Scenario

## Sender

George has:

```text
150 contacts
```

He wants to share:

```text
20 contacts
```

He opens ContactQR.

```text
Send Contacts
```

Searches and selects 20.

```text
20 contacts selected
```

He reviews them.

```text
Generate Transfer
```

The app creates a QR session.

---

## Receiver

Another user opens ContactQR.

```text
Receive Contacts
```

They scan the QR.

The devices establish the transfer.

The receiver sees:

```text
20 contacts received
```

The receiver deselects 4.

```text
16 selected
```

They press:

```text
Save Contacts
```

The application saves the 16 selected contacts.

Result:

```text
✓ 16 contacts saved
```

The transfer session expires.

Temporary transfer information is deleted.

---

# 56. Edge Case Scenarios

## Scenario A — Sender selects nothing

```text
Cannot continue.
Select at least one contact.
```

---

## Scenario B — Receiver scans expired QR

```text
This transfer has expired.
Ask the sender to generate a new QR.
```

---

## Scenario C — Receiver already has contact

```text
Possible duplicate detected.
```

Receiver chooses:

```text
Skip
or
Save Anyway
```

---

## Scenario D — Sender cancels

Receiver sees:

```text
Transfer cancelled by sender.
```

---

## Scenario E — Receiver cancels

Sender sees:

```text
Receiver cancelled the transfer.
```

---

## Scenario F — Connection lost

```text
Connection lost.

The transfer could not be completed.

[ Retry ]
[ Cancel ]
```

---

## Scenario G — Contacts permission denied

The app explains why permission is required and provides a settings path where supported.

---

# 57. Privacy Policy Requirements

Before production release, the project should provide a privacy policy covering:

- Contacts access.
- Camera access.
- Data processing.
- Transfer architecture.
- Data retention.
- Analytics, if any.
- Third-party services, if any.
- User rights.

The privacy policy must accurately reflect the actual implementation.

---

# 58. App Store / Play Store Considerations

The production version should prepare:

- Application icon.
- Screenshots.
- App description.
- Privacy policy.
- Permission explanations.
- Data safety disclosures.
- App category.
- Support/contact information.
- Terms where necessary.

Permissions must have legitimate functionality tied to the core product.

---

# 59. Development Phases

## Phase 1 — Foundation

- Project setup.
- Navigation.
- UI system.
- Permission handling.
- Contact API integration.

---

## Phase 2 — Contact Selection

- Contact list.
- Search.
- Multi-select.
- Select all.
- Review.

---

## Phase 3 — QR

- QR generation.
- QR scanning.
- QR validation.
- Session creation.

---

## Phase 4 — Transfer

- Local connection.
- Dataset serialization.
- Transfer protocol.
- Validation.
- Progress.
- Cancellation.
- Timeout.

---

## Phase 5 — Import

- Contact preview.
- Receiver selection.
- Duplicate detection.
- Contact creation.
- Result reporting.

---

## Phase 6 — Security & Privacy

- Session expiration.
- Secure transfer.
- Data cleanup.
- Logging review.
- Permission review.

---

## Phase 7 — Testing

Test:

- Android → Android
- iOS → iOS
- Android → iOS
- iOS → Android

Test:

- 1 contact
- 10 contacts
- 100 contacts
- 500+ contacts

Test:

- No internet.
- Same Wi-Fi.
- Different Wi-Fi.
- Bluetooth availability.
- Permission denial.
- Interrupted connection.

---

# 60. Definition of Done

The MVP is considered complete when:

- [ ] Users can select contacts from their device.
- [ ] Users can generate a transfer QR.
- [ ] Another device can scan the QR.
- [ ] Contacts can be transferred.
- [ ] Receiver can preview contacts.
- [ ] Receiver can deselect contacts.
- [ ] Receiver cannot add contacts outside the received dataset.
- [ ] Receiver can save selected contacts.
- [ ] Duplicate contacts are handled safely.
- [ ] Transfer failures are handled gracefully.
- [ ] Sessions expire.
- [ ] Temporary data is removed.
- [ ] Core functionality works without cloud storage.
- [ ] Permissions are handled correctly.
- [ ] Android and iOS behavior is documented/tested.
- [ ] No contact information is unnecessarily logged or uploaded.

---

# 61. Core Product Differentiator

ContactQR is **not simply a QR contact-sharing application**.

The key experience is:

```text
SELECTIVE BULK TRANSFER
        +
QR-ASSISTED CONNECTION
        +
RECEIVER REVIEW
        +
SELECTIVE IMPORT
        +
NO MANUAL TYPING
```

The most important UX distinction is:

> **The sender decides what can be shared; the receiver decides what gets saved.**

This creates a controlled transfer mechanism rather than an all-or-nothing contact migration system.

---

# 62. One-Sentence Product Definition

> **ContactQR is a privacy-first mobile utility that lets users select multiple contacts, transfer them to another device through a QR-assisted local connection, and let the receiver review and selectively save them without manually entering contact information.**
