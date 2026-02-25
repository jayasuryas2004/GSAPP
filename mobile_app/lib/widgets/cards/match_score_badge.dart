import 'package:flutter/material.dart';
import 'package:mobile_app/config/theme_config.dart';

/// Match Score Badge Widget
/// Color-coded badge showing personalization score
class MatchScoreBadge extends StatelessWidget {
  final int score;
  final double size;

  const MatchScoreBadge({
    Key? key,
    required this.score,
    this.size = 60,
  }) : super(key: key);

  Color get _backgroundColor {
    if (score >= 80) return ThemeConfig.successColor;
    if (score >= 60) return ThemeConfig.warningColor;
    return ThemeConfig.errorColor;
  }

  String get _scoreLabel {
    if (score >= 80) return 'Perfect';
    if (score >= 60) return 'Good';
    return 'Fair';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: ThemeConfig.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$score%',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.35,
            ),
          ),
          Text(
            _scoreLabel,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
