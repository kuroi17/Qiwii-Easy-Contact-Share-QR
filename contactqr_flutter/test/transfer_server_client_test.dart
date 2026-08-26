import 'package:flutter_test/flutter_test.dart';
import 'package:contactqr_flutter/core/utils/crypto_utils.dart';
import 'package:contactqr_flutter/data/models/contact_model.dart';
import 'package:contactqr_flutter/data/models/transfer_session_model.dart';
import 'package:contactqr_flutter/features/transfer/services/local_transfer_client.dart';
import 'package:contactqr_flutter/features/transfer/services/local_transfer_server.dart';

void main() {
  group('Local P2P Transfer Server & Client Tests', () {
    test('transfers contacts dataset over local HTTP server with encryption and checksums', () async {
      const contactsToSend = [
        AppContact(id: 'c1', name: 'Alice Cooper', phone: '+15550001111', initials: 'AC', email: 'alice@test.com'),
        AppContact(id: 'c2', name: 'Bob Dylan', phone: '+15550002222', initials: 'BD'),
      ];

      final sessionId = 'test-session-${DateTime.now().millisecondsSinceEpoch}';
      final sessionToken = CryptoUtils.generateRandomToken(length: 16);
      final encryptionKey = CryptoUtils.generateSessionKey();

      TransferStatus currentStatus = TransferStatus.idle;
      final server = LocalTransferServer(
        contacts: contactsToSend,
        sessionId: sessionId,
        sessionToken: sessionToken,
        encryptionKey: encryptionKey,
        onStatusChanged: (status, _) {
          currentStatus = status;
        },
      );

      final port = await server.start();
      expect(port > 0, true);
      expect(server.isRunning, true);
      expect(currentStatus, TransferStatus.waiting);

      // Setup client session
      final session = TransferSession(
        sessionId: sessionId,
        protocolVersion: 1,
        mode: TransferMode.localNetwork,
        contactCount: contactsToSend.length,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        host: '127.0.0.1',
        port: port,
        token: sessionToken,
        encryptionKey: encryptionKey,
      );

      const client = LocalTransferClient();
      final receivedContacts = await client.fetchContactsFromSender(session);

      expect(receivedContacts.length, 2);
      expect(receivedContacts[0].name, 'Alice Cooper');
      expect(receivedContacts[0].phone, '+15550001111');
      expect(receivedContacts[0].email, 'alice@test.com');
      expect(receivedContacts[1].name, 'Bob Dylan');

      await Future.delayed(const Duration(milliseconds: 200));
      expect(currentStatus, TransferStatus.completed);

      await server.stop();
    });
  });
}
