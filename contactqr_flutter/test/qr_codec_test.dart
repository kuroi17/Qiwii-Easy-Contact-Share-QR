import 'package:flutter_test/flutter_test.dart';
import 'package:contactqr_flutter/core/utils/qr_codec.dart';
import 'package:contactqr_flutter/data/models/contact_model.dart';
import 'package:contactqr_flutter/data/models/transfer_session_model.dart';

void main() {
  group('QrCodec Tests', () {
    test('encodes and decodes session round-trip', () {
      final originalSession = TransferSession(
        sessionId: 'sess-12345',
        protocolVersion: 1,
        mode: TransferMode.localNetwork,
        contactCount: 15,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
        host: '192.168.1.50',
        port: 8080,
        token: 'auth-token-xyz',
        encryptionKey: 'aes-key-base64',
      );

      final encoded = QrCodec.encodeSession(originalSession);
      expect(encoded.startsWith('qiwii://'), true);

      final decoded = QrCodec.decode(encoded);
      expect(decoded.sessionId, 'sess-12345');
      expect(decoded.contactCount, 15);
      expect(decoded.mode, TransferMode.localNetwork);
      expect(decoded.host, '192.168.1.50');
      expect(decoded.port, 8080);
      expect(decoded.token, 'auth-token-xyz');
      expect(decoded.encryptionKey, 'aes-key-base64');
    });

    test('encodes and unpacks direct contact payload', () {
      const contacts = [
        AppContact(id: '1', name: 'Maya Chen', phone: '+14155550198', initials: 'MC', email: 'maya@chen.com'),
        AppContact(id: '2', name: 'Jordan Rivera', phone: '+14155550142', initials: 'JR'),
      ];

      final encoded = QrCodec.encodeDirectContacts(contacts, timeoutMinutes: 5);
      final session = QrCodec.decode(encoded);

      expect(session.mode, TransferMode.direct);
      expect(session.contactCount, 2);

      final unpacked = QrCodec.decodeDirectPayload(session.directPayload);
      expect(unpacked.length, 2);
      expect(unpacked[0].name, 'Maya Chen');
      expect(unpacked[0].phone, '+14155550198');
      expect(unpacked[0].email, 'maya@chen.com');
      expect(unpacked[1].name, 'Jordan Rivera');
    });

    test('encodes and unpacks 4-digit PIN protected direct payload', () {
      const contacts = [
        AppContact(id: '1', name: 'Liam Vance', phone: '+14155550199', initials: 'LV'),
      ];
      const pin = '7890';

      final encoded = QrCodec.encodeDirectContacts(contacts, pin: pin);
      final session = QrCodec.decode(encoded);

      expect(session.isPinProtected, true);
      expect(session.pinSalt != null, true);

      // Unpack with correct PIN
      final unpacked = QrCodec.decodeDirectPayload(
        session.directPayload,
        pin: pin,
        salt: session.pinSalt,
      );
      expect(unpacked.length, 1);
      expect(unpacked[0].name, 'Liam Vance');

      // Unpack with wrong PIN fails
      expect(
        () => QrCodec.decodeDirectPayload(
          session.directPayload,
          pin: '0000',
          salt: session.pinSalt,
        ),
        throwsA(isA<QrProtocolException>()),
      );
    });

    test('throws QrExpiredException when QR code is expired', () {
      final expiredSession = TransferSession(
        sessionId: 'expired-123',
        protocolVersion: 1,
        mode: TransferMode.direct,
        contactCount: 1,
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      final encoded = QrCodec.encodeSession(expiredSession);
      expect(() => QrCodec.decode(encoded), throwsA(isA<QrExpiredException>()));
    });

    test('rejects unrecognized or non-Qiwii strings', () {
      expect(() => QrCodec.decode(''), throwsA(isA<QrProtocolException>()));
      expect(() => QrCodec.decode('https://google.com'), throwsA(isA<QrProtocolException>()));
      expect(() => QrCodec.decode('{"app":"otherapp"}'), throwsA(isA<QrProtocolException>()));
    });

    test('decodes legacy demo format for testing', () {
      final session = QrCodec.decode('contactqr://session/demo-5');
      expect(session.sessionId, 'demo-5');
      expect(session.contactCount, 5);
    });
  });
}
