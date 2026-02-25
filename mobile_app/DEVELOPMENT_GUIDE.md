# 📚 SchemePlus Development Guide

## Code Organization & Best Practices

### 1. **File Naming Conventions**

```
Screens:           home_screen.dart, scheme_details_screen.dart
Widgets:           custom_button.dart, scheme_card.dart
Models:            user_profile_model.dart, scheme_model.dart
Services:          supabase_service.dart, local_storage_service.dart
Providers:         user_provider.dart, scheme_provider.dart
Extensions:        string_extensions.dart, date_extensions.dart
Utilities:         validators.dart, logger.dart
```

**Rule**: Always use `_screen.dart`, `_widget.dart`, `_model.dart`, `_service.dart`

---

### 2. **Import Organization**

```dart
// ✅ CORRECT ORDER
import 'package:flutter/material.dart';           // Flutter imports first
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:mobile_app/config/config.dart';   // App imports (organized alphabetically)
import 'package:mobile_app/models/models.dart';
import 'package:mobile_app/services/supabase_service.dart';
import 'package:mobile_app/widgets/common/custom_button.dart';

import '../models/scheme_model.dart';              // Relative imports (if in same package)
import '../widgets/scheme/scheme_card.dart';

// ✅ No blank lines between import groups!
```

---

### 3. **Const Convention**

```dart
// ✅ CORRECT - Use const for static values
class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);  // Always const constructor
  
  static const double padding = 16.0;
  static const Duration animDuration = Duration(milliseconds: 300);
}

// ❌ AVOID - Creating new objects in build()
class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),  // New object every build!
      child: Text('Hello'),
    );
  }
}

// ✅ CORRECT
const edgePadding = EdgeInsets.all(16.0);
```

---

### 4. **Naming Conventions**

```dart
// Variables & Functions (camelCase)
String firstName = 'John';
String lastName = 'Doe';
int userAge = 25;

void calculateTotal() {}
bool isUserEligible() {}
Future<void> fetchSchemes() async {}

// Constants (camelCase, usually in constants file)
const String appName = 'SchemePlus';
const double defaultPadding = 16.0;

// Private members (use underscore prefix)
class _MyPrivateClass {}
String _privateVariable = '';
void _privateMethod() {}

// Classes (PascalCase)
class UserProfile {}
class SchemeCard extends StatelessWidget {}

// Enums (PascalCase)
enum UserGender { male, female, other }
enum ApplicationStatus { open, closed, upcoming }
```

---

### 5. **Widget Structure**

```dart
/// ✅ PERFECT WIDGET STRUCTURE

class SchemeCard extends StatelessWidget {
  // 1️⃣ Constants at the top
  static const double _cardHeight = 120.0;
  static const double _borderRadius = 12.0;
  
  // 2️⃣ Properties
  final Scheme scheme;
  final VoidCallback onTap;
  final bool isBookmarked;
  
  // 3️⃣ Constructor (always const if possible)
  const SchemeCard({
    Key? key,
    required this.scheme,
    required this.onTap,
    this.isBookmarked = false,
  }) : super(key: key);
  
  // 4️⃣ Build method at the end
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          children: [
            _buildHeader(),
            _buildBody(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
  
  // 5️⃣ Helper methods (prefix with _)
  Widget _buildHeader() {
    return Row(
      children: [
        Text(scheme.title),
        if (scheme.isNew) const Badge(label: 'NEW'),
      ],
    );
  }
  
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(scheme.description),
    );
  }
  
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Match: ${calculateMatch()}%'),
        IconButton(
          icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
          onPressed: onTap,
        ),
      ],
    );
  }
  
  int calculateMatch() {
    // Implementation
    return 85;
  }
}
```

---

## State Management with Provider

### **User Profile Provider**

```dart
// ✅ providers/user_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/models/models.dart';
import 'package:mobile_app/services/local_storage_service.dart';

final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final storage = LocalStorageService();
  return await storage.getUserProfile();
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final LocalStorageService _storage;
  
  UserProfileNotifier(this._storage) : super(const AsyncValue.loading());
  
  Future<void> updateProfile(UserProfile profile) async {
    state = const AsyncValue.loading();
    try {
      await _storage.saveUserProfile(profile);
      state = AsyncValue.data(profile);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final userNotifierProvider = 
  StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile>>((ref) {
    final storage = LocalStorageService();
    return UserProfileNotifier(storage);
  });
```

### **Using Provider in Widget**

```dart
// ✅ schemes_screen.dart

class SchemesScreen extends ConsumerWidget {
  const SchemesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch user profile changes
    final userProfileAsync = ref.watch(userProfileProvider);
    
    // Watch recommended schemes
    final recommendedAsync = ref.watch(recommendedSchemesProvider);
    
    return userProfileAsync.when(
      loading: () => const LoadingSpinner(),
      error: (error, stackTrace) => ErrorWidget(error: error.toString()),
      data: (userProfile) {
        return recommendedAsync.when(
          loading: () => const LoadingSpinner(),
          error: (error, stackTrace) => ErrorWidget(error: error.toString()),
          data: (schemes) {
            return ListView(
              children: schemes
                  .map((scheme) => SchemeCard(scheme: scheme))
                  .toList(),
            );
          },
        );
      },
    );
  }
}
```

