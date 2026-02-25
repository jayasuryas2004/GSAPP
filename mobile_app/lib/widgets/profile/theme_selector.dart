import 'package:flutter/material.dart';
import 'package:mobile_app/providers/index.dart';
import 'package:mobile_app/config/theme_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme Selector Widget
/// Radio button selector for theme modes
class ThemeSelector extends ConsumerWidget {
  final AppThemeMode currentMode;
  final ValueChanged<AppThemeMode> onChanged;

  const ThemeSelector({
    Key? key,
    required this.currentMode,
    required this.onChanged,
  }) : super(key: key);

  String _getThemeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light Mode';
      case AppThemeMode.dark:
        return 'Dark Mode';
      case AppThemeMode.system:
        return 'System Default';
    }
  }

  IconData _getThemeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.settings;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: AppThemeMode.values.map((mode) {
        return ListTile(
          title: Text(_getThemeLabel(mode)),
          leading: Icon(_getThemeIcon(mode), color: ThemeConfig.primaryColor),
          trailing: Radio<AppThemeMode>(
            value: mode,
            groupValue: currentMode,
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConfig.radiusSm),
          ),
          onTap: () => onChanged(mode),
        );
      }).toList(),
    );
  }
}
