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

  /// Derives an AES-compatible encryption key from a 4-digit PIN and a salt using iterated HMAC-SHA256
  static String deriveKeyFromPin(String pin, String salt) {
    List<int> current = utf8.encode('$pin:$salt:qiwii_secure_pin_kdf');
    final saltBytes = utf8.encode(salt);
    for (int i = 0; i < 500; i++) {
      final hmac = Hmac(sha256, saltBytes);
      current = hmac.convert(current).bytes;
    }
    return base64UrlEncode(current).replaceAll('=', '');
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

    // Pack binary: IV (16 bytes) + AuthTag (32 bytes) + CipherBytes (N bytes)
    final packed = Uint8List(16 + 32 + cipherBytes.length);
    packed.setRange(0, 16, iv);
    packed.setRange(16, 48, authTag);
    packed.setRange(48, packed.length, cipherBytes);

    return base64UrlEncode(packed).replaceAll('=', '');
  }

  /// Decrypts a payload and verifies its cryptographic HMAC authentication tag.
  /// Supports both ultra-compact binary format and legacy JSON packages.
  static String decryptPayload(String encryptedPackage, String key) {
    if (encryptedPackage.isEmpty) return '';

    try {
      final keyBytes = utf8.encode(key);
      String normalized = encryptedPackage;
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }

      Uint8List rawBytes;
      try {
        rawBytes = Uint8List.fromList(base64Url.decode(normalized));
      } catch (_) {
        rawBytes = Uint8List.fromList(base64.decode(normalized.replaceAll('-', '+').replaceAll('_', '/')));
      }

      // Check if it's the ultra-compact binary format (length >= 48 bytes: 16 IV + 32 Tag)
      if (rawBytes.length >= 48 && rawBytes[0] != 0x7B) { // 0x7B is '{' in ASCII
        final iv = rawBytes.sublist(0, 16);
        final expectedTag = rawBytes.sublist(16, 48);
        final cipherBytes = rawBytes.sublist(48);

        // Verify HMAC authentication tag
        final calculatedTag = Hmac(sha256, keyBytes).convert([...iv, ...cipherBytes]).bytes;
        if (!_constantTimeEquals(expectedTag, calculatedTag)) {
          throw const CryptoException('Payload authentication failed. Invalid PIN or data tampered with.');
        }

        return _decryptCipherStream(cipherBytes, iv, keyBytes);
      }

      // Fallback: Legacy JSON format
      final jsonMap = jsonDecode(utf8.decode(rawBytes)) as Map<String, dynamic>;
      final iv = base64Url.decode(jsonMap['iv'] as String);
      final cipherBytes = base64Url.decode(jsonMap['ct'] as String);
      final expectedTag = base64Url.decode(jsonMap['tag'] as String);

      final calculatedTag = Hmac(sha256, keyBytes).convert([...iv, ...cipherBytes]).bytes;
      if (!_constantTimeEquals(expectedTag, calculatedTag)) {
        throw const CryptoException('Payload authentication failed. Invalid PIN or data tampered with.');
      }

      return _decryptCipherStream(cipherBytes, iv, keyBytes);
    } catch (e) {
      if (e is CryptoException) rethrow;
      throw const CryptoException('Corrupted or invalid encrypted payload.');
    }
  }

  static String _decryptCipherStream(List<int> cipherBytes, List<int> iv, List<int> keyBytes) {
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
