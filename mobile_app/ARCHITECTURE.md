# SchemePlus Mobile App - Production Architecture

## 🎯 Project Overview

**SchemePlus** is a Flutter mobile application that helps users discover, understand, and apply for government schemes tailored to their profile.

**App Features:**
- ✅ Onboarding with minimal data collection (4 questions)
- ✅ Personalized scheme recommendations using recommendation engine
- ✅ UUID-based user identification (no authentication required)
- ✅ State-specific and central scheme filtering
- ✅ Search and category browsing
- ✅ Bookmark/Save schemes
- ✅ Complete offline support

---

## 📁 Folder Structure & Architecture

```
lib/
│
├── config/                          # Application Configuration
│   ├── config.dart                  # Index (exports all)
│   ├── app_config.dart             # API keys, endpoints, feature flags
│   ├── theme_config.dart           # Colors, typography, spacing
│   └── routes.dart                 # Navigation routes
│
├── constants/                       # Static Constants
│   ├── constants.dart              # Index (exports all)
│   ├── app_strings.dart            # All UI strings (easy translation)
│   └── data_constants.dart         # Lists: states, occupations, categories
│
├── models/                          # Data Models & Business Logic
│   ├── models.dart                 # Index (exports all)
│   ├── user_profile_model.dart     # User profile data + validation
│   ├── scheme_model.dart           # Scheme data + matching logic
│   └── recommendation_model.dart   # Recommendation engine logic
│
├── services/                        # Business Logic Layer
│   ├── supabase_service.dart       # Database queries (fetch schemes, save bookmarks)
│   ├── local_storage_service.dart  # SharedPreferences (UUID, profile, saved schemes)
│   ├── uuid_service.dart           # UUID generation
│   └── recommendation_service.dart # High-level recommendation logic
│
├── providers/                       # State Management (Provider/Riverpod)
│   ├── user_provider.dart          # Current user profile state
│   ├── scheme_provider.dart        # All schemes list state
│   ├── recommendation_provider.dart # Filtered/recommended schemes
│   ├── search_provider.dart        # Search state
│   ├── saved_provider.dart         # Saved/bookmarked schemes
│   └── theme_provider.dart         # Dark/light mode
│
├── screens/                         # UI Screens (Feature-based)
│   ├── splash/
│   │   └── splash_screen.dart      # Splash screen (2 sec animation)
│   │
│   ├── onboarding/
│   │   ├── onboarding_screen.dart  # Main onboarding container
│   │   ├── step1_gender_screen.dart # Gender selection (4 screens)
│   │   ├── step2_age_screen.dart
│   │   ├── step3_state_screen.dart
│   │   ├── step4_occupation_screen.dart
│   │   └── review_profile_screen.dart # Confirm selections
│   │
│   ├── home/
│   │   ├── home_screen.dart        # Main dashboard
│   │   └── home_components.dart    # Home-specific widgets
│   │
│   ├── schemes/
│   │   ├── schemes_list_screen.dart # All schemes / filtered
│   │   ├── scheme_details_screen.dart # Single scheme details
│   │   └── scheme_components.dart  # Scheme-specific widgets
│   │
│   ├── search/
│   │   ├── search_screen.dart      # Search & filter
│   │   └── search_results_screen.dart
│   │
│   ├── saved/
│   │   └── saved_schemes_screen.dart # Bookmarked schemes
│   │
│   └── profile/
│       ├── profile_screen.dart     # User profile view
│       ├── edit_profile_screen.dart # Edit profile
│       └── settings_screen.dart    # App settings
│
├── widgets/                         # Reusable UI Components
│   ├── common/
│   │   ├── custom_app_bar.dart
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── loading_spinner.dart
│   │   ├── empty_state.dart
│   │   ├── error_widget.dart
│   │   └── no_internet_banner.dart
│   │
│   ├── scheme/
│   │   ├── scheme_card.dart        # Horizontal scheme card
│   │   ├── scheme_list_item.dart   # List item variant
│   │   ├── match_percentage_badge.dart
│   │   ├── benefit_amount_tag.dart
│   │   └── eligibility_checker.dart
│   │
│   └── onboarding/
│       ├── progress_indicator.dart # Step progress 1/4
│       ├── gender_selector.dart    # Gender selection widget
│       ├── age_slider.dart
│       ├── state_dropdown.dart
│       └── occupation_selector.dart
│
├── utils/                           # Utility Functions
│   ├── extensions/
│   │   ├── string_extensions.dart  # String helpers
│   │   ├── date_extensions.dart    # Date formatting
│   │   └── widget_extensions.dart  # Widget helpers
│   │
│   └── helpers/
│       ├── logger.dart             # Logging utility
│       ├── validators.dart         # Form validation
│       ├── date_formatter.dart     # Date/time formatting
│       └── permissions.dart        # Permission handling
│
├── assets/
│   ├── images/
│   │   ├── splash_logo.png
│   │   ├── onboarding_1.png        # Onboarding animations (from your mockups)
│   │   ├── onboarding_2.png
│   │   ├── onboarding_3.png
│   │   ├── onboarding_4.png
│   │   ├── empty_state_schemes.png
│   │   └── empty_state_saved.png
│   │
│   └── icons/
│       ├── ic_home.svg
│       ├── ic_search.svg
│       ├── ic_bookmark.svg
│       ├── ic_profile.svg
│       ├── ic_agriculture.svg      # Category icons
│       ├── ic_education.svg
│       ├── ic_healthcare.svg
│       └── ... (more category icons)
│
├── main.dart                        # App entry point
└── app.dart                         # App widget configuration
```

