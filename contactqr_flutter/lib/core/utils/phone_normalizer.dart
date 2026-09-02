import '../../data/models/contact_model.dart';

class PhoneNormalizer {
  /// Strips whitespace, dashes, parentheses, dots, and formatting characters.
  /// Keeps a leading '+' if present.
  static String normalize(String rawPhone) {
    if (rawPhone.trim().isEmpty) return '';
    final trimmed = rawPhone.trim();
    final hasLeadingPlus = trimmed.startsWith('+');
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return '';
    return hasLeadingPlus ? '+$digitsOnly' : digitsOnly;
  }

  /// Returns the core significant digits (last 9 to 10 digits) for fuzzy matching
  /// across local dialing formats vs international country codes.
  static String extractCoreDigits(String phone, {int minDigits = 10}) {
    final normalized = normalize(phone).replaceAll('+', '');
    if (normalized.length <= minDigits) return normalized;
    return normalized.substring(normalized.length - minDigits);
  }

  /// Checks whether two phone numbers represent the same recipient.
  static bool areNumbersEqual(String phoneA, String phoneB) {
    final normA = normalize(phoneA);
    final normB = normalize(phoneB);
    if (normA.isEmpty || normB.isEmpty) return false;
    if (normA == normB) return true;

    final digitsOnlyA = normA.replaceAll('+', '');
    final digitsOnlyB = normB.replaceAll('+', '');

    // Compare 10-digit national significant number (e.g. 9171234567)
    if (digitsOnlyA.length >= 10 && digitsOnlyB.length >= 10) {
      final coreA = digitsOnlyA.substring(digitsOnlyA.length - 10);
      final coreB = digitsOnlyB.substring(digitsOnlyB.length - 10);
      return coreA == coreB;
    }

    // Compare 9-digit format if available
    if (digitsOnlyA.length >= 9 && digitsOnlyB.length >= 9) {
      final coreA = digitsOnlyA.substring(digitsOnlyA.length - 9);
      final coreB = digitsOnlyB.substring(digitsOnlyB.length - 9);
      return coreA == coreB;
    }

    return digitsOnlyA == digitsOnlyB;
  }

  /// Checks whether two emails represent the same email address.
  static bool areEmailsEqual(String? emailA, String? emailB) {
    if (emailA == null || emailB == null) return false;
    final cleanA = emailA.trim().toLowerCase();
    final cleanB = emailB.trim().toLowerCase();
    if (cleanA.isEmpty || cleanB.isEmpty) return false;
    return cleanA == cleanB;
  }

  /// Checks if a contact already exists within a target contact list.
  static bool isDuplicateContact(AppContact candidate, List<AppContact> targetList) {
    for (final existing in targetList) {
      // 1. Phone number match
      if (areNumbersEqual(candidate.phone, existing.phone)) {
        return true;
      }
      // 2. Email match
      if (areEmailsEqual(candidate.email, existing.email)) {
        return true;
      }
      // 3. Exact normalized name match
      if (candidate.name.trim().isNotEmpty &&
          existing.name.trim().isNotEmpty &&
          candidate.name.trim().toLowerCase() == existing.name.trim().toLowerCase()) {
        return true;
      }
    }
    return false;
  }
}
