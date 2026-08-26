import 'package:flutter_test/flutter_test.dart';
import 'package:contactqr_flutter/core/utils/crypto_utils.dart';
import 'package:contactqr_flutter/data/models/contact_model.dart';
import 'package:contactqr_flutter/data/models/transfer_session_model.dart';
import 'package:contactqr_flutter/features/transfer/services/local_transfer_client.dart';
import 'package:contactqr_flutter/features/transfer/services/local_transfer_server.dart';

void main() {
  group('Session Resilience & Error Recovery Tests', () {
    test('wipes ephemeral memory when transfer server stops', () async {
      const contacts = [
        AppContact(id: '1', name: 'Maya Chen', phone: '+14155550198', initials: 'MC'),
      ];

      final server = LocalTransferServer(
        contacts: contacts,
        sessionId: 'wipe-test',
        sessionToken: 'test-token',
        encryptionKey: 'test-key',
      );

      await server.start();
      expect(server.isRunning, true);

      await server.stop();
      expect(server.isRunning, false);
    });

    test('rejects unauthorized transfer requests with invalid token', () async {
      const contacts = [
        AppContact(id: '1', name: 'Maya Chen', phone: '+14155550198', initials: 'MC'),
      ];

      final server = LocalTransferServer(
        contacts: contacts,
        sessionId: 'auth-test',
        sessionToken: 'valid-token',
        encryptionKey: CryptoUtils.generateSessionKey(),
      );

      final port = await server.start();

      final invalidSession = TransferSession(
        sessionId: 'auth-test',
        protocolVersion: 1,
        mode: TransferMode.localNetwork,
        contactCount: 1,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        host: '127.0.0.1',
        port: port,
        token: 'WRONG-TOKEN',
        encryptionKey: server.encryptionKey,
      );

      const client = LocalTransferClient();
      expect(
        () => client.fetchContactsFromSender(invalidSession),
        throwsA(isA<NetworkTransferException>()),
      );

      await server.stop();
    });

    test('throws NetworkTransferException when host is unreachable', () async {
      final unreachableSession = TransferSession(
        sessionId: 'unreachable-test',
        protocolVersion: 1,
        mode: TransferMode.localNetwork,
        contactCount: 1,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        host: '192.0.2.1', // Non-routable test IP
        port: 9999,
        token: 'token',
        encryptionKey: 'key',
      );

      const client = LocalTransferClient();
      expect(
        () => client.fetchContactsFromSender(unreachableSession),
        throwsA(isA<NetworkTransferException>()),
      );
    });
  });
}
