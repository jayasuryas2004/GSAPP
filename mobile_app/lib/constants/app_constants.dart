/// ============================================================================
/// APP CONFIGURATION & CONSTANTS
/// ============================================================================
/// 
/// This file contains all configuration settings for the GSAPP application.
/// These are constants that don't change during app runtime.
///
/// IMPORTANT: Add your Supabase credentials here!
/// ============================================================================

// ============================================================================
// SUPABASE CONFIGURATION
// ============================================================================
/// 
/// Supabase is your backend database system.
/// These credentials connect your Flutter app to the 823 government schemes.
///
/// WHERE TO GET THESE:
/// 1. Go to: https://app.supabase.com
/// 2. Click your project
/// 3. Go to: Settings → API
/// 4. Copy the values below
///

class SupabaseConfig {
  /// YOUR SUPABASE PROJECT URL
  /// Example: https://xyzabc.supabase.co
  /// This is where your database lives
  static const String supabaseUrl = 'YOUR_SUPABASE_URL'; // Change this!

  /// YOUR SUPABASE ANON KEY
  /// This is the public key for mobile app (read-only, safe to expose)
  /// Used to fetch schemes from database
  /// RLS policies prevent users from modifying data
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'; // Change this!

  /// VERIFY CREDENTIALS ARE SET
  /// These checks run when app starts
  static bool isConfigured() {
    return !supabaseUrl.startsWith('YOUR_') && !supabaseAnonKey.startsWith('YOUR_');
  }

  /// Status message for debugging
  static String getStatus() {
    if (!isConfigured()) {
      return '⚠️  WARNING: Supabase credentials not configured!';
    }
    return '✅ Supabase configured correctly';
  }
}

// ============================================================================
// APP THEME & COLORS
// ============================================================================
///
/// These colors define the look and feel of your app
///

class AppColors {
  // Primary colors (for buttons, headers)
  static const int primaryColor = 0xFF1F77B4;      // Blue
  static const int secondaryColor = 0xFF2CA02C;    // Green
  
  // Text colors
  static const int textPrimary = 0xFF212121;       // Dark gray
  static const int textSecondary = 0xFF757575;     // Medium gray
  static const int textLight = 0xFFBDBDBD;         // Light gray
  
  // Background colors
  static const int bgWhite = 0xFFFFFFFF;           // White
  static const int bgLight = 0xFFF5F5F5;           // Light gray background
  
  // Status colors
  static const int successGreen = 0xFF4CAF50;      // Success
  static const int errorRed = 0xFFE53935;          // Error
  static const int warningOrange = 0xFFFB8C00;     // Warning
}

// ============================================================================
// APP TEXT STRINGS
// ============================================================================
///
/// Centralize all app text here for easy translation later
///

class AppStrings {
  // App name
  static const String appName = 'GSAPP';
  static const String appSubtitle = 'Government Schemes';
  
  // Screen titles
  static const String homeTitle = 'Government Schemes';
  static const String searchTitle = 'Search Schemes';
  static const String detailsTitle = 'Scheme Details';
  static const String savedSchemesTitle = 'My Saved Schemes';
  static const String settingsTitle = 'Settings';
  
  // Common buttons
  static const String btnApplyNow = 'Apply Now';
  static const String btnSave = 'Save Scheme';
  static const String btnRemove = 'Remove';
  static const String btnSearch = 'Search';
  static const String btnFilter = 'Filter';
  static const String btnRetry = 'Retry';
  static const String btnOk = 'OK';
  static const String btnCancel = 'Cancel';
  
  // Loading & Error
  static const String loading = 'Loading...';
  static const String noResults = 'No schemes found';
  static const String noSavedSchemes = 'You haven\'t saved any schemes yet';
  static const String error = 'Something went wrong';
  static const String errorLoadingSchemes = 'Error loading schemes. Please retry.';
  
  // Filter labels
  static const String filterByState = 'Filter by State';
  static const String filterByCategory = 'Filter by Category';
  static const String allStates = 'All States';
  static const String allCategories = 'All Categories';
  
