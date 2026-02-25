import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/models/models.dart';

/// Exception for local storage operations
class LocalStorageException implements Exception {
  final String message;
  LocalStorageException(this.message);

  @override
  String toString() => message;
}

/// Service for managing local device storage
/// Handles:
/// - User profile persistence
/// - UUID generation and storage
/// - Bookmarked schemes list
/// - Onboarding status
/// - App preferences
class LocalStorageService {
  late SharedPreferences _prefs;

  // Singleton instance
  static LocalStorageService? _instance;

  // Storage Keys
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyUserProfile = 'user_profile';
  static const String _keyUserUuid = 'user_uuid';
  static const String _keySavedSchemes = 'saved_schemes'; // List of scheme IDs
  static const String _keyLastSyncTime = 'last_sync_time';
  static const String _keyAppVersion = 'app_version';
  static const String _keyThemeMode = 'theme_mode'; // 'light', 'dark', 'system'

  /// Private constructor
  LocalStorageService._();

  /// Get singleton instance
  static LocalStorageService getInstance() {
    _instance ??= LocalStorageService._();
    return _instance!;
  }

  /// Initialize local storage
  Future<void> initialize() async {
    try {
      print('[DEBUG] 🔄 Initializing local storage...');
      _prefs = await SharedPreferences.getInstance();
      print('[INFO] ✅ Local storage initialized');
    } catch (e) {
      final error = 'Failed to initialize local storage: $e';
      print('[ERROR] $error');
      throw LocalStorageException(error);
    }
  }

  // ========== ONBOARDING STATUS ==========

  /// Check if user has completed onboarding
  bool hasCompletedOnboarding() {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  /// Mark onboarding as complete
  Future<void> setOnboardingComplete(bool complete) async {
    try {
      await _prefs.setBool(_keyOnboardingComplete, complete);
      print('[DEBUG] ✅ Onboarding status updated: $complete');
    } catch (e) {
      print('[ERROR] ❌ Error updating onboarding status: $e');
      rethrow;
    }
  }

  // ========== USER PROFILE ==========

  /// Get saved user profile
  UserProfile? getUserProfile() {
    try {
      final jsonString = _prefs.getString(_keyUserProfile);
      if (jsonString == null) {
        print('[DEBUG] ℹ️ No user profile found in local storage');
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final profile = UserProfile.fromJson(json);
      print('[DEBUG] ✅ User profile loaded from storage');
      return profile;
    } catch (e) {
      print('[ERROR] ❌ Error loading user profile: $e');
      rethrow;
    }
  }

  /// Save user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final json = profile.toJson();
      final jsonString = jsonEncode(json);
      await _prefs.setString(_keyUserProfile, jsonString);
      print('[INFO] ✅ User profile saved: ${profile.gender}, ${profile.age}, ${profile.state}, ${profile.occupation}');
    } catch (e) {
      print('[ERROR] ❌ Error saving user profile: $e');
      rethrow;
    }
  }

  /// Update specific profile field
  Future<void> updateProfileField({
    required String fieldName,
    required dynamic value,
  }) async {
    try {
      final profile = getUserProfile();
      if (profile == null) {
        throw LocalStorageException('No profile found to update');
      }

      final updatedProfile = _updateProfileField(profile, fieldName, value);
      await saveUserProfile(updatedProfile);
      print('[DEBUG] ✅ Profile field updated: $fieldName = $value');
    } catch (e) {
      print('[ERROR] ❌ Error updating profile field: $e');
      rethrow;
    }
  }

  /// Helper method to update profile fields
  UserProfile _updateProfileField(
    UserProfile profile,
    String fieldName,
    dynamic value,
  ) {
    switch (fieldName) {
      case 'gender':
        return profile.copyWith(gender: value as String?);
      case 'age':
        return profile.copyWith(age: value as int?);
      case 'state':
        return profile.copyWith(state: value as String?);
      case 'occupation':
        return profile.copyWith(occupation: value as String?);
      default:
        throw LocalStorageException('Unknown profile field: $fieldName');
    }
  }

  /// Clear user profile (logout equivalent)
  Future<void> clearUserProfile() async {
    try {
      await _prefs.remove(_keyUserProfile);
      await _prefs.setBool(_keyOnboardingComplete, false);
      print('[INFO] ✅ User profile cleared');
    } catch (e) {
      print('[ERROR] ❌ Error clearing user profile: $e');
      rethrow;
    }
  }

  // ========== UUID MANAGEMENT ==========

  /// Get or create device UUID
  String getOrCreateUuid() {
    try {
      final existingUuid = _prefs.getString(_keyUserUuid);

      if (existingUuid != null && existingUuid.isNotEmpty) {
        print('[DEBUG] ✅ UUID found in storage: ${existingUuid.substring(0, 8)}...');
        return existingUuid;
      }

      // UUID not found, will be created during profile setup
      print('[DEBUG] ℹ️ No UUID in storage yet');
      return '';
    } catch (e) {
      print('[ERROR] ❌ Error getting UUID: $e');
      rethrow;
    }
  }