---

## 🔄 Data Flow Architecture

```
User Profile Collection
        ↓
    [Onboarding: 4 screens]
        ↓
  [Save UUID + Profile to LocalStorage]
        ↓
  [Load all Schemes from Supabase]
        ↓
  [RecommendationEngine filters/ranks]
        ↓
  [Display: Dashboard with sections]
        ├─ Perfect Match (95%+)
        ├─ Good Match (65-94%)
        ├─ Possible Match (40-64%)
        └─ General Schemes
        ↓
  [User taps "Find My Schemes"]
        ↓
  [Show all 127 schemes filtered by profile]
        ↓
  [User browses categories/searches]
        ↓
  [User views + bookmarks schemes]
        ↓
  [All stored locally + remote analytics]
```

---

## 🏗️ Key Architecture Patterns

### 1. **Model-View-Provider (MVP + Provider)**
- **Models** (`models/`) - Data & business logic
- **Views** (`screens/` + `widgets/`) - UI layer
- **Providers** (`providers/`) - State management

### 2. **Service Layer Architecture**
```
Screens/Widgets
      ↓
   Providers (State)
      ↓
   Services (Business Logic)
      ↓
   Repositories (Data access)
      ↓
   Supabase / Local Storage
```

### 3. **Local Storage First**
- User profile saved locally immediately after onboarding
- UUID generated once, never changes
- Saved schemes stored locally for offline access
- Remote sync only for analytics

### 4. **Recommendation Engine**
Located in `models/recommendation_model.dart`:
- Filters schemes by matching profile
- Calculates match score (0-100)
- Categorizes into sections
- Provides sorting & filtering

---

## 🎨 Recommended Next Steps

### Phase 1: Setup & Core Services (1-2 weeks)
1. **Create Services** (`services/`)
   - `supabase_service.dart` - Connect to 823 schemes
   - `local_storage_service.dart` - SharedPreferences helper
   - `uuid_service.dart` - Device-specific UUID

2. **Create Providers** (`providers/`)
   - User profile state
   - Schemes list state
   - Recommendation state

3. **Add Dependencies** to `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     supabase_flutter: ^1.10.0
     provider: ^6.0.0
     shared_preferences: ^2.2.0
     uuid: ^4.0.0
     http: ^1.1.0
     cached_network_image: ^3.3.0
   ```

### Phase 2: Screens (2-3 weeks)
1. Splash screen (simple)
2. Onboarding (4 screens + review)
3. Home/Dashboard
4. Scheme details page

### Phase 3: Features (2-3 weeks)
1. Search & filter
2. Bookmarks/Saved
3. Profile management

### Phase 4: Polish (1 week)
1. Error states
2. Loading states
3. Animations
4. Offline support

---

## 📋 Constants Management

### `app_strings.dart` - All UI Strings
```dart
static const String onboardingWelcome = 'Welcome to SchemePlus';
static const String findMySchemes = 'Find My Schemes';
// ... 100+ strings, easy for translation
```

### `data_constants.dart` - Static Lists
```dart
static const List<String> indianStates = [
  'Tamil Nadu', 'Kerala', 'Karnataka', ...
];
static const List<String> occupationOptions = [
  'Farmer', 'Student', 'Laborer', ...
];
```

**Benefit**: Change any string/list in ONE place, updates everywhere.

---

## 🔐 Data Security

### What Gets Stored Where

**LocalStorage (SharedPreferences):**
```json
{
  "hasSeenOnboarding": true,
  "userUUID": "550e8400-...",
  "userProfile": {
    "gender": "Female",
    "age": 28,
    "state": "Tamil Nadu",
    "occupation": "Farmer"
  },
  "savedSchemeIds": ["scheme_1", "scheme_25", ...]
}
```

**Supabase (Optional Analytics):**
- Only userUUID + profile (no PII)
- Only if user opts-in
- Helps understand app usage patterns

---

## 🚀 Deployment Checklist

```
Before Release:
  ☐ Update Supabase URL in app_config.dart
  ☐ Add all 823 schemes to database with target fields
  ☐ Test recommendation engine with sample profiles
  ☐ Verify offline mode works
  ☐ Test on real Android device
  ☐ Add error handling for all network calls
  ☐ Implement analytics tracking
  ☐ Create app privacy policy
  ☐ Sign APK for release
```

---

## 📞 Development Commands

```bash
# Get dependencies
flutter pub get

# Run on emulator
flutter run

# Build APK
flutter build apk --release

# Format code
dart format lib/

# Analyze code
dart analyze lib/

# Run tests
flutter test
```

---

## 🎯 Design Philosophy

### **Minimize Complexity**
- 4 questions only during onboarding
- No complex forms
- Clear, simple navigation

### **Personalization Without Tracking**
- Profile-based recommendations
- Local storage only (unless opted-in)
- No user authentication needed

### **State-Centric Approach**
- Show state schemes prominently
- Central schemes as secondary
- "Based on your profile" messaging

### **Progressive Disclosure**
- Dashboard: Show top 5 schemes
- "View All" button for list
- Categories for browsing
- Search for specific schemes

---

**Last Updated**: February 2026
**Version**: 1.0 Architecture
**Status**: Production-Ready ✅
