import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/utils/crypto_utils.dart';
import '../../../data/models/contact_model.dart';
import '../../../data/models/transfer_session_model.dart';

class NetworkTransferException implements Exception {
  final String message;
  final bool isNetworkUnreachable;
  const NetworkTransferException(this.message, {this.isNetworkUnreachable = false});
  @override
  String toString() => message;
}

class LocalTransferClient {
  const LocalTransferClient();

  /// Connects to the sender's local HTTP server, downloads and decrypts contacts.
  Future<List<AppContact>> fetchContactsFromSender(TransferSession session) async {
    if (session.host == null || session.port == null || session.token == null || session.encryptionKey == null) {
      throw const NetworkTransferException('Incomplete session connection parameters.');
    }

    final url = Uri.parse('http://${session.host}:${session.port}/transfer?token=${session.token}');

    try {
      final response = await http.get(url).timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          throw const NetworkTransferException(
            'Connection timed out. Could not reach sender device. Check if both devices are on the same Wi-Fi or Hotspot.',
            isNetworkUnreachable: true,
          );
        },
      );

      if (response.statusCode == HttpStatus.unauthorized) {
        throw const NetworkTransferException('Unauthorized session. Please ask the sender for a new QR code.');
      }

      if (response.statusCode != HttpStatus.ok) {
        throw NetworkTransferException('Transfer server returned error code ${response.statusCode}.');
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final encryptedPayload = responseData['payload'] as String?;
      final checksum = responseData['checksum'] as String?;

      if (encryptedPayload == null || checksum == null) {
        throw const NetworkTransferException('Invalid transfer response: missing payload or checksum.');
      }

      // Verify SHA-256 payload integrity checksum
      final actualChecksum = CryptoUtils.sha256Hash(encryptedPayload);
      if (actualChecksum != checksum) {
        throw const NetworkTransferException('Transfer integrity check failed: payload checksum mismatch.');
      }

      // Decrypt contacts payload using session key
      final decryptedJson = CryptoUtils.decryptPayload(encryptedPayload, session.encryptionKey!);
      final List<dynamic> contactsRaw = jsonDecode(decryptedJson) as List<dynamic>;

      final List<AppContact> contacts = contactsRaw.map((item) {
        return AppContact.fromJson(item as Map<String, dynamic>);
      }).toList();

      // Send acknowledgment back to sender
      _sendAcknowledgment(session);

      return contacts;
    } on SocketException {
      throw const NetworkTransferException(
        'Could not connect to the sender’s device. Ensure both phones are on the same Wi-Fi or Personal Hotspot.',
        isNetworkUnreachable: true,
      );
    } catch (e) {
      if (e is NetworkTransferException) rethrow;
      debugPrint('Error downloading contacts from sender: $e');
      throw NetworkTransferException('Transfer error: $e');
    }
  }

  Future<void> _sendAcknowledgment(TransferSession session) async {
    try {
      final ackUrl = Uri.parse('http://${session.host}:${session.port}/ack?token=${session.token}');
      await http.post(ackUrl).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Warning: Failed to send transfer acknowledgment to sender: $e');
    }
  }

  /// Sends cancellation notice to sender if receiver aborts.
  Future<void> sendCancellation(TransferSession session) async {
    try {
      if (session.host != null && session.port != null && session.token != null) {
        final cancelUrl = Uri.parse('http://${session.host}:${session.port}/cancel?token=${session.token}');
        await http.post(cancelUrl).timeout(const Duration(seconds: 3));
      }
    } catch (_) {}
  }
}
