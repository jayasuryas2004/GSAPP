import 'package:flutter/material.dart';
import 'package:mobile_app/config/theme_config.dart';

/// Benefit Card Widget
/// Displays individual benefits in an attractive card
class BenefitCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? color;

  const BenefitCard({
    Key? key,
    required this.title,
    required this.description,
    this.icon = Icons.star,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? ThemeConfig.primaryLight;
    
    return Container(
      padding: EdgeInsets.all(ThemeConfig.md),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.1),
        border: Border.all(color: bgColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(ThemeConfig.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ThemeConfig.sm),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(ThemeConfig.radiusSm),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              SizedBox(width: ThemeConfig.md),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: bgColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ThemeConfig.sm),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
