import 'dart:convert';
import '../../data/models/contact_model.dart';
import '../../data/models/transfer_session_model.dart';
import 'crypto_utils.dart';

class QrProtocolException implements Exception {
  final String message;
  const QrProtocolException(this.message);
  @override
  String toString() => message;
}

class QrExpiredException extends QrProtocolException {
  const QrExpiredException([super.message = 'This transfer QR code has expired.']);
}

class QrPinRequiredException extends QrProtocolException {
  final TransferSession session;
  const QrPinRequiredException(this.session, [super.message = 'This transfer is protected with a 4-digit PIN.']);
}

class QrCodec {
  static const String protocolScheme = 'contactqr://';
  static const String qiwiiScheme = 'qiwii://';
  static const String protocolName = 'contactqr';
  static const String qiwiiName = 'qiwii';
  static const int currentVersion = 1;

  /// Encodes a TransferSession into a QR-friendly string.
  static String encodeSession(TransferSession session) {
    final payload = {
      'app': qiwiiName,
      'v': session.protocolVersion,
      'mode': session.mode == TransferMode.direct ? 'direct' : 'p2p',
      'id': session.sessionId,
      'count': session.contactCount,
      'exp': session.expiresAt.millisecondsSinceEpoch,
      if (session.host != null) 'host': session.host,
      if (session.port != null) 'port': session.port,
      if (session.token != null) 'token': session.token,
      if (session.encryptionKey != null) 'key': session.encryptionKey,
      if (session.directPayload != null) 'data': session.directPayload,
      if (session.isPinProtected) 'pin': true,
      if (session.pinSalt != null) 'salt': session.pinSalt,
    };

    final jsonString = jsonEncode(payload);
    final base64Payload = base64UrlEncode(utf8.encode(jsonString));
    return '$qiwiiScheme$base64Payload';
  }

  /// Convenience method to generate a Direct QR transfer for small datasets (<= 5 contacts), optionally PIN-protected.
  static String encodeDirectContacts(
    List<AppContact> contacts, {
    int timeoutMinutes = 10,
    String? customSessionId,
    String? pin,
  }) {
    final contactsJson = contacts.map((c) => c.toJson()).toList();
    final dataString = jsonEncode(contactsJson);

    String compressedData;
    String? pinSalt;
    bool isPinProtected = false;

    if (pin != null && pin.trim().isNotEmpty) {
      pinSalt = CryptoUtils.generateRandomToken(length: 16);
      final derivedKey = CryptoUtils.deriveKeyFromPin(pin.trim(), pinSalt);
      compressedData = CryptoUtils.encryptPayload(dataString, derivedKey);
      isPinProtected = true;
    } else {
      compressedData = base64UrlEncode(utf8.encode(dataString));
    }

    final session = TransferSession(
      sessionId: customSessionId ?? 'direct-${DateTime.now().millisecondsSinceEpoch}',
      protocolVersion: currentVersion,
      mode: TransferMode.direct,
      contactCount: contacts.length,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(minutes: timeoutMinutes)),
      directPayload: compressedData,
      isPinProtected: isPinProtected,
      pinSalt: pinSalt,
    );

    return encodeSession(session);
  }

  /// Decodes and validates raw QR data into a TransferSession.
  static TransferSession decode(String rawData) {
    if (rawData.trim().isEmpty) {
      throw const QrProtocolException('Scanned QR code is empty.');
    }

    // Check for legacy or plain demo format
    if (rawData.startsWith('contactqr://session/demo-') || rawData.startsWith('qiwii://session/demo-')) {
      final countStr = rawData.split('demo-').last;
      final count = int.tryParse(countStr) ?? 3;
      return TransferSession(
        sessionId: 'demo-$count',
        protocolVersion: currentVersion,
        mode: TransferMode.direct,
        contactCount: count,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      );
    }

    String jsonString;

    // Support qiwii:// and contactqr:// protocol schemes
    if (rawData.startsWith(qiwiiScheme)) {
      final base64Payload = rawData.substring(qiwiiScheme.length);
      try {
        final decodedBytes = base64Url.decode(base64Payload);
        jsonString = utf8.decode(decodedBytes);
      } catch (e) {
        throw const QrProtocolException('Invalid QR code data format.');
      }
    } else if (rawData.startsWith(protocolScheme)) {
      final base64Payload = rawData.substring(protocolScheme.length);
      try {
        final decodedBytes = base64Url.decode(base64Payload);
        jsonString = utf8.decode(decodedBytes);
      } catch (e) {
        throw const QrProtocolException('Invalid QR code data format.');
      }
    } else if (rawData.trim().startsWith('{') && rawData.trim().endsWith('}')) {
      jsonString = rawData.trim();
    } else {
      throw const QrProtocolException('Unrecognized QR code. Please scan a Qiwii code.');
    }

    Map<String, dynamic> map;
    try {
      map = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      throw const QrProtocolException('Corrupted QR code payload.');
    }

    final appName = map['app'] as String?;
    if (appName != protocolName && appName != qiwiiName) {
      throw const QrProtocolException('Not a valid Qiwii transfer code.');
    }

    final version = map['v'] as int? ?? 1;
    if (version > currentVersion) {
      throw QrProtocolException('This QR code requires a newer version of Qiwii (v$version).');
    }

    final expTimestamp = map['exp'] as int?;
    if (expTimestamp != null) {
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(expTimestamp);
      if (DateTime.now().isAfter(expiresAt)) {
        throw const QrExpiredException();
      }
    }

    final expiresAt = expTimestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(expTimestamp)
        : DateTime.now().add(const Duration(minutes: 10));

    return TransferSession(
      sessionId: map['id'] as String? ?? 'unknown-session',
      protocolVersion: version,
      mode: map['mode'] == 'p2p' ? TransferMode.localNetwork : TransferMode.direct,
      contactCount: map['count'] as int? ?? 0,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      host: map['host'] as String?,
      port: map['port'] as int?,
      token: map['token'] as String?,
      encryptionKey: map['key'] as String?,
      directPayload: map['data'] as String?,
      isPinProtected: map['pin'] as bool? ?? false,
      pinSalt: map['salt'] as String?,
    );
  }

  /// Decodes direct contact payload if session contains embedded data.
  /// If [pin] is provided, uses PIN key derivation to decrypt the payload.
  static List<AppContact> decodeDirectPayload(String? payloadData, {String? pin, String? salt}) {
    if (payloadData == null || payloadData.isEmpty) return [];

    try {
      String jsonString;
      if (pin != null && pin.trim().isNotEmpty && salt != null) {
        final derivedKey = CryptoUtils.deriveKeyFromPin(pin.trim(), salt);
        jsonString = CryptoUtils.decryptPayload(payloadData, derivedKey);
      } else {
        // Plain base64 decode
        jsonString = utf8.decode(base64Url.decode(payloadData));
      }

      final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
      return list.map((item) => AppContact.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      if (pin != null) {
        throw const QrProtocolException('Incorrect 4-digit PIN. Unable to unlock contacts.');
      }
      throw const QrProtocolException('Failed to unpack embedded contact data.');
    }
  }
}
