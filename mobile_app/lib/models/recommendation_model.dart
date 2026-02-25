import 'package:mobile_app/models/scheme_model.dart';

/// AI/ML Recommendation Engine
/// Contains logic for filtering and ranking schemes based on user profile
class RecommendationEngine {
  /// Filter schemes based on user profile
  /// Returns organized recommendations by match strength
  static Map<String, List<Scheme>> getRecommendations({
    required List<Scheme> allSchemes,
    required String? userGender,
    required int? userAge,
    required String? userState,
    required String? userOccupation,
  }) {
    final occupationSpecific = <Scheme>[];
    final genderSpecific = <Scheme>[];
    final generalCommon = <Scheme>[];

    for (final scheme in allSchemes) {
      if (!scheme.matchesProfile(
        userGender: userGender,
        userAge: userAge,
        userState: userState,
        userOccupation: userOccupation,
      )) {
        continue; // Skip non-matching schemes
      }

      // Categorize based on what matched
      final hasOccupationMatch = scheme.targetOccupation != null &&
          userOccupation != null &&
          scheme.targetOccupation!.contains(userOccupation);

      final hasGenderMatch = scheme.targetGender != null &&
          userGender != null &&
          scheme.targetGender!.contains(userGender);

      if (hasOccupationMatch) {
        occupationSpecific.add(scheme);
      } else if (hasGenderMatch) {
        genderSpecific.add(scheme);
      } else {
        generalCommon.add(scheme);
      }
    }

    // Sort each list by match score (highest first)
    occupationSpecific.sort((a, b) {
      final scoreA = a.calculateMatchScore(
        userGender: userGender,
        userAge: userAge,
        userState: userState,
        userOccupation: userOccupation,
      );
      final scoreB = b.calculateMatchScore(
        userGender: userGender,
        userAge: userAge,
        userState: userState,
        userOccupation: userOccupation,
      );
      return scoreB.compareTo(scoreA);
    });

    genderSpecific.sort((a, b) {
      final scoreA = a.calculateMatchScore(
        userGender: userGender,
        userAge: userAge,
        userState: userState,
        userOccupation: userOccupation,
      );
      final scoreB = b.calculateMatchScore(
        userGender: userGender,
        userAge: userAge,
        userState: userState,
        userOccupation: userOccupation,
      );
      return scoreB.compareTo(scoreA);
    });

    generalCommon.sort((a, b) {
      final scoreA = a.calculateMatchScore(
        userGender: userGender,
        userAge: userAge,
        userState: userState,
        userOccupation: userOccupation,
      );
      final scoreB = b.calculateMatchScore(
        userGender: userGender,
        userAge: userAge,
        userState: userState,
        userOccupation: userOccupation,
      );
      return scoreB.compareTo(scoreA);
    });

    return {
      'occupation_specific': occupationSpecific,
      'gender_specific': genderSpecific,
      'general_common': generalCommon,
    };
  }

  /// Get top N recommended schemes
  static List<Scheme> getTopRecommendations({
    required List<Scheme> allSchemes,
    required String? userGender,
    required int? userAge,
    required String? userState,
    required String? userOccupation,
    int topN = 10,
  }) {
    final recommendations = getRecommendations(
      allSchemes: allSchemes,
      userGender: userGender,
      userAge: userAge,
      userState: userState,
      userOccupation: userOccupation,
    );

    final combined = <Scheme>[
      ...recommendations['occupation_specific'] ?? [],
      ...recommendations['gender_specific'] ?? [],
      ...recommendations['general_common'] ?? [],
    ];

    return combined.take(topN).toList();
  }

  /// Filter schemes by category
  static List<Scheme> filterByCategory({
    required List<Scheme> schemes,
    required String category,
  }) {
    return schemes.where((scheme) => scheme.categoryName == category).toList();
  }

  /// Filter schemes by state
  static List<Scheme> filterByState({
    required List<Scheme> schemes,
    required String state,
  }) {
    return schemes
        .where((scheme) =>
            scheme.isCentral ||
            (scheme.applicableStates?.contains(state) ?? false))
        .toList();
  }

  /// Filter schemes by application status
  static List<Scheme> filterByStatus({
    required List<Scheme> schemes,
    required String status, // 'Open', 'Closed', 'Upcoming'
  }) {
    return schemes
        .where((scheme) =>
            scheme.lastDate == null ||
            (status == 'Open' && scheme.isApplicationOpen()) ||
            (status == 'Closed' && !scheme.isApplicationOpen()))
        .toList();
  }

  /// Search schemes by name or description
  static List<Scheme> search({
    required List<Scheme> schemes,
    required String query,
  }) {
    final lowerQuery = query.toLowerCase();
    return schemes
        .where((scheme) =>
            scheme.title.toLowerCase().contains(lowerQuery) ||
            scheme.description.toLowerCase().contains(lowerQuery) ||
            (scheme.benefits?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }

  /// Sort schemes
  static List<Scheme> sort({
    required List<Scheme> schemes,
    required String sortBy, // 'best_match', 'latest', 'most_popular', 'highest_benefit'
    String? userGender,
    int? userAge,
    String? userState,
    String? userOccupation,
  }) {
    final sorted = List<Scheme>.from(schemes);

    switch (sortBy) {
      case 'best_match':
        sorted.sort((a, b) {
          final scoreA = a.calculateMatchScore(
            userGender: userGender,
            userAge: userAge,
            userState: userState,
            userOccupation: userOccupation,
          );
          final scoreB = b.calculateMatchScore(
            userGender: userGender,
            userAge: userAge,
            userState: userState,
            userOccupation: userOccupation,
          );
          return scoreB.compareTo(scoreA);
        });
        break;
      case 'latest':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'most_popular':
        sorted.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case 'highest_benefit':
        // Could parse benefit amounts here if stored in consistent format
        break;
    }

    return sorted;
  }
}

