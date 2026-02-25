import 'package:flutter/material.dart';
import 'package:mobile_app/models/models.dart';
import 'package:mobile_app/config/theme_config.dart';

/// Reusable Scheme Card Widget
/// Displays scheme info in a card format with match score and actions
class SchemeCard extends StatelessWidget {
  final Scheme scheme;
  final int? matchScore;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback? onSave;

  const SchemeCard({
    Key? key,
    required this.scheme,
    this.matchScore,
    this.isSaved = false,
    required this.onTap,
    this.onSave,
  }) : super(key: key);

  Color _getScoreColor(int score) {
    if (score >= 80) return ThemeConfig.successColor;
    if (score >= 60) return ThemeConfig.warningColor;
    return ThemeConfig.errorColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: ThemeConfig.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.radiusMd),
        ),
        child: Padding(
          padding: EdgeInsets.all(ThemeConfig.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title and Match Score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      scheme.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (matchScore != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ThemeConfig.sm,
                        vertical: ThemeConfig.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(matchScore!),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$matchScore%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: ThemeConfig.sm),

              // Description
              Text(
                scheme.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: ThemeConfig.md),

              // Category and State
              Wrap(
                spacing: ThemeConfig.sm,
                children: [
                  Chip(
                    label: Text(scheme.categoryName),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text(scheme.stateName),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              SizedBox(height: ThemeConfig.md),

              // Save Button
              if (onSave != null)
                ElevatedButton.icon(
                  onPressed: onSave,
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_outline),
                  label: Text(isSaved ? 'Saved' : 'Save Scheme'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
