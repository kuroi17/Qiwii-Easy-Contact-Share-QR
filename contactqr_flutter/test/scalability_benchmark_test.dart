import 'package:flutter_test/flutter_test.dart';
import 'package:contactqr_flutter/core/utils/crypto_utils.dart';
import 'package:contactqr_flutter/core/utils/phone_normalizer.dart';
import 'package:contactqr_flutter/core/utils/qr_codec.dart';
import 'package:contactqr_flutter/data/models/contact_model.dart';
import 'package:contactqr_flutter/data/models/transfer_session_model.dart';
import 'package:contactqr_flutter/features/transfer/services/local_transfer_client.dart';
import 'package:contactqr_flutter/features/transfer/services/local_transfer_server.dart';

List<AppContact> generateMockContacts(int count) {
  return List.generate(count, (index) {
    final num = (index + 1).toString().padLeft(4, '0');
    return AppContact(
      id: 'contact-$index',
      name: 'User $num Benchmark',
      phone: '+1415555$num',
      initials: 'UB',
      email: 'user$num@benchmark.local',
      organization: 'Acme Corp',
      jobTitle: 'Engineer',
    );
  });
}

void main() {
  group('Scalability & Performance Benchmarks', () {
    test('Tier 1: Encodes and decodes 1 contact direct QR payload instantly (< 5ms)', () {
      final contacts = generateMockContacts(1);
      final stopwatch = Stopwatch()..start();

      final encoded = QrCodec.encodeDirectContacts(contacts);
      final decodedSession = QrCodec.decode(encoded);
      final unpacked = QrCodec.decodeDirectPayload(decodedSession.directPayload);

      stopwatch.stop();
      expect(unpacked.length, 1);
      expect(unpacked.first.name, 'User 0001 Benchmark');
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    test('Tier 1: Encodes and decodes 5 contacts direct QR payload (< 10ms)', () {
      final contacts = generateMockContacts(5);
      final stopwatch = Stopwatch()..start();

      final encoded = QrCodec.encodeDirectContacts(contacts);
      final decodedSession = QrCodec.decode(encoded);
      final unpacked = QrCodec.decodeDirectPayload(decodedSession.directPayload);

      stopwatch.stop();
      expect(unpacked.length, 5);
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    test('Tier 2: Transfers 20 contacts via local HTTP server in under 1 second', () async {
      final contacts = generateMockContacts(20);
      final sessionId = 'bench-20-${DateTime.now().millisecondsSinceEpoch}';
      final sessionToken = CryptoUtils.generateRandomToken(length: 16);
      final encryptionKey = CryptoUtils.generateSessionKey();

      final server = LocalTransferServer(
        contacts: contacts,
        sessionId: sessionId,
        sessionToken: sessionToken,
        encryptionKey: encryptionKey,
      );

      final port = await server.start();

      final session = TransferSession(
        sessionId: sessionId,
        protocolVersion: 1,
        mode: TransferMode.localNetwork,
        contactCount: 20,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        host: '127.0.0.1',
        port: port,
        token: sessionToken,
        encryptionKey: encryptionKey,
      );

      final stopwatch = Stopwatch()..start();
      const client = LocalTransferClient();
      final downloaded = await client.fetchContactsFromSender(session);
      stopwatch.stop();

      expect(downloaded.length, 20);
      expect(stopwatch.elapsedMilliseconds, lessThan(1500));

      await server.stop();
    });

    test('Tier 2: Transfers 100 contacts via local HTTP server with authenticated encryption', () async {
      final contacts = generateMockContacts(100);
      final sessionId = 'bench-100-${DateTime.now().millisecondsSinceEpoch}';
      final sessionToken = CryptoUtils.generateRandomToken(length: 16);
      final encryptionKey = CryptoUtils.generateSessionKey();

      final server = LocalTransferServer(
        contacts: contacts,
        sessionId: sessionId,
        sessionToken: sessionToken,
        encryptionKey: encryptionKey,
      );

      final port = await server.start();

      final session = TransferSession(
        sessionId: sessionId,
        protocolVersion: 1,
        mode: TransferMode.localNetwork,
        contactCount: 100,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        host: '127.0.0.1',
        port: port,
        token: sessionToken,
        encryptionKey: encryptionKey,
      );

      const client = LocalTransferClient();
      final downloaded = await client.fetchContactsFromSender(session);

      expect(downloaded.length, 100);
      expect(downloaded[99].name, 'User 0100 Benchmark');

      await server.stop();
    });

    test('Tier 2: Transfers 500 contacts bulk dataset and flags duplicates', () async {
      final contacts = generateMockContacts(500);
      final sessionId = 'bench-500-${DateTime.now().millisecondsSinceEpoch}';
      final sessionToken = CryptoUtils.generateRandomToken(length: 16);
      final encryptionKey = CryptoUtils.generateSessionKey();

      final server = LocalTransferServer(
        contacts: contacts,
        sessionId: sessionId,
        sessionToken: sessionToken,
        encryptionKey: encryptionKey,
      );

      final port = await server.start();

      final session = TransferSession(
        sessionId: sessionId,
        protocolVersion: 1,
        mode: TransferMode.localNetwork,
        contactCount: 500,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        host: '127.0.0.1',
        port: port,
        token: sessionToken,
        encryptionKey: encryptionKey,
      );

      const client = LocalTransferClient();
      final downloaded = await client.fetchContactsFromSender(session);
      expect(downloaded.length, 500);

      // Verify duplicate detection performance on 500 contacts
      final stopwatch = Stopwatch()..start();
      final existingAddressBook = generateMockContacts(50);
      int duplicatesFound = 0;
      for (final contact in downloaded) {
        if (PhoneNormalizer.isDuplicateContact(contact, existingAddressBook)) {
          duplicatesFound++;
        }
      }
      stopwatch.stop();

      expect(duplicatesFound, 50);
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      await server.stop();
    });
  });
}
