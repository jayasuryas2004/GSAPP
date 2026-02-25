import 'package:flutter/material.dart';
import 'package:mobile_app/config/theme_config.dart';

/// Category/State Dropdown Selector
/// Custom dropdown with styling
class FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final IconData icon;

  const FilterDropdown({
    Key? key,
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
    this.icon = Icons.filter_list,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: ThemeConfig.textSecondary,
          ),
        ),
        SizedBox(height: ThemeConfig.sm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: ThemeConfig.borderColor),
            borderRadius: BorderRadius.circular(ThemeConfig.radiusSm),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: ThemeConfig.md),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: SizedBox.shrink(),
              hint: Text('Select $label'),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
