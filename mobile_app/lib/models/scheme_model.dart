/// ============================================================================
/// SCHEME MODEL (PRODUCTION VERSION)
/// ============================================================================
///
/// This model represents ONE government scheme from the database.
/// It's the blueprint for how scheme data looks.
///
/// Enhanced with targeting fields for personality recommendations:
/// - targetGender, targetOccupation, targetAgeMin/Max
/// - applicableStates for multi-state schemes
/// - calculateMatchScore() for personalized ranking
///
/// Example:
/// Scheme(
///   id: 'uuid-123',
///   title: 'PM-JAY',
///   description: 'Health insurance scheme',
///   state: 'Central',
///   targetGender: ['Any'],
///   ...
/// )
///

class Scheme {
  // ========== BASIC INFO ==========
  final String id;                    // Unique identifier
  final String title;                 // Scheme name (English)
  final String? titleTa;              // Scheme name (Tamil)
  final String description;           // What the scheme does
  final String? descriptionTa;        // Description (Tamil)
  final String? shortDescription;     // One-line summary

  // ========== LOCATION & CATEGORY ==========
  final String stateName;             // Which state (Tamil Nadu, Kerala, etc.)
  final String categoryName;          // Category (Education, Health, etc.)
  final bool isCentral;               // Is it a central or state scheme?
  final List<String>? applicableStates; // For multi-state schemes

  // ========== APPLICATION INFO ==========
  final String applyLink;             // URL to apply
  final String? sourceUrl;            // Where we scraped this from
  final DateTime? lastDate;           // Last date to apply

  // ========== BENEFITS & ELIGIBILITY ==========
  final String? benefits;             // What you get from this scheme
  final String? benefitsTa;           // Benefits (Tamil)
  final String? benefitAmount;        // e.g., '₹6000/year', 'Free'
  final int? eligibilityAgeMin;       // Minimum age required
  final int? eligibilityAgeMax;       // Maximum age allowed
  final String? eligibilityGender;    // Gender requirement (any, male, female)
  final int? eligibilityIncomeMax;    // Maximum income limit

  // ========== TARGETING FIELDS (For Recommendations) ==========
  final List<String>? targetGender;   // ['Any', 'Male', 'Female'] - exact targets
  final List<String>? targetOccupation; // ['Farmer', 'Student', etc.]
  final int? targetAgeMin;            // Recommended min age
  final int? targetAgeMax;            // Recommended max age

  // ========== METADATA ==========
  final String? agency;               // Which agency runs it
  final String? badge;                // Special tag (New, Popular, etc.)
  final String? highlight;            // Featured info
  final String? imageUrl;             // Image for the scheme
  final String source;                // Where we got this (scrapy, json, etc.)
  final bool isNew;                   // Added this month
  final double? rating;               // User ratings (0-5)
  final int viewCount;                // Times viewed

  // ========== TIMESTAMPS ==========
  final DateTime createdAt;           // When added to database
  final DateTime updatedAt;           // When last updated

