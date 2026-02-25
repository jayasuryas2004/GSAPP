import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:mobile_app/services/local_storage_service.dart';

/// Exception for UUID operations
class UuidException implements Exception {
  final String message;
  UuidException(this.message);

  @override
  String toString() => message;
}

/// Service for managing device-specific UUIDs
/// Generates unique identifier per device and stores locally
/// Ensures consistent UUID across app sessions
class UuidService {
  static const String _uuidVersion = '1.0';
  late final LocalStorageService _storage;

  UuidService(this._storage);

  /// Get or create device UUID
  /// First call generates new UUID, subsequent calls return cached value
  Future<String> getOrCreateUuid() async {
    try {
      // Check if UUID already exists in local storage
      final existingUuid = _storage.getOrCreateUuid();
      if (existingUuid.isNotEmpty) {
        print('[UUID] ✅ UUID found in cache: ${existingUuid.substring(0, 8)}...');
        return existingUuid;
      }

      // Generate new device-specific UUID
      final newUuid = _generateDeviceUuid();
      print('[UUID] 🆕 Generated new UUID: ${newUuid.substring(0, 8)}...');

      // Save to local storage
      await _storage.saveUuid(newUuid);
      print('[UUID] 💾 UUID saved to storage');

      return newUuid;
    } catch (e) {
      final error = 'Error getting/creating UUID: $e';
      print('[UUID] ❌ $error');
      throw UuidException(error);
    }
  }

  /// Generate deterministic device UUID
  /// Creates consistent ID based on device characteristics
  String _generateDeviceUuid() {
    final timestamp = DateTime.now().toIso8601String();
    final random = _getRandomComponent();
    final deviceInfo = _getDeviceComponent();

    // Combine components for deterministic but unique UUID
    final combined = '$deviceInfo-$timestamp-$random-$_uuidVersion';
    final hash = sha256.convert(utf8.encode(combined));

    // Format as UUID-like string: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
    final hashStr = hash.toString();
    return '${hashStr.substring(0, 8)}'
        '-${hashStr.substring(8, 12)}'
        '-4${hashStr.substring(13, 16)}'
        '-a${hashStr.substring(17, 20)}'
        '-${hashStr.substring(20, 32)}';
  }

  /// Get device-specific component for UUID generation
  /// Uses platform info for deterministic generation
  String _getDeviceComponent() {
    try {
      // Use OS and platform info as base
      final platform = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
              ? 'ios'
              : Platform.isWindows
                  ? 'windows'
                  : Platform.isLinux
                      ? 'linux'
                      : 'unknown';

      final operatingSystem = Platform.operatingSystem;
      final version = Platform.operatingSystemVersion;

      return '$platform-$operatingSystem-$version';
    } catch (e) {
      print('[UUID] ⚠️ Could not get device info: $e');
      return 'unknown-device';
    }
  }

  /// Get random component for uniqueness
  /// Uses current time + random seed
  String _getRandomComponent() {
    final random = _generateRandomString(16);
    return random;
  }

  /// Generate random alphanumeric string
  String _generateRandomString(int length) {
    const chars = 'abcdef0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;

    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      final index = (random + i) % chars.length;
      buffer.write(chars[index]);
    }
    return buffer.toString();
  }

  /// Validate UUID format
  static bool isValidUuid(String uuid) {
    // Check basic UUID format: 8-4-4-4-12 hex digits
    final pattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return pattern.hasMatch(uuid);
  }

  /// Get UUID formatted details (for debugging)
  Map<String, String> getUuidDetails(String uuid) {
    final parts = uuid.split('-');
    return {
      'full': uuid,
      'time_part': parts.isNotEmpty ? parts[0] : '',
      'mid_part_1': parts.length > 1 ? parts[1] : '',
      'mid_part_2': parts.length > 2 ? parts[2] : '',
      'clock_seq': parts.length > 3 ? parts[3] : '',
      'node': parts.length > 4 ? parts[4] : '',
      'short': '${uuid.substring(0, 8)}...${uuid.substring(uuid.length - 8)}',
    };
  }
}