---

## Error Handling

### **Service Layer Error Handling**

```dart
// ✅ services/supabase_service.dart

class SupabaseService {
  Future<List<Scheme>> fetchSchemes() async {
    try {
      final response = await _supabase
          .from('schemes')
          .select()
          .timeout(const Duration(seconds: 30));
      
      return (response as List)
          .map((json) => Scheme.fromJson(json))
          .toList();
    } on SocketException catch (e) {
      throw AppException('No internet connection: $e');
    } on TimeoutException catch (e) {
      throw AppException('Request timeout: $e');
    } on PostgrestException catch (e) {
      throw AppException('Database error: ${e.message}');
    } catch (e) {
      throw AppException('Unexpected error: $e');
    }
  }
}

// Custom exception class
class AppException implements Exception {
  final String message;
  AppException(this.message);
  
  @override
  String toString() => message;
}
```

### **Widget Error Display**

```dart
// ✅ Using error display

class SchemesList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemesAsync = ref.watch(schemesProvider);
    
    return schemesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, st) => ErrorWidget(
        error: error.toString(),
        onRetry: () => ref.refresh(schemesProvider),
      ),
      data: (schemes) => ListView(
        children: schemes.map((s) => SchemeCard(scheme: s)).toList(),
      ),
    );
  }
}
```

---

## Testing Best Practices

```dart
// ✅ test/models/scheme_model_test.dart

void main() {
  group('Scheme Model', () {
    test('matchesProfile returns true for matching profile', () {
      final scheme = Scheme(
        id: '1',
        title: 'Test Scheme',
        description: 'Test',
        stateName: 'Tamil Nadu',
        categoryName: 'Agriculture',
        applyLink: 'https://example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        targetOccupation: ['Farmer'],
        targetGender: ['Any'],
      );
      
      final matches = scheme.matchesProfile(
        userGender: 'Male',
        userAge: 25,
        userState: 'Tamil Nadu',
        userOccupation: 'Farmer',
      );
      
      expect(matches, true);
    });
    
    test('calculateMatchScore returns correct score', () {
      final scheme = Scheme(
        // ... scheme setup
        targetOccupation: ['Farmer'],
        targetGender: ['Female'],
      );
      
      final score = scheme.calculateMatchScore(
        userGender: 'Female',
        userAge: 25,
        userState: 'Tamil Nadu',
        userOccupation: 'Farmer',
      );
      
      expect(score, greaterThan(50));
      expect(score, lessThanOrEqualTo(100));
    });
  });
}
```

---

## Logging & Debugging

```dart
// ✅ utils/helpers/logger.dart

class Logger {
  static void debug(String message) {
    if (kDebugMode) {
      print('🐛 DEBUG: $message');
    }
  }
  
  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️  INFO: $message');
    }
  }
  
  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️  WARNING: $message');
    }
  }
  
  static void error(String message, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
      if (stackTrace != null) print(stackTrace);
    }
  }
}

// Usage
Logger.debug('Fetching schemes...');
Logger.info('User profile loaded');
Logger.warning('Slow network detected');
Logger.error('Failed to fetch schemes', stackTrace);
```

---

## Performance Tips

### **1. Use ListView.builder for Long Lists**

```dart
// ❌ SLOW - Creates all items upfront
ListView(
  children: schemes.map((s) => SchemeCard(scheme: s)).toList(),
)

// ✅ FAST - Creates items on demand
ListView.builder(
  itemCount: schemes.length,
  itemBuilder: (context, index) => SchemeCard(scheme: schemes[index]),
)
```

### **2. Cache Images**

```dart
// ❌ SLOW - Downloads every time
Image.network(scheme.imageUrl)

// ✅ FAST - Uses cache
CachedNetworkImage(
  imageUrl: scheme.imageUrl,
  placeholder: (context, url) => const Skeleton(),
  errorWidget: (context, url, error) => const PlaceholderImage(),
)
```

### **3. Use const Widgets**

```dart
// ❌ REBUILDS - New object every time
Widget _buildButton() {
  return ElevatedButton(
    onPressed: () {},
    child: Text('Click me'),
  );
}

// ✅ OPTIMIZED - Reuses same widget
const _myButton = ElevatedButton(
  onPressed: null,
  child: Text('Click me'),
);
```

---

## Deployment Checklist

- [ ] All strings in `app_strings.dart`
- [ ] All colors in `theme_config.dart`
- [ ] All routes in `routes.dart`
- [ ] No hardcoded magic numbers
- [ ] No print() statements (use Logger)
- [ ] All error cases handled
- [ ] Loading states for all async operations
- [ ] Tests pass (flutter test)
- [ ] Code formatted (dart format lib/)
- [ ] No linting errors (dart analyze lib/)
- [ ] Offline mode tested
- [ ] Privacy policy added
- [ ] All permissions declared
- [ ] Version bumped in pubspec.yaml
- [ ] APK signed for release

---

**Version**: 1.0
**Last Updated**: February 2026
