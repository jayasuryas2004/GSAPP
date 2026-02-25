import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/models/models.dart';
import 'package:mobile_app/services/supabase_service.dart';

/// In-memory cache for all schemes
class SchemesCacheNotifier extends StateNotifier<AsyncValue<List<Scheme>>> {
  final SupabaseService supabaseService;
  
  // Cache for all schemes
  List<Scheme> _allSchemes = [];
  DateTime? _lastSyncTime;
  static const Duration _cacheDuration = Duration(hours: 1);

  SchemesCacheNotifier({required this.supabaseService})
      : super(const AsyncValue.loading()) {
    _loadAllSchemes();
  }

  /// Load all schemes from Supabase (with caching)
  Future<void> _loadAllSchemes() async {
    try {
      // Check if cache is still valid
      if (_allSchemes.isNotEmpty && _lastSyncTime != null) {
        final age = DateTime.now().difference(_lastSyncTime!);
        if (age < _cacheDuration) {
          print('[DEBUG] Using cached schemes (age: ${age.inMinutes} minutes)');
          state = AsyncValue.data(List.unmodifiable(_allSchemes));
          return;
        }
      }

      state = const AsyncValue.loading();
      print('[INFO] Fetching all schemes from Supabase...');
      
      final schemes = await supabaseService.fetchAllSchemes();
      _allSchemes = schemes;
      _lastSyncTime = DateTime.now();
      
      state = AsyncValue.data(List.unmodifiable(schemes));
      print('[INFO] Loaded ${schemes.length} schemes successfully');
    } catch (error, stackTrace) {
      print('[ERROR] Failed to load schemes: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Get scheme by ID
  Scheme? getSchemeById(String schemeId) {
    try {
      return _allSchemes.firstWhere((scheme) => scheme.id == schemeId);
    } catch (e) {
      print('[WARNING] Scheme not found: $schemeId');
      return null;
    }
  }

  /// Refresh schemes (force update from Supabase)
  Future<void> refreshSchemes() async {
    try {
      _lastSyncTime = null; // Invalidate cache
      await _loadAllSchemes();
    } catch (e) {
      print('[ERROR] Failed to refresh schemes: $e');
    }
  }

  /// Get schemes by category
  List<Scheme> getSchemesByCategory(String categoryName) {
    try {
      return _allSchemes
          .where((scheme) =>
              scheme.categoryName.toLowerCase() == categoryName.toLowerCase())
          .toList();
    } catch (e) {
      print('[ERROR] Failed to get schemes by category: $e');
      return [];
    }
  }

  /// Get schemes by state
  List<Scheme> getSchemesByState(String stateName) {
    try {
      return _allSchemes
          .where((scheme) =>
              scheme.stateName.toLowerCase() == stateName.toLowerCase() ||
              (scheme.applicableStates?.contains(stateName) ?? false))
          .toList();
    } catch (e) {
      print('[ERROR] Failed to get schemes by state: $e');
      return [];
    }
  }

  /// Clear cache
  void clearCache() {
    _allSchemes = [];
    _lastSyncTime = null;
    state = const AsyncValue.loading();
  }
}

/// Provider for Supabase Service (dependency)
final supabaseServiceProvider = Provider((ref) {
  return SupabaseService();
});

/// Main Schemes Provider - all schemes in system
final schemesProvider =
    StateNotifierProvider<SchemesCacheNotifier, AsyncValue<List<Scheme>>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return SchemesCacheNotifier(supabaseService: supabaseService);
});

/// Get a single scheme by ID
final schemeByIdProvider =
    FutureProvider.family<Scheme?, String>((ref, schemeId) async {
  final schemes = ref.watch(schemesProvider);
  
  return schemes.when(
    data: (schemesList) {
      try {
        return schemesList.firstWhere((scheme) => scheme.id == schemeId);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (error, stack) => null,
  );
});

/// Get schemes by category
final schemesByCategoryProvider =
    FutureProvider.family<List<Scheme>, String>((ref, categoryName) async {
  final schemes = ref.watch(schemesProvider);
  
  return schemes.when(
    data: (schemesList) {
      return schemesList
          .where((scheme) =>
              scheme.categoryName.toLowerCase() == categoryName.toLowerCase())
          .toList();
    },
    loading: () => [],
    error: (error, stack) => [],
  );
});

/// Get schemes by state
final schemesByStateProvider =
    FutureProvider.family<List<Scheme>, String>((ref, stateName) async {
  final schemes = ref.watch(schemesProvider);
  
  return schemes.when(
    data: (schemesList) {
      return schemesList
          .where((scheme) =>
              scheme.stateName.toLowerCase() == stateName.toLowerCase() ||
              (scheme.applicableStates?.contains(stateName) ?? false))
          .toList();
    },
    loading: () => [],
    error: (error, stack) => [],
  );
});

/// Get all unique categories
final schemseCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final schemes = ref.watch(schemesProvider);
  
  return schemes.when(
    data: (schemesList) {
      final categories = <String>{};
      for (final scheme in schemesList) {
        categories.add(scheme.categoryName);
      }
      return categories.toList()..sort();
    },
    loading: () => [],
    error: (error, stack) => [],
  );
});

/// Get all unique states
final schemesStatesProvider = FutureProvider<List<String>>((ref) async {
  final schemes = ref.watch(schemesProvider);
  
  return schemes.when(
    data: (schemesList) {
      final states = <String>{};
      for (final scheme in schemesList) {
        states.add(scheme.stateName);
        if (scheme.applicableStates != null) {
          states.addAll(scheme.applicableStates!);
        }
      }
      return states.toList()..sort();
    },
    loading: () => [],
    error: (error, stack) => [],
  );
});