  /// Save UUID after generation
  Future<void> saveUuid(String uuid) async {
    try {
      await _prefs.setString(_keyUserUuid, uuid);
      print('[INFO] ✅ UUID saved: ${uuid.substring(0, 8)}...');
    } catch (e) {
      print('[ERROR] ❌ Error saving UUID: $e');
      rethrow;
    }
  }

  // ========== SAVED SCHEMES ==========

  /// Get list of bookmarked scheme IDs
  List<String> getSavedSchemeIds() {
    try {
      final jsonString = _prefs.getString(_keySavedSchemes);
      if (jsonString == null) {
        print('[DEBUG] ℹ️ No saved schemes found');
        return [];
      }

      final ids = List<String>.from(jsonDecode(jsonString) as List);
      print('[DEBUG] ✅ Loaded ${ids.length} saved schemes');
      return ids;
    } catch (e) {
      print('[ERROR] ❌ Error loading saved schemes: $e');
      return [];
    }
  }

  /// Add scheme to saved list
  Future<void> addSavedScheme(String schemeId) async {
    try {
      final savedIds = getSavedSchemeIds();

      if (savedIds.contains(schemeId)) {
        print('[INFO] ⚠️ Scheme already saved');
        return;
      }

      savedIds.add(schemeId);
      await _saveSchemesToStorage(savedIds);
      print('[DEBUG] ✅ Scheme added to saved list: $schemeId');
    } catch (e) {
      print('[ERROR] ❌ Error adding saved scheme: $e');
      rethrow;
    }
  }

  /// Remove scheme from saved list
  Future<void> removeSavedScheme(String schemeId) async {
    try {
      final savedIds = getSavedSchemeIds();
      savedIds.remove(schemeId);
      await _saveSchemesToStorage(savedIds);
      print('[DEBUG] ✅ Scheme removed from saved list: $schemeId');
    } catch (e) {
      print('[ERROR] ❌ Error removing saved scheme: $e');
      rethrow;
    }
  }

  /// Check if scheme is saved
  bool isSchemeSaved(String schemeId) {
    return getSavedSchemeIds().contains(schemeId);
  }

  /// Clear all saved schemes
  Future<void> clearSavedSchemes() async {
    try {
      await _prefs.remove(_keySavedSchemes);
      print('[INFO] ✅ All saved schemes cleared');
    } catch (e) {
      print('[ERROR] ❌ Error clearing saved schemes: $e');
      rethrow;
    }
  }

  /// Helper method to save scheme IDs
  Future<void> _saveSchemesToStorage(List<String> schemeIds) async {
    final jsonString = jsonEncode(schemeIds);
    await _prefs.setString(_keySavedSchemes, jsonString);
  }

  // ========== SYNC & METADATA ==========

  /// Get last sync time with server
  DateTime? getLastSyncTime() {
    try {
      final timeString = _prefs.getString(_keyLastSyncTime);
      if (timeString == null) return null;
      return DateTime.parse(timeString);
    } catch (e) {
      print('[WARNING] ⚠️ Error parsing last sync time: $e');
      return null;
    }
  }

  /// Update last sync time
  Future<void> updateLastSyncTime() async {
    try {
      final now = DateTime.now().toIso8601String();
      await _prefs.setString(_keyLastSyncTime, now);
      print('[DEBUG] ✅ Sync time updated');
    } catch (e) {
      print('[ERROR] ❌ Error updating sync time: $e');
    }
  }

  /// Get stored app version
  String? getAppVersion() {
    return _prefs.getString(_keyAppVersion);
  }

  /// Update app version
  Future<void> setAppVersion(String version) async {
    try {
      await _prefs.setString(_keyAppVersion, version);
      print('[DEBUG] ✅ App version updated to: $version');
    } catch (e) {
      print('[WARNING] ⚠️ Error updating app version: $e');
    }
  }

  // ========== PREFERENCES ==========

  /// Get theme mode preference
  String getThemeMode() {
    return _prefs.getString(_keyThemeMode) ?? 'system';
  }

  /// Save theme mode preference
  Future<void> setThemeMode(String mode) async {
    try {
      await _prefs.setString(_keyThemeMode, mode);
      print('[DEBUG] ✅ Theme mode updated to: $mode');
    } catch (e) {
      print('[ERROR] ❌ Error updating theme mode: $e');
      rethrow;
    }
  }

  // ========== CACHE MANAGEMENT ==========

  /// Clear all stored data (factory reset)
  Future<void> clearAll() async {
    try {
      await _prefs.clear();
      print('[WARNING] ⚠️ All local storage cleared');
    } catch (e) {
      print('[ERROR] ❌ Error clearing local storage: $e');
      rethrow;
    }
  }

  /// Get storage size estimate (keys count)
  int getStorageSize() {
    return _prefs.getKeys().length;
  }
}
