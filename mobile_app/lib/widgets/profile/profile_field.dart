import 'package:flutter/material.dart';
import 'package:mobile_app/config/theme_config.dart';

/// Read-only Profile Field Widget
/// Displays profile information
class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const ProfileField({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ThemeConfig.sm),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: ThemeConfig.primaryColor, size: 20),
            SizedBox(width: ThemeConfig.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ThemeConfig.textSecondary,
                  ),
                ),
                SizedBox(height: ThemeConfig.xs),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
