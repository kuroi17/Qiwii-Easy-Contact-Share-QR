import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkHelper {
  /// Resolves the device's local network IPv4 address on Wi-Fi or Hotspot.
  static Future<String> getLocalIpAddress() async {
    if (kIsWeb) return '127.0.0.1';

    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );

      // Prioritize Wi-Fi / hotspot / wlan interfaces
      for (final interface in interfaces) {
        final name = interface.name.toLowerCase();
        if (name.contains('wlan') ||
            name.contains('wi-fi') ||
            name.contains('wifi') ||
            name.contains('ap') ||
            name.contains('hotspot')) {
          for (final addr in interface.addresses) {
            if (!addr.isLoopback && _isPrivateIp(addr.address)) {
              return addr.address;
            }
          }
        }
      }

      // Secondary check: Any private IPv4 address
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback && _isPrivateIp(addr.address)) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      debugPrint('Error retrieving network interfaces: $e');
    }

    return '127.0.0.1';
  }

  static bool _isPrivateIp(String ip) {
    // 192.168.x.x, 10.x.x.x, 172.16-31.x.x
    if (ip.startsWith('192.168.') || ip.startsWith('10.')) return true;
    if (ip.startsWith('172.')) {
      final parts = ip.split('.');
      if (parts.length > 1) {
        final secondOctet = int.tryParse(parts[1]);
        if (secondOctet != null && secondOctet >= 16 && secondOctet <= 31) {
          return true;
        }
      }
    }
    return false;
  }
}
