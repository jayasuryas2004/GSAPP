import 'package:flutter/material.dart';
import 'package:mobile_app/config/theme_config.dart';

/// Editable Profile Field Widget
/// Shows field with edit dialog
class EditableProfileField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;
  final IconData icon;

  const EditableProfileField({
    Key? key,
    required this.label,
    required this.value,
    required this.onEdit,
    this.icon = Icons.edit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ThemeConfig.md),
      decoration: BoxDecoration(
        border: Border.all(color: ThemeConfig.borderColor),
        borderRadius: BorderRadius.circular(ThemeConfig.radiusSm),
      ),
      child: Row(
        children: [
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: Icon(icon),
            color: ThemeConfig.primaryColor,
          ),
        ],
      ),
    );
  }
}