  // Constructor
  Scheme({
    required this.id,
    required this.title,
    this.titleTa,
    required this.description,
    this.descriptionTa,
    this.shortDescription,
    required this.stateName,
    required this.categoryName,
    this.isCentral = false,
    this.applicableStates,
    required this.applyLink,
    this.sourceUrl,
    this.lastDate,
    this.benefits,
    this.benefitsTa,
    this.benefitAmount,
    this.eligibilityAgeMin,
    this.eligibilityAgeMax,
    this.eligibilityGender,
    this.eligibilityIncomeMax,
    this.targetGender,
    this.targetOccupation,
    this.targetAgeMin,
    this.targetAgeMax,
    this.agency,
    this.badge,
    this.highlight,
    this.imageUrl,
    this.source = 'unknown',
    this.isNew = false,
    this.rating,
    this.viewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // ========== MATCHING & SCORING METHODS ==========

  /// Check if scheme matches user profile completely
  bool matchesProfile({
    required String? userGender,
    required int? userAge,
    required String? userState,
    required String? userOccupation,
  }) {
    // Check gender match
    if (targetGender != null && !targetGender!.contains('Any')) {
      if (userGender == null || !targetGender!.contains(userGender)) {
        return false;
      }
    }

    // Check occupation match
    if (targetOccupation != null && !targetOccupation!.contains('Any')) {
      if (userOccupation == null || !targetOccupation!.contains(userOccupation)) {
        return false;
      }
    }

    // Check age match
    if (userAge != null) {
      if (targetAgeMin != null && userAge < targetAgeMin!) return false;
      if (targetAgeMax != null && userAge > targetAgeMax!) return false;
    }

    // Check state applicability
    if (!isCentral && applicableStates != null) {
      if (userState == null || !applicableStates!.contains(userState)) {
        return false;
      }
    }

    return true;
  }

  /// Calculate match score (0-100) for personalized ranking
  /// Scoring:
  /// - Occupation exact match: +30
  /// - Gender exact match: +20
  /// - Age match: +15
  /// - State scheme: +10
  /// - New scheme: +5
  /// - Rating bonus: +5 (if >= 4.0)
  int calculateMatchScore({
    required String? userGender,
    required int? userAge,
    required String? userState,
    required String? userOccupation,
  }) {
    if (!matchesProfile(
      userGender: userGender,
      userAge: userAge,
      userState: userState,
      userOccupation: userOccupation,
    )) {
      return 0; // Doesn't match at all
    }

    int score = 0;

    // Occupation exact match: +30
    if (targetOccupation != null &&
        userOccupation != null &&
        targetOccupation!.contains(userOccupation)) {
      score += 30;
    }

    // Gender exact match: +20
    if (targetGender != null &&
        userGender != null &&
        targetGender!.contains(userGender)) {
      score += 20;
    }

    // Age range match: +15
    if (userAge != null && targetAgeMin != null && targetAgeMax != null) {
      if (userAge >= targetAgeMin! && userAge <= targetAgeMax!) {
        score += 15;
      }
    }

    // State scheme bonus: +10
    if (!isCentral && userState != null) {
      score += 10;
    }

    // New scheme bonus: +5
    if (isNew) {
      score += 5;
    }

    // Rating bonus: +5
    if (rating != null && rating! >= 4.0) {
      score += 5;
    }

    return score.clamp(0, 100);
  }

  /// Get match description
  String getMatchDescription(int score) {
    if (score >= 85) return 'Perfect Match';
    if (score >= 65) return 'Good Match';
    if (score >= 40) return 'Possible Match';
    return 'May Apply';
  }

  // ========== HELPER METHODS ==========

  /// Is this scheme still open for applications?
  bool isApplicationOpen() {
    if (lastDate == null) return true;
    return DateTime.now().isBefore(lastDate!);
  }

  /// Get the correct title (English or Tamil)
  String getTitle({bool useTamil = false}) {
    if (useTamil && titleTa != null) return titleTa!;
    return title;
  }

  /// Get the correct description
  String getDescription({bool useTamil = false}) {
    if (useTamil && descriptionTa != null) return descriptionTa!;
    return description;
  }

  /// Is user age eligible?
  bool isAgeEligible(int age) {
    if (eligibilityAgeMin != null && age < eligibilityAgeMin!) return false;
    if (eligibilityAgeMax != null && age > eligibilityAgeMax!) return false;
    return true;
  }

  /// Is user income eligible?
  bool isIncomeEligible(int annualIncome) {
    if (eligibilityIncomeMax != null && annualIncome > eligibilityIncomeMax!) {
      return false;
    }
    return true;
  }

  /// Get scheme type (Central or State)
  String getType() {
    return isCentral ? 'Central Scheme' : 'State Scheme';
  }

  /// ========== JSON SERIALIZATION ==========
  /// Convert from JSON (from Supabase) to Scheme object
  factory Scheme.fromJson(Map<String, dynamic> json) {
    return Scheme(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown Scheme',
      titleTa: json['title_ta'] as String?,
      description: json['description'] as String? ?? '',
      descriptionTa: json['description_ta'] as String?,
      shortDescription: json['short_description'] as String?,
      stateName: json['state_name'] as String? ?? 'Central',
      categoryName: json['category_name'] as String? ?? 'Other',
      isCentral: json['is_central'] as bool? ?? false,
      applicableStates: List<String>.from(
          json['applicable_states'] as List<dynamic>? ?? <String>[]),
      applyLink: json['apply_link'] as String? ?? '',
      sourceUrl: json['source_url'] as String?,
      lastDate: json['last_date'] != null
          ? DateTime.parse(json['last_date'] as String)
          : null,
      benefits: json['benefits'] as String?,
      benefitsTa: json['benefits_ta'] as String?,
      benefitAmount: json['benefit_amount'] as String?,
      eligibilityAgeMin: json['eligibility_age_min'] as int?,
      eligibilityAgeMax: json['eligibility_age_max'] as int?,
      eligibilityGender: json['eligibility_gender'] as String?,
      eligibilityIncomeMax: json['eligibility_income_max'] as int?,
      targetGender: List<String>.from(
          json['target_gender'] as List<dynamic>? ?? <String>[]),
      targetOccupation: List<String>.from(
          json['target_occupation'] as List<dynamic>? ?? <String>[]),
      targetAgeMin: json['target_age_min'] as int?,
      targetAgeMax: json['target_age_max'] as int?,
      agency: json['agency'] as String?,
      badge: json['badge'] as String?,
      highlight: json['highlight'] as String?,
      imageUrl: json['image_url'] as String?,
      source: json['source'] as String? ?? 'unknown',
      isNew: json['is_new'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
      viewCount: json['view_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert Scheme to JSON (for sending to database)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_ta': titleTa,
      'description': description,
      'description_ta': descriptionTa,
      'short_description': shortDescription,
      'state_name': stateName,
      'category_name': categoryName,
      'is_central': isCentral,
      'applicable_states': applicableStates,
      'apply_link': applyLink,
      'source_url': sourceUrl,
      'last_date': lastDate?.toIso8601String(),
      'benefits': benefits,
      'benefits_ta': benefitsTa,
      'benefit_amount': benefitAmount,
      'eligibility_age_min': eligibilityAgeMin,
      'eligibility_age_max': eligibilityAgeMax,
      'eligibility_gender': eligibilityGender,
      'eligibility_income_max': eligibilityIncomeMax,
      'target_gender': targetGender,
      'target_occupation': targetOccupation,
      'target_age_min': targetAgeMin,
      'target_age_max': targetAgeMax,
      'agency': agency,
      'badge': badge,
      'highlight': highlight,
      'image_url': imageUrl,
      'source': source,
      'is_new': isNew,
      'rating': rating,
      'view_count': viewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Scheme(id: $id, title: $title, state: $stateName, category: $categoryName)';
  }
}
