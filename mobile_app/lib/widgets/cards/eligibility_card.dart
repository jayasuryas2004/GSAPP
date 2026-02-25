import 'package:flutter/material.dart';
import 'package:mobile_app/config/theme_config.dart';

/// Eligibility Card Widget
/// Shows eligibility criteria in structured format
class EligibilityCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isMet;

  const EligibilityCard({
    Key? key,
    required this.label,
    required this.value,
    this.isMet = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = isMet ? ThemeConfig.successColor : ThemeConfig.errorColor;
    
    return Container(
      padding: EdgeInsets.all(ThemeConfig.md),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(ThemeConfig.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: statusColor,
            size: 24,
          ),
          SizedBox(width: ThemeConfig.md),
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
        ],
      ),
    );
  }
}
