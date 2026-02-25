import 'package:flutter/material.dart';
import 'package:mobile_app/config/theme_config.dart';

/// Filter Chip Widget
/// Selectable chip for filters with active state
class FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  const FilterChip({
    Key? key,
    required this.label,
    this.isSelected = false,
    required this.onSelected,
    this.icon,
  }) : super(key: key);

  @override
  State<FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<FilterChip> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onSelected(!widget.isSelected),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ThemeConfig.md,
          vertical: ThemeConfig.sm,
        ),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? ThemeConfig.primaryColor
              : ThemeConfig.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isSelected
                ? ThemeConfig.primaryColor
                : ThemeConfig.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 16,
                color: widget.isSelected ? Colors.white : ThemeConfig.textSecondary,
              ),
              SizedBox(width: ThemeConfig.xs),
            ],
            Text(
              widget.label,
              style: TextStyle(
                color: widget.isSelected ? Colors.white : ThemeConfig.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
