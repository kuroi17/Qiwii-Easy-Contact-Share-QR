import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/utils/crypto_utils.dart';
import '../../../data/models/contact_model.dart';
import '../../../data/models/transfer_session_model.dart';

typedef TransferServerCallback = void Function(TransferStatus status, String? message);

class LocalTransferServer {
  LocalTransferServer({
    required List<AppContact> contacts,
    required this.sessionId,
    required this.sessionToken,
    required this.encryptionKey,
    this.onStatusChanged,
  }) : _contacts = List<AppContact>.from(contacts);

  List<AppContact> _contacts;
  final String sessionId;
  final String sessionToken;
  final String encryptionKey;
  final TransferServerCallback? onStatusChanged;

  HttpServer? _server;
  bool _isDisposed = false;

  int get port => _server?.port ?? 0;
  bool get isRunning => _server != null;

  /// Starts the local HTTP transfer server on an ephemeral random port.
  Future<int> start() async {
    if (kIsWeb) return 8080;

    try {
      _server = await HttpServer.bind(
        InternetAddress.anyIPv4,
        0, // Bind to random available port
      );

      _server!.listen(
        _handleRequest,
        onError: (err) {
          debugPrint('Transfer server error: $err');
          onStatusChanged?.call(TransferStatus.failed, err.toString());
        },
      );

      onStatusChanged?.call(TransferStatus.waiting, 'Server ready on port $port');
      return _server!.port;
    } catch (e) {
      debugPrint('Failed to bind transfer server: $e');
      onStatusChanged?.call(TransferStatus.failed, e.toString());
      rethrow;
    }
  }

  void _handleRequest(HttpRequest request) async {
    if (_isDisposed) {
      request.response.statusCode = HttpStatus.serviceUnavailable;
      await request.response.close();
      return;
    }

    final path = request.uri.path;
    final token = request.uri.queryParameters['token'];

    // CORS Headers for local P2P communication
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    // Health check endpoint
    if (path == '/health') {
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'app': 'contactqr', 'status': 'ok'}));
      await request.response.close();
      return;
    }

    // Validate security token for all transfer routes
    if (token == null || token != sessionToken) {
      request.response.statusCode = HttpStatus.unauthorized;
      request.response.write(jsonEncode({'error': 'Unauthorized: Invalid session token'}));
      await request.response.close();
      return;
    }

    if (path == '/transfer' && request.method == 'GET') {
      onStatusChanged?.call(TransferStatus.transferring, 'Sending contacts to receiver...');

      try {
        // Serialize and encrypt contacts dataset
        final contactsJson = jsonEncode(_contacts.map((c) => c.toJson()).toList());
        final encryptedPayload = CryptoUtils.encryptPayload(contactsJson, encryptionKey);
        final checksum = CryptoUtils.sha256Hash(encryptedPayload);

        final responseData = {
          'sessionId': sessionId,
          'count': _contacts.length,
          'payload': encryptedPayload,
          'checksum': checksum,
        };

        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(responseData));
        await request.response.close();

        onStatusChanged?.call(TransferStatus.transferring, 'Contacts delivered, waiting for ack...');
      } catch (e) {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.write(jsonEncode({'error': e.toString()}));
        await request.response.close();
        onStatusChanged?.call(TransferStatus.failed, e.toString());
      }
      return;
    }

    if (path == '/ack' && request.method == 'POST') {
      request.response.statusCode = HttpStatus.ok;
      request.response.write(jsonEncode({'status': 'acknowledged'}));
      await request.response.close();

      onStatusChanged?.call(TransferStatus.completed, 'Transfer completed successfully!');

      // Secure ephemeral wipe and close server gracefully after 2 seconds
      Future.delayed(const Duration(seconds: 2), stop);
      return;
    }

    if (path == '/cancel' && request.method == 'POST') {
      request.response.statusCode = HttpStatus.ok;
      request.response.write(jsonEncode({'status': 'cancelled'}));
      await request.response.close();

      onStatusChanged?.call(TransferStatus.cancelled, 'Receiver cancelled the transfer.');
      stop();
      return;
    }

    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
  }

  /// Securely stops the HTTP server, clears port bindings, and wipes memory.
  Future<void> stop() async {
    if (_isDisposed) return;
    _isDisposed = true;

    // Ephemeral wipe of in-memory contact records
    _contacts = [];

    try {
      await _server?.close(force: true);
      _server = null;
    } catch (e) {
      debugPrint('Error stopping transfer server: $e');
    }
  }
}