  // Settings
  static const String preferredState = 'Preferred State';
  static const String preferredLanguage = 'Preferred Language';
  static const String language = 'Language';
  static const String english = 'English';
  static const String tamil = 'Tamil';
}

// ============================================================================
// APP SETTINGS & DEFAULTS
// ============================================================================
///
/// Default app configurations
///

class AppSettings {
  // Number of schemes per page (for pagination)
  static const int schemesPerPage = 20;
  
  // API timeout in seconds
  static const int apiTimeoutSeconds = 30;
  
  // Cache duration in hours
  // (how long to keep schemes in memory before refreshing)
  static const int cacheDurationHours = 24;
  
  // Default state for filtering
  static const String defaultState = 'Central';
  
  // Default language
  static const String defaultLanguage = 'en'; // 'en' for English, 'ta' for Tamil
  
  // Enable logging for debugging
  static const bool debugLogging = true;
}

// ============================================================================
// DATABASE QUERIES
// ============================================================================
///
/// SQL-like queries we'll use to fetch data from Supabase
/// These are pre-written patterns for common operations
///

class QueryPatterns {
  // Fetch all schemes
  static const String getAllSchemes = 'SELECT * FROM schemes ORDER BY created_at DESC';
  
  // Fetch schemes by state
  static const String getSchemesByState = 'SELECT * FROM schemes WHERE state_name = \'STATE_NAME\'';
  
  // Fetch schemes by category
  static const String getSchemesByCategory = 'SELECT * FROM schemes WHERE category_name = \'CATEGORY_NAME\'';
  
  // Search schemes
  static const String searchSchemes = 'SELECT * FROM schemes WHERE title ILIKE \'%SEARCH_TERM%\' OR description ILIKE \'%SEARCH_TERM%\'';
}

// ============================================================================
// LOG MESSAGES
// ============================================================================
///
/// Debug messages for development
///

class LogMessages {
  static const String appStarted = '✅ App started';
  static const String supabaseInitialized = '✅ Supabase initialized';
  static const String schemesLoaded = '✅ Schemes loaded';
  static const String schemeSaved = '✅ Scheme saved to wishlist';
  static const String schemeRemoved = '✅ Scheme removed from wishlist';
  static const String preferencesSaved = '✅ Preferences saved';
}

// ============================================================================
// VALIDATION RULES
// ============================================================================
///
/// Rules for validating user input
///

class ValidationRules {
  // Minimum search query length
  static const int minSearchLength = 2;
  
  // Maximum search results to show
  static const int maxSearchResults = 100;
}

// ============================================================================
// ENDPOINT CONFIGURATION
// ============================================================================
///
/// API endpoints (for future use if needed)
///

class Endpoints {
  // Supabase REST API base URL (auto-configured in SupabaseService)
  static String getSupabaseApiUrl(String projectUrl) {
    return '$projectUrl/rest/v1';
  }
}

// ============================================================================
// USAGE GUIDE
// ============================================================================
/// 
/// HOW TO USE THESE CONSTANTS:
///
/// 1. SUPABASE CREDENTIALS (MOST IMPORTANT):
///    - Go to app_constants.dart
///    - Find: SupabaseConfig.supabaseUrl
///    - Replace 'YOUR_SUPABASE_URL' with your actual URL
///    - Find: SupabaseConfig.supabaseAnonKey
///    - Replace 'YOUR_SUPABASE_ANON_KEY' with your actual key
///
/// 2. IN OTHER FILES, USE LIKE THIS:
///    - AppString.appName → "GSAPP"
///    - AppColors.primaryColor → Blue color code
///    - AppSettings.cacheDurationHours → 24
///
/// 3. TO CHANGE APP TEXT:
///    - Edit strings in AppStrings class
///    - All screens automatically use new text
///
/// 4. TO CHANGE COLORS:
///    - Edit colors in AppColors class
///    - Entire app theme updates
///
