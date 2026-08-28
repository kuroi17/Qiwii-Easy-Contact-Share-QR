import 'package:flutter_test/flutter_test.dart';
import 'package:contactqr_flutter/core/utils/crypto_utils.dart';

void main() {
  group('CryptoUtils Tests', () {
    test('generates random tokens and session keys', () {
      final token1 = CryptoUtils.generateRandomToken(length: 16);
      final token2 = CryptoUtils.generateRandomToken(length: 16);
      expect(token1.isNotEmpty, true);
      expect(token2.isNotEmpty, true);
      expect(token1, isNot(token2));

      final key = CryptoUtils.generateSessionKey();
      expect(key.length >= 32, true);
    });

    test('computes valid SHA-256 hash', () {
      final hash = CryptoUtils.sha256Hash('contactqr-test-payload');
      expect(hash.length, 64);
      expect(hash, CryptoUtils.sha256Hash('contactqr-test-payload'));
    });

    test('encrypts and decrypts payload round-trip', () {
      const plainText = '{"contacts":[{"name":"Maya Chen","phone":"+14155550198"}]}';
      final key = CryptoUtils.generateSessionKey();

      final cipherText = CryptoUtils.encryptPayload(plainText, key);
      expect(cipherText, isNot(plainText));

      final decrypted = CryptoUtils.decryptPayload(cipherText, key);
      expect(decrypted, plainText);
    });

    test('derives consistent encryption key from 4-digit PIN', () {
      const pin = '4821';
      const salt = 'random-salt-1234';

      final key1 = CryptoUtils.deriveKeyFromPin(pin, salt);
      final key2 = CryptoUtils.deriveKeyFromPin(pin, salt);
      expect(key1, key2);

      const wrongPin = '4822';
      final wrongKey = CryptoUtils.deriveKeyFromPin(wrongPin, salt);
      expect(key1, isNot(wrongKey));
    });

    test('encrypts and decrypts payload using PIN-derived key', () {
      const plainText = '{"name":"Maya Chen","phone":"+14155550198"}';
      const pin = '9182';
      const salt = 'pin-salt-xyz';

      final key = CryptoUtils.deriveKeyFromPin(pin, salt);
      final encrypted = CryptoUtils.encryptPayload(plainText, key);

      // Decrypt with correct PIN
      final decrypted = CryptoUtils.decryptPayload(encrypted, key);
      expect(decrypted, plainText);

      // Decrypt with wrong PIN key fails
      final wrongKey = CryptoUtils.deriveKeyFromPin('0000', salt);
      expect(() => CryptoUtils.decryptPayload(encrypted, wrongKey), throwsA(isA<CryptoException>()));
    });

    test('throws CryptoException when tampered with or wrong key is provided', () {
      const plainText = '{"secret":"confidential"}';
      final key1 = CryptoUtils.generateSessionKey();
      final key2 = CryptoUtils.generateSessionKey();

      final cipherText = CryptoUtils.encryptPayload(plainText, key1);

      // Wrong key
      expect(() => CryptoUtils.decryptPayload(cipherText, key2), throwsA(isA<CryptoException>()));
    });
  });
}
