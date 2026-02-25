import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_app/config/config.dart';
import 'package:mobile_app/models/models.dart';

/// Exception for Supabase operations
class SupabaseException implements Exception {
  final String message;
  SupabaseException(this.message);

  @override
  String toString() => message;
}

/// Service for interacting with Supabase database
/// Handles:
/// - Fetching schemes
/// - Saving user profiles
/// - Bookmarking schemes
/// - Analytics tracking
class SupabaseService {
  late final SupabaseClient _supabase;

  SupabaseService() {
    _supabase = Supabase.instance.client;
  }

  // ========== LOGGING ==========
  void _log(String level, String message) {
    print('[$level] $message');
  }

  // ========== INITIALIZATION ==========

  /// Initialize Supabase connection
  /// Call this during app startup
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      print('[INFO] ✅ Supabase initialized successfully');
    } catch (e) {
      print('[ERROR] ❌ Supabase initialization failed: $e');
      rethrow;
    }
  }

  // ========== SCHEME QUERIES ==========

  /// Fetch all schemes from database
  /// Returns list of 823 schemes
  Future<List<Scheme>> fetchAllSchemes() async {
    try {
      _log('INFO', '🔄 Fetching all schemes from database...');

      final response = await _supabase
          .from(AppConfig.schemesTable)
          .select()
          .timeout(AppConfig.apiTimeout);

      final schemes = (response as List)
          .map((json) => Scheme.fromJson(json as Map<String, dynamic>))
          .toList();

      _log('INFO', '✅ Fetched ${schemes.length} schemes');
      return schemes;
    } catch (e) {
      final error = 'Error fetching schemes: $e';
      _log('ERROR', error);
      throw SupabaseException(error);
    }
  }

  /// Fetch schemes filtered by category
  Future<List<Scheme>> fetchSchemesByCategory(String category) async {
    try {
      _log('DEBUG', '🔄 Fetching schemes for category: $category');

      final response = await _supabase
          .from(AppConfig.schemesTable)
          .select()
          .eq('category_name', category)
          .timeout(AppConfig.apiTimeout);

      final schemes = (response as List)
          .map((json) => Scheme.fromJson(json as Map<String, dynamic>))
          .toList();

      _log('INFO', '✅ Fetched ${schemes.length} schemes for category: $category');
      return schemes;
    } catch (e) {
      _log('ERROR', '❌ Error fetching schemes by category: $e');
      rethrow;
    }
  }

  /// Fetch schemes for specific state (central + state-specific)
  Future<List<Scheme>> fetchSchemesByState(String state) async {
    try {
      _log('DEBUG', '🔄 Fetching schemes for state: $state');

      final response = await _supabase
          .from(AppConfig.schemesTable)
          .select()
          .or('is_central.eq.true,applicable_states.contains."$state"')
          .timeout(AppConfig.apiTimeout);

      final schemes = (response as List)
          .map((json) => Scheme.fromJson(json as Map<String, dynamic>))
          .toList();

      _log('INFO', '✅ Fetched ${schemes.length} state schemes for: $state');
      return schemes;
    } catch (e) {
      _log('ERROR', '❌ Error fetching schemes by state: $e');
      rethrow;
    }
  }

  /// Search schemes by keyword
  Future<List<Scheme>> searchSchemes(String query) async {
    try {
      _log('DEBUG', '🔄 Searching schemes with query: $query');

      final lowerQuery = query.toLowerCase();

      final response = await _supabase
          .from(AppConfig.schemesTable)
          .select()
          .or('title.ilike.%$lowerQuery%,description.ilike.%$lowerQuery%,benefits.ilike.%$lowerQuery%')
          .timeout(AppConfig.apiTimeout);

      final schemes = (response as List)
          .map((json) => Scheme.fromJson(json as Map<String, dynamic>))
          .toList();

      _log('INFO', '✅ Found ${schemes.length} schemes matching: "$query"');
      return schemes;
    } catch (e) {
      _log('ERROR', '❌ Error searching schemes: $e');
      rethrow;
    }
  }

  /// Fetch new schemes added this month
  Future<List<Scheme>> fetchNewSchemes() async {
    try {
      _log('DEBUG', '🔄 Fetching new schemes...');

      final response = await _supabase
          .from(AppConfig.schemesTable)
          .select()
          .eq('is_new', true)
          .order('created_at', ascending: false)
          .limit(50)
          .timeout(AppConfig.apiTimeout);

      final schemes = (response as List)
          .map((json) => Scheme.fromJson(json as Map<String, dynamic>))
          .toList();

      _log('INFO', '✅ Fetched ${schemes.length} new schemes');
      return schemes;
    } catch (e) {
      _log('ERROR', '❌ Error fetching new schemes: $e');
      rethrow;
    }
  }

  // ========== BOOKMARKS / SAVED SCHEMES ==========

  /// Save scheme to user's bookmarks
  Future<void> bookmarkScheme({
    required String userUuid,
    required String schemeId,
  }) async {
    try {
      _log('DEBUG', '🔄 Bookmarking scheme $schemeId for user $userUuid');

      await _supabase
          .from(AppConfig.savedSchemesTable)
          .insert({
            'user_uuid': userUuid,
            'scheme_id': schemeId,
            'created_at': DateTime.now().toIso8601String(),
          })
          .timeout(AppConfig.apiTimeout);

      _log('INFO', '✅ Scheme bookmarked successfully');
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        _log('INFO', '⚠️ Scheme already bookmarked');
      } else {
        _log('ERROR', '❌ Database error: ${e.message}');
        rethrow;
      }
    } catch (e) {
      _log('ERROR', '❌ Error bookmarking scheme: $e');
      rethrow;
    }
  }

  /// Remove scheme from bookmarks
  Future<void> unbookmarkScheme({
    required String userUuid,
    required String schemeId,
  }) async {
    try {
      _log('DEBUG', '🔄 Removing bookmark for scheme $schemeId');

      await _supabase
          .from(AppConfig.savedSchemesTable)
          .delete()
          .eq('user_uuid', userUuid)
          .eq('scheme_id', schemeId)
          .timeout(AppConfig.apiTimeout);

      _log('INFO', '✅ Scheme unbookmarked successfully');
    } catch (e) {
      _log('ERROR', '❌ Error unbookmarking scheme: $e');
      rethrow;
    }
  }

  /// Get all bookmarked schemes for user
  Future<List<String>> getBookmarkedSchemeIds(String userUuid) async {
    try {
      _log('DEBUG', '🔄 Fetching bookmarked schemes for user $userUuid');

      final response = await _supabase
          .from(AppConfig.savedSchemesTable)
          .select('scheme_id')
          .eq('user_uuid', userUuid)
          .timeout(AppConfig.apiTimeout);

      final schemeIds = (response as List)
          .map((item) => item['scheme_id'] as String)
          .toList();

      _log('INFO', '✅ Fetched ${schemeIds.length} bookmarked schemes');
      return schemeIds;
    } catch (e) {
      _log('ERROR', '❌ Error fetching bookmarked schemes: $e');
      rethrow;
    }
  }

  // ========== ANALYTICS & TRACKING ==========

  /// Record scheme view (for analytics)
  Future<void> recordSchemeView({
    required String userUuid,
    required String schemeId,
  }) async {
    try {
      if (!AppConfig.enableAnalytics) return;

      _log('DEBUG', '📊 Recording scheme view');

      // Increment view count in schemes table
      await _supabase
          .from(AppConfig.schemesTable)
          .update({'view_count': 'view_count + 1'})
          .eq('id', schemeId)
          .timeout(AppConfig.apiTimeout);

      _log('DEBUG', '✅ View recorded');
    } catch (e) {
      _log('INFO', '⚠️ Error recording view (non-critical): $e');
      // Don't rethrow - this is non-critical
    }
  }

  /// Save user profile to analytics table
  Future<void> saveUserProfileAnalytics(UserProfile profile) async {
    try {
      if (!AppConfig.enableAnalytics) return;

      _log('DEBUG', '📊 Saving user profile to analytics');

      await _supabase
          .from(AppConfig.userAnalyticsTable)
          .insert({
            'user_uuid': profile.uuid,
            'gender': profile.gender,
            'age': profile.age,
            'state': profile.state,
            'occupation': profile.occupation,
            'created_at': DateTime.now().toIso8601String(),
          })
          .timeout(AppConfig.apiTimeout);

      _log('INFO', '✅ User profile saved to analytics');
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        _log('INFO', '⚠️ User profile already exists in analytics');
      } else {
        _log('ERROR', '❌ Database error: ${e.message}');
      }
    } catch (e) {
      _log('INFO', '⚠️ Error saving analytics (non-critical): $e');
      // Don't rethrow - this is non-critical
    }
  }

  // ========== CONNECTION MANAGEMENT ==========

  /// Check if connected to Supabase
  bool isConnected() {
    try {
      return _supabase.auth.currentUser != null ||
          _supabase.auth.currentSession == null;
    } catch (e) {
      return false;
    }
  }

  /// Close Supabase connection
  Future<void> disconnect() async {
    try {
      _log('DEBUG', '🔄 Disconnecting from Supabase...');
      // Supabase doesn't require explicit disconnect in Flutter
      _log('INFO', '✅ Supabase connection closed');
    } catch (e) {
      _log('ERROR', '❌ Error disconnecting: $e');
    }
  }
}
