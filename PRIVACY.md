# 🔒 ContactQR — Privacy Policy & Architecture Disclosure

**Effective Date:** August 2026  
**Product:** ContactQR (Mobile App for Android & iOS)

---

## 1. Core Philosophy: Private by Design

ContactQR is engineered from the ground up on the principle of **Zero-Cloud, Zero-Account, Zero-Data Retention**.

* **No Accounts:** You do not need to create an account, log in, or provide any personal identifiers to use ContactQR.
* **No Cloud Servers:** ContactQR does not maintain or connect to any cloud databases, external APIs, telemetry collectors, or remote backend servers.
* **Direct Peer-to-Peer:** All contact transfers occur directly between the sender's physical device and the receiver's physical device.
* **Sender & Receiver Autonomy:** The sender chooses precisely which contacts to offer, and the receiver chooses precisely which contacts to save.

---

## 2. Technical Transfer Architecture

ContactQR operates using a **Dual-Tier Transport Protocol**:

### Tier 1: Direct Optical QR Mode ($\le 5$ Contacts)
* Contact data is compressed and encoded directly into the visual 2D matrix of the QR code.
* **Network Usage:** **0% (100% Offline)**. No Wi-Fi, Cellular, or Bluetooth radio is active.
* Data transmission occurs purely via camera optical scanning.

### Tier 2: Bulk Local Area Network Mode ($> 5$ to $500+$ Contacts)
* The sender device binds a temporary, local-only HTTP server on a random ephemeral port accessible only to devices on the same local Wi-Fi or Personal Hotspot.
* **Encryption:** Payload is encrypted with ephemeral 256-bit AES keys generated randomly for each session.
* **Integrity:** SHA-256 HMAC authentication tags prevent data tampering or eavesdropping.
* **Ephemeral Cleanup:** Upon transfer completion, cancellation, or a 10-minute timeout, all session keys, socket listeners, and cached data in RAM are immediately wiped.

---

## 3. Device Permissions & Justifications

ContactQR requests only the minimal native permissions required for core functionality:

| Permission | Platform | Purpose & Justification |
| :--- | :--- | :--- |
| **Read Contacts** (`READ_CONTACTS` / `NSContactsUsageDescription`) | Android / iOS | Used exclusively on-device to display your contact list so you can select which contacts to share. |
| **Write Contacts** (`WRITE_CONTACTS` / `NSContactsUsageDescription`) | Android / iOS | Used exclusively on-device to save contacts approved by the receiver directly into the device's native address book. |
| **Camera** (`CAMERA` / `NSCameraUsageDescription`) | Android / iOS | Used strictly to scan the sender's QR code viewfinder. No photos or video frames are ever recorded or stored. |
| **Local Network / Wi-Fi** (`INTERNET`, `ACCESS_WIFI_STATE`) | Android | Used strictly for local P2P socket communication between the two phones on the same Wi-Fi or Hotspot. Never communicates with the public internet. |

---

## 4. App Store & Play Store Compliance

* **Google Play Data Safety:** ContactQR declares **"No data collected"** and **"No data shared with third parties"**.
* **Apple App Privacy Details:** ContactQR declares **"Data Not Collected"**.
* **GDPR & CCPA Compliance:** Because ContactQR never transmits, stores, or processes personal data outside the user's physical devices, it inherently satisfies strict international data sovereignty standards.

---

## 5. Contact & Inquiries

For technical questions or audit inquiries, visit our open-source repository:  
[ContactQR GitHub Repository](https://github.com/kuroi17/ContactShareQR)
