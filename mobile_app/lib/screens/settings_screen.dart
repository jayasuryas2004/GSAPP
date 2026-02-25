import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/providers/index.dart';

/// Settings Screen - App settings and preferences
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionTitle(context, 'Appearance'),
          
          // Theme Settings
          themeMode.whenData((mode) {
            return ListTile(
              leading: Icon(Icons.palette),
              title: Text('Theme'),
              subtitle: _getThemeName(mode),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                _showThemeDialog(context, ref, mode);
              },
            );
          }).value ?? ListTile(
            leading: Icon(Icons.palette),
            title: Text('Theme'),
            subtitle: Text('Loading...'),
          ),

          Divider(),

          SizedBox(height: 16),

          _buildSectionTitle(context, 'Data & Privacy'),

          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Clear Saved Schemes'),
            subtitle: Text(ref.watch(savedCountProvider).toString() + ' schemes saved'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showClearSavedDialog(context, ref);
            },
          ),

          Divider(),

          SizedBox(height: 16),

          _buildSectionTitle(context, 'About'),

          ListTile(
            leading: Icon(Icons.info),
            title: Text('App Version'),
            subtitle: Text('1.0.0'),
          ),

          ListTile(
            leading: Icon(Icons.language),
            title: Text('Available Languages'),
            subtitle: Text('English, Tamil'),
          ),

          Divider(),

          SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () {
              _showAboutDialog(context);
            },
            icon: Icon(Icons.help),
            label: Text('Help & Support'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Text('Light Mode');
      case AppThemeMode.dark:
        return Text('Dark Mode');
      case AppThemeMode.system:
        return Text('System Default');
    }
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode currentMode,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AppThemeMode>(
              title: Text('Light Mode'),
              value: AppThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<AppThemeMode>(
              title: Text('Dark Mode'),
              value: AppThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<AppThemeMode>(
              title: Text('System Default'),
              value: AppThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearSavedDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Saved Schemes?'),
        content: Text('This will remove all saved schemes. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(savedSchemeIdsProvider.notifier).clearAllSaved();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Saved schemes cleared')),
              );
            },
            child: Text('Clear'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About Government Schemes'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Discover Government Benefits',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                'This app helps you find and apply for government schemes that match your profile. '
                'Get personalized recommendations based on your demographics and interests.',
              ),
              SizedBox(height: 16),
              Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              bulletPoint('Personalized Recommendations'),
              bulletPoint('Search & Filter Schemes'),
              bulletPoint('Save Favorite Schemes'),
              bulletPoint('Easy Application Links'),
              SizedBox(height: 16),
              Text(
                'Version: 1.0.0',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget bulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
