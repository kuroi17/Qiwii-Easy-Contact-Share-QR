import 'dart:convert';
import '../../data/models/contact_model.dart';
import '../../data/models/transfer_session_model.dart';

class QrProtocolException implements Exception {
  final String message;
  const QrProtocolException(this.message);
  @override
  String toString() => message;
}

class QrExpiredException extends QrProtocolException {
  const QrExpiredException([super.message = 'This transfer QR code has expired.']);
}

class QrCodec {
  static const String protocolScheme = 'contactqr://';
  static const String protocolName = 'contactqr';
  static const int currentVersion = 1;

  /// Encodes a TransferSession into a QR-friendly string.
  static String encodeSession(TransferSession session) {
    final payload = {
      'app': protocolName,
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
    };

    final jsonString = jsonEncode(payload);
    final base64Payload = base64UrlEncode(utf8.encode(jsonString));
    return '$protocolScheme$base64Payload';
  }

  /// Convenience method to generate a Direct QR transfer for small datasets (<= 5 contacts).
  static String encodeDirectContacts(
    List<AppContact> contacts, {
    int timeoutMinutes = 10,
    String? customSessionId,
  }) {
    final contactsJson = contacts.map((c) => c.toJson()).toList();
    final dataString = jsonEncode(contactsJson);
    final compressedData = base64UrlEncode(utf8.encode(dataString));

    final session = TransferSession(
      sessionId: customSessionId ?? 'direct-${DateTime.now().millisecondsSinceEpoch}',
      protocolVersion: currentVersion,
      mode: TransferMode.direct,
      contactCount: contacts.length,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(minutes: timeoutMinutes)),
      directPayload: compressedData,
    );

    return encodeSession(session);
  }

  /// Decodes and validates raw QR data into a TransferSession.
  static TransferSession decode(String rawData) {
    if (rawData.trim().isEmpty) {
      throw const QrProtocolException('Scanned QR code is empty.');
    }

    // Check for legacy or plain demo format
    if (rawData.startsWith('contactqr://session/demo-')) {
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

    // Support contactqr:// protocol scheme
    if (rawData.startsWith(protocolScheme)) {
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

    if (map['app'] != protocolName) {
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
    );
  }

  /// Decodes direct contact payload if session contains embedded data.
  static List<AppContact> decodeDirectPayload(String? base64Data) {
    if (base64Data == null || base64Data.isEmpty) return [];

    try {
      final decodedJson = utf8.decode(base64Url.decode(base64Data));
      final List<dynamic> list = jsonDecode(decodedJson) as List<dynamic>;
      return list.map((item) => AppContact.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw const QrProtocolException('Failed to unpack embedded contact data.');
    }
  }
}
