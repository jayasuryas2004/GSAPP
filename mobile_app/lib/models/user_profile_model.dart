/// User Profile Model
/// Represents user information collected during onboarding
class UserProfile {
  final String uuid;
  final String? gender; // 'Male', 'Female', 'Prefer Not to Say'
  final int? age;
  final String? state;
  final String? occupation;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    String? uuid,
    this.gender,
    this.age,
    this.state,
    this.occupation,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : uuid = uuid ?? _generateDefaultUuid(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Generate a default UUID (will be replaced with device UUID in real app)
  static String _generateDefaultUuid() {
    return 'profile-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'gender': gender,
      'age': age,
      'state': state,
      'occupation': occupation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uuid: json['uuid'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      state: json['state'] as String?,
      occupation: json['occupation'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Copy with modifications
  UserProfile copyWith({
    String? uuid,
    String? gender,
    int? age,
    String? state,
    String? occupation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uuid: uuid ?? this.uuid,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      state: state ?? this.state,
      occupation: occupation ?? this.occupation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if profile is complete
  bool get isComplete {
    return gender != null &&
        age != null &&
        state != null &&
        occupation != null;
  }

  /// Get profile completion percentage
  int get completionPercentage {
    int count = 0;
    if (gender != null) count++;
    if (age != null) count++;
    if (state != null) count++;
    if (occupation != null) count++;
    return (count / 4 * 100).toInt();
  }

  @override
  String toString() {
    return 'UserProfile(uuid: $uuid, gender: $gender, age: $age, state: $state, occupation: $occupation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile &&
        other.uuid == uuid &&
        other.gender == gender &&
        other.age == age &&
        other.state == state &&
        other.occupation == occupation;
  }

  @override
  int get hashCode {
    return uuid.hashCode ^
        gender.hashCode ^
        age.hashCode ^
        state.hashCode ^
        occupation.hashCode;
  }
}
