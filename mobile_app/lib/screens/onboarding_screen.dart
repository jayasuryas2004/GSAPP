import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/providers/index.dart';
import 'package:mobile_app/models/models.dart';

/// Onboarding Screen - Collect user profile information
/// Guides new users through setup
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  // Form data
  String? selectedGender;
  int? selectedAge;
  String? selectedState;
  String? selectedOccupation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      // Get user UUID first
      final userUuid = await ref.read(currentUserUuidProvider.future);
      
      if (userUuid != null) {
        // Create user profile with collected data
        final profile = UserProfile(
          uuid: userUuid,
          gender: selectedGender,
          age: selectedAge,
          state: selectedState,
          occupation: selectedOccupation,
        );

        // Update profile in provider
        await ref.read(userProfileProvider.notifier).updateUserProfile(profile);

        // Mark onboarding as complete
        await ref.read(updateUserOnboardingProvider(true).future);

        // Navigate to home
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (error) {
      print('[ERROR] Onboarding completion failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Setup failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (_currentPage + 1) / 4,
              minHeight: 4,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildGenderPage(),
                  _buildAgePage(),
                  _buildStatePage(),
                  _buildOccupationPage(),
                ],
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _currentPage > 0 ? _previousPage : null,
                    icon: Icon(Icons.arrow_back),
                    label: Text('Previous'),
                  ),
                  Text(
                    'Step ${_currentPage + 1}/4',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _nextPage,
                    label: Text(_currentPage == 3 ? 'Complete' : 'Next'),
                    icon: Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderPage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64, color: Colors.blue),
            SizedBox(height: 24),
            Text(
              'What is your gender?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 32),
            ..._genderOptions().map((option) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() => selectedGender = value);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAgePage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cake, size: 64, color: Colors.blue),
            SizedBox(height: 24),
            Text(
              'What is your age?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 32),
            Slider(
              value: (selectedAge ?? 25).toDouble(),
              min: 18,
              max: 80,
              divisions: 62,
              label: selectedAge?.toString() ?? '25',
              onChanged: (value) {
                setState(() => selectedAge = value.toInt());
              },
            ),
            SizedBox(height: 16),
            Text(
              'Selected Age: ${selectedAge ?? 25}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatePage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 64, color: Colors.blue),
            SizedBox(height: 24),
            Text(
              'Which state are you in?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 32),
            DropdownButton<String>(
              value: selectedState,
              hint: Text('Select your state'),
              isExpanded: true,
              items: _stateOptions().map((state) {
                return DropdownMenuItem(
                  value: state,
                  child: Text(state),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedState = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupationPage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work, size: 64, color: Colors.blue),
            SizedBox(height: 24),
            Text(
              'What is your occupation?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 32),
            DropdownButton<String>(
              value: selectedOccupation,
              hint: Text('Select your occupation'),
              isExpanded: true,
              items: _occupationOptions().map((occupation) {
                return DropdownMenuItem(
                  value: occupation,
                  child: Text(occupation),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedOccupation = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  List<String> _genderOptions() => ['Male', 'Female', 'Other', 'Prefer Not to Say'];
  List<String> _stateOptions() => [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
    'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
    'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
    'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
    'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  ];
  List<String> _occupationOptions() => [
    'Student', 'Employed', 'Self-Employed', 'Farmer', 'Retired',
    'Homemaker', 'Unemployed', 'Other',
  ];
}
