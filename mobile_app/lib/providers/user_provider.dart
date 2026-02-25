import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/models/models.dart';
import 'package:mobile_app/services/local_storage_service.dart';
import 'package:mobile_app/services/uuid_service.dart';

/// User Profile State Notifier for managing user profile state changes
class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final LocalStorageService localStorageService;
  final UuidService uuidService;

  UserProfileNotifier({
    required this.localStorageService,
    required this.uuidService,
  }) : super(const AsyncValue.loading()) {
    _initializeUserProfile();
  }

  /// Initialize user profile from local storage or create new
  Future<void> _initializeUserProfile() async {
    try {
      state = const AsyncValue.loading();
      
      // Try to load existing profile from local storage
      final existingProfile = await localStorageService.getUserProfile();
      
      if (existingProfile != null) {
        state = AsyncValue.data(existingProfile);
      } else {
        // Create new profile stub with device UUID
        final deviceUuid = await uuidService.getOrCreateUuid();
        final newProfile = UserProfile(uuid: deviceUuid);
        
        // Save to local storage
        await localStorageService.saveUserProfile(newProfile);
        state = AsyncValue.data(newProfile);
      }
    } catch (error, stackTrace) {
      print('[ERROR] Failed to initialize user profile: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update user profile with new data (partial update)
  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    try {
      state = const AsyncValue.loading();
      
      // Save to local storage
      await localStorageService.saveUserProfile(updatedProfile);
      
      // Update state
      state = AsyncValue.data(updatedProfile);
      print('[INFO] User profile updated successfully');
    } catch (error, stackTrace) {
      print('[ERROR] Failed to update user profile: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update a single field in the user profile
  Future<void> updateProfileField(String field, dynamic value) async {
    try {
      final currentProfile = state.whenData((profile) => profile).value;
      if (currentProfile == null) {
        throw Exception('No active user profile');
      }

      // Update field using LocalStorage service
      await localStorageService.updateProfileField(
        fieldName: field,
        value: value,
      );

      // Update state with new profile from storage
      final updatedProfile = await localStorageService.getUserProfile();
      if (updatedProfile != null) {
        state = AsyncValue.data(updatedProfile);
        print('[INFO] Profile field "$field" updated to "$value"');
      }
    } catch (error, stackTrace) {
      print('[ERROR] Failed to update profile field: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Clear user profile (logout scenario)
  Future<void> clearProfile() async {
    try {
      state = const AsyncValue.loading();
      
      // Clear from local storage
      await localStorageService.clearUserProfile();
      
      // Set to null
      state = const AsyncValue.data(null);
      print('[INFO] User profile cleared');
    } catch (error, stackTrace) {
      print('[ERROR] Failed to clear user profile: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Get current user UUID
  Future<String?> getUserUuid() async {
    try {
      final profile = state.whenData((p) => p).value;
      return profile?.uuid;
    } catch (e) {
      print('[ERROR] Failed to get user UUID: $e');
      return null;
    }
  }
}

/// Provider for Local Storage Service (dependency)
final localStorageServiceProvider = Provider((ref) {
  return LocalStorageService.getInstance();
});

/// Provider for UUID Service (dependency)
final uuidServiceProvider = Provider((ref) {
  final localStorageService = ref.watch(localStorageServiceProvider);
  return UuidService(localStorageService);
});

/// Main User Profile Provider
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final localStorageService = ref.watch(localStorageServiceProvider);
  final uuidService = ref.watch(uuidServiceProvider);

  return UserProfileNotifier(
    localStorageService: localStorageService,
    uuidService: uuidService,
  );
});

/// Helper provider to get current user UUID
final currentUserUuidProvider = FutureProvider<String?>((ref) async {
  final userState = ref.watch(userProfileProvider);
  return userState.whenData((profile) => profile?.uuid).value;
});

/// Helper provider to check if user has completed onboarding
final userOnboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final localStorageService = ref.watch(localStorageServiceProvider);
  return await localStorageService.hasCompletedOnboarding();
});

/// Helper provider to update onboarding status
final updateUserOnboardingProvider = FutureProvider.family<void, bool>((ref, isComplete) async {
  final localStorageService = ref.watch(localStorageServiceProvider);
  await localStorageService.setOnboardingComplete(isComplete);
});
