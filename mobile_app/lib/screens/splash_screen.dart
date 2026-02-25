import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/providers/index.dart';
import 'package:mobile_app/models/models.dart';

/// Splash Screen - Initial loading screen
/// Checks onboarding status and initializes app state
class SplashScreen extends ConsumerWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch onboarding status
    final onboardingComplete = ref.watch(userOnboardingCompleteProvider);

    // BYPASS FOR TESTING: Force skip onboarding and go to home with auto-profile
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Create default user profile for testing
      final defaultProfile = UserProfile(
        uuid: 'test-user-12345',
        gender: 'Male',
        age: 28,
        state: 'Tamil Nadu',
        occupation: 'Student',
      );
      
      // Update user profile (save to local storage)
      await ref.read(userProfileProvider.notifier).updateUserProfile(defaultProfile);
      
      // Navigate to home immediately
      Navigator.of(context).pushReplacementNamed('/home');
    });

    return onboardingComplete.when(
      // Data loaded - check if can navigate
      data: (isComplete) {
        // Already handled above via WidgetsBinding
        return _buildLoadingUI();
      },
      // Still loading
      loading: () => _buildLoadingUI(),
      // Error occurred
      error: (error, stack) {
        print('[ERROR] Splash screen error: $error');
        return _buildLoadingUI();
      },
    );
  }

  Widget _buildLoadingUI() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[700]!, Colors.blue[900]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo / Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.policy,
                  size: 60,
                  color: Colors.blue[700],
                ),
              ),
              SizedBox(height: 30),
              
              // App Name
              Text(
                'Government Schemes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              SizedBox(height: 10),
              
              // Tagline
              Text(
                'Discover Benefits You Deserve',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              
              SizedBox(height: 50),
              
              // Loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              
              SizedBox(height: 20),
              
              // Loading text
              Text(
                'Initializing...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
