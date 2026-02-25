import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/providers/index.dart';

/// Home Screen - Main feed showing personalized recommendations
/// Primary landing screen after onboarding
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // BYPASS: Watch all schemes directly instead of recommendations
    final allSchemes = ref.watch(schemesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Schemes For You'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Theme toggle
          IconButton(
            icon: Icon(
              ref.watch(isDarkModeProvider) ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              final currentMode = ref.read(themeProvider).whenData((m) => m).value;
              if (currentMode != null) {
                final newMode = currentMode == AppThemeMode.dark
                    ? AppThemeMode.light
                    : AppThemeMode.dark;
                ref.read(themeProvider.notifier).setThemeMode(newMode);
              }
            },
          ),
        ],
      ),
      body: allSchemes.when(
        // Data loaded - show all schemes directly
        data: (schemes) {
          if (schemes.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: schemes.length,
            itemBuilder: (context, index) {
              final scheme = schemes[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(scheme.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${scheme.categoryName} • ${scheme.stateName}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    print('Tapped: ${scheme.title}');
                  },
                ),
              );
            },
          );
        },
        // Still loading
        loading: () => Center(
          child: CircularProgressIndicator(),
        ),
        // Error occurred
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Error loading schemes: $error'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(schemesProvider);
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/search');
        },
        child: Icon(Icons.search),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.of(context).pushNamed('/saved');
              break;
            case 2:
              Navigator.of(context).pushNamed('/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildGreetingSection(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return userProfile.whenData((profile) {
      final greeting = profile != null
          ? 'Hello, ${profile.gender ?? 'there'}!'
          : 'Welcome!';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text(
            'Here are schemes tailored for you',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    }).value ?? SizedBox.shrink();
  }

  Widget _buildCategorySection(
    BuildContext context,
    String categoryName,
    List<dynamic> schemes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoryName,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 12),
        ...schemes.map((scheme) {
          return _buildSchemeCard(context, scheme);
        }).toList(),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSchemeCard(BuildContext context, dynamic scheme) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          scheme.title ?? 'Unknown Scheme',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              scheme.description ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(scheme.stateName ?? 'Central'),
                ),
                SizedBox(width: 8),
                Chip(
                  label: Text(scheme.categoryName ?? 'Other'),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.of(context).pushNamed(
            '/scheme-details',
            arguments: scheme.id,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Schemes Found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            'Try updating your profile for better recommendations',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
            child: Text('Update Profile'),
          ),
        ],
      ),
    );
  }
}

enum ChipSize { small, medium, large }
