import 'package:flutter/material.dart';
import 'package:mobile_app/config/theme_config.dart';

/// Empty State Widget
/// Shows when no items are available with call-to-action
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyState({
    Key? key,
    this.icon = Icons.inbox,
    this.title = 'No Items',
    this.subtitle = 'Get started by adding your first item',
    this.actionLabel,
    this.onAction,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(ThemeConfig.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 80,
                color: iconColor ?? ThemeConfig.primaryLight.withOpacity(0.5),
              ),
              SizedBox(height: ThemeConfig.lg),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ThemeConfig.sm),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                SizedBox(height: ThemeConfig.lg),
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: Icon(Icons.add),
                  label: Text(actionLabel!),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: ThemeConfig.lg,
                      vertical: ThemeConfig.md,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
