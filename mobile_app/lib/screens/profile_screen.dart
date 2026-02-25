import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/providers/index.dart';

/// Profile Screen - User profile management
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch user profile
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: userProfile.when(
        data: (profile) {
          if (profile == null) {
            return Center(child: Text('No profile found'));
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Profile header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'User ID: ${profile.uuid}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Profile information
              _buildProfileField(
                context,
                'Gender',
                profile.gender ?? 'Not specified',
                () => _editField(context, 'gender', profile.gender),
              ),

              _buildProfileField(
                context,
                'Age',
                profile.age?.toString() ?? 'Not specified',
                () => _editField(context, 'age', profile.age?.toString()),
              ),

              _buildProfileField(
                context,
                'State',
                profile.state ?? 'Not specified',
                () => _editField(context, 'state', profile.state),
              ),

              _buildProfileField(
                context,
                'Occupation',
                profile.occupation ?? 'Not specified',
                () => _editField(context, 'occupation', profile.occupation),
              ),

              SizedBox(height: 32),

              // Settings section
              Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              SizedBox(height: 16),

              // Theme toggle
              ListTile(
                leading: Icon(Icons.palette),
                title: Text('Theme'),
                trailing: ref.watch(themeProvider).whenData((mode) {
                  return DropdownButton<AppThemeMode>(
                    value: mode,
                    items: [
                      DropdownMenuItem(
                        value: AppThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: AppThemeMode.dark,
                        child: Text('Dark'),
                      ),
                      DropdownMenuItem(
                        value: AppThemeMode.system,
                        child: Text('System'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(themeProvider.notifier).setThemeMode(value);
                      }
                    },
                  );
                }).value ?? SizedBox.shrink(),
              ),

              Divider(),

              // Logout button
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: Icon(Icons.logout),
                label: Text('Clear Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading profile'),
        ),
      ),
    );
  }

  Widget _buildProfileField(
    BuildContext context,
    String label,
    String value,
    VoidCallback onEdit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            IconButton(
              icon: Icon(Icons.edit, size: 18),
              onPressed: onEdit,
            ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  void _editField(BuildContext context, String field, String? currentValue) {
    final controller = TextEditingController(text: currentValue ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${field[0].toUpperCase()}${field.substring(1)}'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $field',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(userProfileProvider.notifier)
                  .updateProfileField(field, controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$field updated')),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Profile?'),
        content: Text('This will remove all your profile data and reset the app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(userProfileProvider.notifier).clearProfile();
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed('/splash');
            },
            child: Text('Clear'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
