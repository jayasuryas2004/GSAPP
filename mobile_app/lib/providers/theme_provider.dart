import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/services/local_storage_service.dart';

/// Theme mode enum
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Theme State Notifier - manages app theme
class ThemeNotifier extends StateNotifier<AsyncValue<AppThemeMode>> {
  final LocalStorageService localStorageService;

  ThemeNotifier({required this.localStorageService})
      : super(const AsyncValue.loading()) {
    _loadTheme();
  }

  /// Load theme from local storage
  Future<void> _loadTheme() async {
    try {
      state = const AsyncValue.loading();
      print('[INFO] Loading theme preference...');

      final themeMode = await localStorageService.getThemeMode();
      
      // Parse theme mode string to enum
      final mode = _parseThemeMode(themeMode);
      state = AsyncValue.data(mode);

      print('[INFO] Theme loaded: ${mode.toString().split('.').last}');
    } catch (error, _) {
      print('[ERROR] Failed to load theme: $error');
      // Default to system theme on error
      state = const AsyncValue.data(AppThemeMode.system);
    }
  }

  /// Parse theme mode string to enum
  AppThemeMode _parseThemeMode(String? themeStr) {
    if (themeStr == null) {
      return AppThemeMode.system;
    }

    switch (themeStr.toLowerCase()) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }

  /// Convert enum to string
  String _themeModeToString(AppThemeMode mode) {
    return mode.toString().split('.').last;
  }

  /// Set theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    try {
      state = const AsyncValue.loading();
      print('[INFO] Setting theme to: ${mode.toString().split(".").last}');

      // Save to local storage
      await localStorageService.setThemeMode(_themeModeToString(mode));

      // Update state
      state = AsyncValue.data(mode);
      print('[INFO] Theme updated successfully');
    } catch (error, stackTrace) {
      print('[ERROR] Failed to set theme: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    try {
      final currentMode = state.whenData((mode) => mode).value ?? AppThemeMode.system;
      
      final newMode = currentMode == AppThemeMode.light
          ? AppThemeMode.dark
          : AppThemeMode.light;

      await setThemeMode(newMode);
    } catch (error) {
      print('[ERROR] Failed to toggle theme: $error');
    }
  }

  /// Get Flutter ThemeMode from our AppThemeMode
  ThemeMode getFlutterThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Get theme description
  String getThemeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }
}

/// Provider for Local Storage Service (dependency)
final themeLocalStorageProvider = Provider((ref) {
  return LocalStorageService.getInstance();
});

/// Main Theme Provider
final themeProvider =
    StateNotifierProvider<ThemeNotifier, AsyncValue<AppThemeMode>>((ref) {
  final localStorageService = ref.watch(themeLocalStorageProvider);
  return ThemeNotifier(localStorageService: localStorageService);
});

/// Get current theme mode as string
final currentThemeModeStringProvider = Provider<String>((ref) {
  final theme = ref.watch(themeProvider);

  return theme.when(
    data: (mode) {
      switch (mode) {
        case AppThemeMode.light:
          return 'light';
        case AppThemeMode.dark:
          return 'dark';
        case AppThemeMode.system:
          return 'system';
      }
    },
    loading: () => 'system',
    error: (error, stack) => 'system',
  );
});

/// Get Flutter ThemeMode for MaterialApp
final flutterThemeModeProvider = Provider<ThemeMode>((ref) {
  final theme = ref.watch(themeProvider);

  return theme.when(
    data: (mode) {
      switch (mode) {
        case AppThemeMode.light:
          return ThemeMode.light;
        case AppThemeMode.dark:
          return ThemeMode.dark;
        case AppThemeMode.system:
          return ThemeMode.system;
      }
    },
    loading: () => ThemeMode.system,
    error: (error, stack) => ThemeMode.system,
  );
});

/// Check if dark mode is enabled
final isDarkModeProvider = Provider<bool>((ref) {
  final theme = ref.watch(themeProvider);

  return theme.when(
    data: (mode) => mode == AppThemeMode.dark,
    loading: () => false,
    error: (error, stack) => false,
  );
});

/// Helper provider to check if theme is system
final isSystemThemeProvider = Provider<bool>((ref) {
  final theme = ref.watch(themeProvider);

  return theme.when(
    data: (mode) => mode == AppThemeMode.system,
    loading: () => true,
    error: (error, stack) => true,
  );
});

/// Get theme description
final themeDescriptionProvider = Provider<String>((ref) {
  final theme = ref.watch(themeProvider);

  return theme.when(
    data: (mode) {
      switch (mode) {
        case AppThemeMode.light:
          return 'Light Mode';
        case AppThemeMode.dark:
          return 'Dark Mode';
        case AppThemeMode.system:
          return 'System Theme';
      }
    },
    loading: () => 'Loading...',
    error: (error, stack) => 'System Theme',
  );
});
