import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/providers/index.dart';
import 'package:mobile_app/screens/index.dart';
import 'package:mobile_app/config/theme_config.dart';
import 'package:mobile_app/services/supabase_service.dart';
import 'package:mobile_app/services/local_storage_service.dart';

void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize LocalStorage FIRST before any other services
    print('[INFO] 🔄 Initializing local storage...');
    final localStorage = LocalStorageService.getInstance();
    await localStorage.initialize();
    print('[INFO] ✅ Local storage initialized successfully');
    
    // Initialize Supabase after local storage
    print('[INFO] 🔄 Initializing Supabase...');
    await SupabaseService.initialize();
    print('[INFO] ✅ Supabase initialized successfully');
  } catch (e) {
    print('[ERROR] ❌ Failed to initialize services: $e');
    rethrow;
  }
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode
    final themeMode = ref.watch(flutterThemeModeProvider);

    return MaterialApp(
      title: 'Government Schemes',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: themeMode,

      // Navigation and routing
      home: const SplashScreen(),
      routes: _buildRoutes(),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/splash': (_) => const SplashScreen(),
      '/onboarding': (_) => const OnboardingScreen(),
      '/home': (_) => const HomeScreen(),
      '/search': (_) => const SearchScreen(),
      '/saved': (_) => const SavedSchemesScreen(),
      '/profile': (_) => const ProfileScreen(),
      '/settings': (_) => const SettingsScreen(),
      '/scheme-details': (context) {
        // Get scheme ID from route arguments
        final schemeId = ModalRoute.of(context)?.settings.arguments as String?;
        if (schemeId != null) {
          return SchemeDetailsScreen(schemeId: schemeId);
        }
        return const HomeScreen();
      },
    };
  }
}

