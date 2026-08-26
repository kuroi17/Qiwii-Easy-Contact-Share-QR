import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class CryptoException implements Exception {
  final String message;
  const CryptoException(this.message);
  @override
  String toString() => message;
}

class CryptoUtils {
  static final Random _secureRandom = Random.secure();

  /// Generates a cryptographically secure random token string.
  static String generateRandomToken({int length = 32}) {
    final values = List<int>.generate(length, (_) => _secureRandom.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  /// Generates a random 256-bit session encryption key.
  static String generateSessionKey() {
    return generateRandomToken(length: 32);
  }

  /// Calculates the SHA-256 hash of a string.
  static String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  /// Encrypts a plaintext string with an ephemeral session key.
  /// Generates a random 16-byte IV, computes a stream cipher, and appends a SHA-256 HMAC tag.
  static String encryptPayload(String plainText, String key) {
    if (plainText.isEmpty) return '';

    final plainBytes = utf8.encode(plainText);
    final keyBytes = utf8.encode(key);

    // Generate 16-byte random IV
    final iv = List<int>.generate(16, (_) => _secureRandom.nextInt(256));

    // Derive key stream using HMAC-SHA256(key, iv + counter)
    final cipherBytes = Uint8List(plainBytes.length);
    int blockCounter = 0;
    int keyStreamOffset = 0;
    List<int> currentKeyStream = [];

    for (int i = 0; i < plainBytes.length; i++) {
      if (keyStreamOffset >= currentKeyStream.length) {
        final counterBytes = [
          (blockCounter >> 24) & 0xFF,
          (blockCounter >> 16) & 0xFF,
          (blockCounter >> 8) & 0xFF,
          blockCounter & 0xFF,
        ];
        final hmac = Hmac(sha256, keyBytes);
        currentKeyStream = hmac.convert([...iv, ...counterBytes]).bytes;
        blockCounter++;
        keyStreamOffset = 0;
      }
      cipherBytes[i] = plainBytes[i] ^ currentKeyStream[keyStreamOffset++];
    }

    // Compute HMAC authentication tag over IV + Ciphertext
    final authTag = Hmac(sha256, keyBytes).convert([...iv, ...cipherBytes]).bytes;

    final result = {
      'iv': base64UrlEncode(iv),
      'ct': base64UrlEncode(cipherBytes),
      'tag': base64UrlEncode(authTag),
    };

    return base64UrlEncode(utf8.encode(jsonEncode(result)));
  }

  /// Decrypts a payload and verifies its cryptographic HMAC authentication tag.
  static String decryptPayload(String encryptedPackage, String key) {
    if (encryptedPackage.isEmpty) return '';

    try {
      final jsonBytes = base64Url.decode(encryptedPackage);
      final jsonMap = jsonDecode(utf8.decode(jsonBytes)) as Map<String, dynamic>;

      final iv = base64Url.decode(jsonMap['iv'] as String);
      final cipherBytes = base64Url.decode(jsonMap['ct'] as String);
      final expectedTag = base64Url.decode(jsonMap['tag'] as String);
      final keyBytes = utf8.encode(key);

      // Verify HMAC authentication tag
      final calculatedTag = Hmac(sha256, keyBytes).convert([...iv, ...cipherBytes]).bytes;
      if (!_constantTimeEquals(expectedTag, calculatedTag)) {
        throw const CryptoException('Payload authentication failed. Data may have been tampered with.');
      }

      // Decrypt cipher stream
      final plainBytes = Uint8List(cipherBytes.length);
      int blockCounter = 0;
      int keyStreamOffset = 0;
      List<int> currentKeyStream = [];

      for (int i = 0; i < cipherBytes.length; i++) {
        if (keyStreamOffset >= currentKeyStream.length) {
          final counterBytes = [
            (blockCounter >> 24) & 0xFF,
            (blockCounter >> 16) & 0xFF,
            (blockCounter >> 8) & 0xFF,
            blockCounter & 0xFF,
          ];
          final hmac = Hmac(sha256, keyBytes);
          currentKeyStream = hmac.convert([...iv, ...counterBytes]).bytes;
          blockCounter++;
          keyStreamOffset = 0;
        }
        plainBytes[i] = cipherBytes[i] ^ currentKeyStream[keyStreamOffset++];
      }

      return utf8.decode(plainBytes);
    } catch (e) {
      if (e is CryptoException) rethrow;
      throw const CryptoException('Corrupted or invalid encrypted payload.');
    }
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}
