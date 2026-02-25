import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/models/models.dart';
import 'package:mobile_app/services/supabase_service.dart';
import 'package:mobile_app/providers/scheme_provider.dart';

/// Search state class to hold search results and query
class SearchState {
  final String query;
  final List<Scheme> results;
  final bool isLoading;
  final String? error;

  SearchState({
    required this.query,
    required this.results,
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<Scheme>? results,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Search Notifier for managing search state
class SearchNotifier extends StateNotifier<SearchState> {
  final SupabaseService supabaseService;

  SearchNotifier({required this.supabaseService})
      : super(SearchState(query: '', results: []));

  /// Perform search query
  Future<void> search(String query) async {
    try {
      if (query.isEmpty) {
        state = SearchState(query: '', results: []);
        return;
      }

      state = state.copyWith(query: query, isLoading: true, error: null);
      print('[INFO] Searching for: "$query"');

      // Perform search via Supabase service
      final results = await supabaseService.searchSchemes(query);

      state = state.copyWith(
        query: query,
        results: results,
        isLoading: false,
        error: null,
      );

      print('[INFO] Search found ${results.length} results for "$query"');
    } catch (error) {
      print('[ERROR] Search failed: $error');
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  /// Clear search
  void clearSearch() {
    state = SearchState(query: '', results: []);
    print('[DEBUG] Search cleared');
  }

  /// Update query without searching (for UI input)
  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  /// Filter current results (client-side filtering)
  void filterResults(String Function(Scheme) filter) {
    try {
      final filtered = state.results
          .where((scheme) {
            final filterValue = filter(scheme);
            return scheme.title.toLowerCase().contains(filterValue.toLowerCase()) ||
                scheme.description
                    .toLowerCase()
                    .contains(filterValue.toLowerCase());
          })
          .toList();

      state = state.copyWith(results: filtered);
      print('[DEBUG] Filtered to ${filtered.length} results');
    } catch (error) {
      print('[ERROR] Filter failed: $error');
    }
  }
}

/// Provider for Supabase Service (dependency)
final searchSupabaseServiceProvider = Provider((ref) {
  return SupabaseService();
});

/// Main Search Provider
final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final supabaseService = ref.watch(searchSupabaseServiceProvider);
  return SearchNotifier(supabaseService: supabaseService);
});

/// Helper provider to get search results only
final searchResultsProvider = Provider<List<Scheme>>((ref) {
  final searchState = ref.watch(searchProvider);
  return searchState.results;
});

/// Helper provider to get current search query
final searchQueryProvider = Provider<String>((ref) {
  final searchState = ref.watch(searchProvider);
  return searchState.query;
});

/// Helper provider to check if search is loading
final searchLoadingProvider = Provider<bool>((ref) {
  final searchState = ref.watch(searchProvider);
  return searchState.isLoading;
});

/// Helper provider to get search error if any
final searchErrorProvider = Provider<String?>((ref) {
  final searchState = ref.watch(searchProvider);
  return searchState.error;
});

/// Advanced search with multiple filters
final advancedSearchProvider = FutureProvider.family<List<Scheme>, Map<String, dynamic>>((ref, filters) async {
  final schemes = ref.watch(schemesProvider);
  
  return schemes.when(
    data: (allSchemes) {
      try {
        var results = allSchemes;

        // Filter by query (if present)
        if (filters['query'] != null && filters['query'].isNotEmpty) {
          final query = filters['query'].toString().toLowerCase();
          results = results
              .where((scheme) =>
                  scheme.title.toLowerCase().contains(query) ||
                  scheme.description.toLowerCase().contains(query))
              .toList();
        }

        // Filter by category (if present)
        if (filters['category'] != null && filters['category'].isNotEmpty) {
          final category = filters['category'].toString();
          results = results
              .where((scheme) =>
                  scheme.categoryName.toLowerCase() == category.toLowerCase())
              .toList();
        }

        // Filter by state (if present)
        if (filters['state'] != null && filters['state'].isNotEmpty) {
          final state = filters['state'].toString();
          results = results
              .where((scheme) =>
                  scheme.stateName.toLowerCase() == state.toLowerCase() ||
                  (scheme.applicableStates?.contains(state) ?? false))
              .toList();
        }

        print('[DEBUG] Advanced search returned ${results.length} results');
        return results;
      } catch (error) {
        print('[ERROR] Advanced search failed: $error');
        return [];
      }
    },
    loading: () => [],
    error: (error, stack) => [],
  );
});
