import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/models/models.dart';
import 'package:mobile_app/services/local_storage_service.dart';
import 'package:mobile_app/services/supabase_service.dart';

/// Saved Schemes State Notifier - manages bookmarked/saved schemes
class SavedSchemesNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final LocalStorageService localStorageService;
  final SupabaseService supabaseService;

  SavedSchemesNotifier({
    required this.localStorageService,
    required this.supabaseService,
  }) : super(const AsyncValue.loading()) {
    _loadSavedSchemeIds();
  }

  /// Load saved scheme IDs from local storage
  Future<void> _loadSavedSchemeIds() async {
    try {
      state = const AsyncValue.loading();
      print('[INFO] Loading saved scheme IDs...');

      final savedIds = await localStorageService.getSavedSchemeIds();

      state = AsyncValue.data(List.unmodifiable(savedIds));
      print('[INFO] Loaded ${savedIds.length} saved schemes');
    } catch (error, stackTrace) {
      print('[ERROR] Failed to load saved schemes: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Add a scheme to saved
  Future<void> saveScheme(String schemeId) async {
    try {
      // Get current state
      final currentIds = state.whenData((ids) => ids).value ?? [];

      if (currentIds.contains(schemeId)) {
        print('[DEBUG] Scheme already saved: $schemeId');
        return;
      }

      // Add to local storage
      await localStorageService.addSavedScheme(schemeId);

      // Update state with new list
      final updatedIds = [...currentIds, schemeId];
      state = AsyncValue.data(List.unmodifiable(updatedIds));

      print('[INFO] Scheme saved: $schemeId');
    } catch (error, stackTrace) {
      print('[ERROR] Failed to save scheme: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Remove a scheme from saved
  Future<void> removeSavedScheme(String schemeId) async {
    try {
      // Get current state
      final currentIds = state.whenData((ids) => ids).value ?? [];

      if (!currentIds.contains(schemeId)) {
        print('[DEBUG] Scheme not in saved: $schemeId');
        return;
      }

      // Remove from local storage
      await localStorageService.removeSavedScheme(schemeId);

      // Update state with filtered list
      final updatedIds =
          currentIds.where((id) => id != schemeId).toList();
      state = AsyncValue.data(List.unmodifiable(updatedIds));

      print('[INFO] Scheme removed from saved: $schemeId');
    } catch (error, stackTrace) {
      print('[ERROR] Failed to remove saved scheme: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Toggle scheme bookmark status
  Future<void> toggleSaveScheme(String schemeId) async {
    try {
      final currentIds = state.whenData((ids) => ids).value ?? [];

      if (currentIds.contains(schemeId)) {
        await removeSavedScheme(schemeId);
      } else {
        await saveScheme(schemeId);
      }
    } catch (error) {
      print('[ERROR] Failed to toggle save scheme: $error');
    }
  }

  /// Check if scheme is saved
  bool isSchemeSaved(String schemeId) {
    try {
      final ids = state.whenData((savedIds) => savedIds).value ?? [];
      return ids.contains(schemeId);
    } catch (e) {
      print('[WARNING] Error checking if scheme is saved: $e');
      return false;
    }
  }

  /// Clear all saved schemes
  Future<void> clearAllSaved() async {
    try {
      await localStorageService.clearSavedSchemes();
      state = const AsyncValue.data([]);
      print('[INFO] All saved schemes cleared');
    } catch (error, stackTrace) {
      print('[ERROR] Failed to clear saved schemes: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Get count of saved schemes
  int getSavedCount() {
    try {
      final ids = state.whenData((savedIds) => savedIds).value ?? [];
      return ids.length;
    } catch (e) {
      return 0;
    }
  }
}

/// Provider for Local Storage Service (dependency)
final savedLocalStorageProvider = Provider((ref) {
  return LocalStorageService.getInstance();
});

/// Provider for Supabase Service (dependency)
final savedSupabaseProvider = Provider((ref) {
  return SupabaseService();
});

/// Main Saved Schemes IDs Provider (list of scheme IDs)
final savedSchemeIdsProvider =
    StateNotifierProvider<SavedSchemesNotifier, AsyncValue<List<String>>>((ref) {
  final localStorageService = ref.watch(savedLocalStorageProvider);
  final supabaseService = ref.watch(savedSupabaseProvider);

  return SavedSchemesNotifier(
    localStorageService: localStorageService,
    supabaseService: supabaseService,
  );
});

/// Get saved schemes as full Scheme objects (requires schemes provider)
final savedSchemesProvider = FutureProvider<List<Scheme>>((ref) async {
  final savedIds = ref.watch(savedSchemeIdsProvider);
  // Import will be fixed in index.dart
  final schemes = <Scheme>[];

  return savedIds.when(
    data: (ids) {
      // This will be populated via schemes provider in implementation
      return schemes;
    },
    loading: () => [],
    error: (error, stack) => [],
  );
});

/// Get count of saved schemes
final savedCountProvider = Provider<int>((ref) {
  final savedIds = ref.watch(savedSchemeIdsProvider);

  return savedIds.when(
    data: (ids) => ids.length,
    loading: () => 0,
    error: (error, stack) => 0,
  );
});

/// Check if a specific scheme is saved
final isSchemeSlvedProvider =
    Provider.family<bool, String>((ref, schemeId) {
  final savedIds = ref.watch(savedSchemeIdsProvider);

  return savedIds.when(
    data: (ids) => ids.contains(schemeId),
    loading: () => false,
    error: (error, stack) => false,
  );
});

/// Helper to get saved scheme IDs only
final savedSchemeIdsListProvider = Provider<List<String>>((ref) {
  final savedIds = ref.watch(savedSchemeIdsProvider);

  return savedIds.when(
    data: (ids) => ids,
    loading: () => [],
    error: (error, stack) => [],
  );
});
