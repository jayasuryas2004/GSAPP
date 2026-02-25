import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/models/models.dart';
import 'package:mobile_app/providers/scheme_provider.dart';
import 'package:mobile_app/providers/user_provider.dart';

/// Helper to convert AsyncValue to simple data for recommendations
extension _AsyncValueExt<T> on AsyncValue<T> {
  T? getDataOrNull() {
    return whenData((data) => data).value;
  }
}

/// Recommendations Provider - personalized schemes based on user profile
final recommendationsProvider = FutureProvider<Map<String, List<Scheme>>>((ref) async {
  // Watch both providers and extract data
  final userAsync = ref.watch(userProfileProvider);
  final schemesAsync = ref.watch(schemesProvider);

  final userProfile = userAsync.getDataOrNull();
  final schemes = schemesAsync.getDataOrNull();

  if (userProfile == null || schemes == null || schemes.isEmpty) {
    print('[WARNING] Missing user profile or schemes for recommendations');
    return <String, List<Scheme>>{};
  }

  try {
    print('[INFO] Generating recommendations for user: ${userProfile.uuid}');

    // Generate recommendations by category
    final recommendationsByCategory = <String, List<Scheme>>{};

    // Group schemes by category
    final schemesByCategory = <String, List<Scheme>>{};
    for (final scheme in schemes) {
      if (!schemesByCategory.containsKey(scheme.categoryName)) {
        schemesByCategory[scheme.categoryName] = [];
      }
      schemesByCategory[scheme.categoryName]!.add(scheme);
    }

    // Get top matches per category
    for (final category in schemesByCategory.keys) {
      final categorySchemes = schemesByCategory[category]!;
      
      // Calculate match scores
      final scoredSchemes = <(Scheme, int)>[];
      for (final scheme in categorySchemes) {
        final score = scheme.calculateMatchScore(
          userGender: userProfile.gender,
          userAge: userProfile.age,
          userOccupation: userProfile.occupation,
          userState: userProfile.state,
        );
        scoredSchemes.add((scheme, score));
      }

      // Sort by score (descending) and take top 5
      scoredSchemes.sort((a, b) => b.$2.compareTo(a.$2));
      final topSchemes = scoredSchemes.take(5).map((e) => e.$1).toList();

      if (topSchemes.isNotEmpty) {
        recommendationsByCategory[category] = topSchemes;
      }
    }

    print('[INFO] Generated recommendations for ${recommendationsByCategory.length} categories');
    return recommendationsByCategory;
  } catch (error) {
    print('[ERROR] Failed to generate recommendations: $error');
    return <String, List<Scheme>>{};
  }
});

/// Get top N recommendations across all categories
final topRecommendationsProvider = FutureProvider.family<List<Scheme>, int>((ref, topN) async {
  final recommendationsMap = await ref.watch(recommendationsProvider.future);
  
  try {
    final allRecommendations = <Scheme>[];
    
    // Flatten all recommendations preserving order
    for (final category in recommendationsMap.keys) {
      allRecommendations.addAll(recommendationsMap[category]!);
    }

    // Take top N
    final topSchemes = allRecommendations.take(topN).toList();
    print('[INFO] Returning top $topN recommendations (total: ${topSchemes.length})');
    
    return topSchemes;
  } catch (error) {
    print('[ERROR] Failed to get top recommendations: $error');
    return [];
  }
});

/// Get recommendations for specific category
final recommendationsByCategoryProvider =
    FutureProvider.family<List<Scheme>, String>((ref, categoryName) async {
  final recommendationsMap = await ref.watch(recommendationsProvider.future);
  
  return recommendationsMap[categoryName] ?? [];
});

/// Get highly relevant recommendations (score > 70)
final relevantRecommendationsProvider = FutureProvider<List<Scheme>>((ref) async {
  final userAsync = ref.watch(userProfileProvider);
  final schemesAsync = ref.watch(schemesProvider);

  final userProfile = userAsync.getDataOrNull();
  final schemes = schemesAsync.getDataOrNull();

  if (userProfile == null || schemes == null || schemes.isEmpty) {
    return [];
  }

  try {
    // Score all schemes
    final scoredSchemes = <(Scheme, int)>[];
    
    for (final scheme in schemes) {
      final score = scheme.calculateMatchScore(
        userGender: userProfile.gender,
        userAge: userProfile.age,
        userOccupation: userProfile.occupation,
        userState: userProfile.state,
      );
      
      // Only include highly relevant matches (score > 70)
      if (score > 70) {
        scoredSchemes.add((scheme, score));
      }
    }

    // Sort by score descending
    scoredSchemes.sort((a, b) => b.$2.compareTo(a.$2));
    
    final relevantSchemes = scoredSchemes.map((e) => e.$1).toList();
    print('[INFO] Found ${relevantSchemes.length} highly relevant recommendations');
    
    return relevantSchemes;
  } catch (error) {
    print('[ERROR] Failed to get relevant recommendations: $error');
    return [];
  }
});

/// Get match score for a specific scheme
final schemeMatchScoreProvider =
    FutureProvider.family<int, String>((ref, schemeId) async {
  final userAsync = ref.watch(userProfileProvider);
  final schemeAsync = ref.watch(schemeByIdProvider(schemeId));

  final userProfile = userAsync.getDataOrNull();
  final scheme = schemeAsync.getDataOrNull();

  if (userProfile == null || scheme == null) {
    return 0;
  }

  try {
    final score = scheme.calculateMatchScore(
      userGender: userProfile.gender,
      userAge: userProfile.age,
      userOccupation: userProfile.occupation,
      userState: userProfile.state,
    );
    
    print('[DEBUG] Match score for scheme $schemeId: $score');
    return score;
  } catch (error) {
    print('[ERROR] Failed to calculate match score: $error');
    return 0;
  }
});
