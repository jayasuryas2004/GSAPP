import 'package:flutter/material.dart';
import 'package:mobile_app/config/theme_config.dart';

/// Advanced Filter Dialog
/// Multi-filter selection dialog
class AdvancedFilterDialog extends StatefulWidget {
  final List<String> categories;
  final List<String> states;
  final String? selectedCategory;
  final String? selectedState;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const AdvancedFilterDialog({
    Key? key,
    required this.categories,
    required this.states,
    this.selectedCategory,
    this.selectedState,
    required this.onApply,
    required this.onClear,
  }) : super(key: key);

  @override
  State<AdvancedFilterDialog> createState() => _AdvancedFilterDialogState();
}

class _AdvancedFilterDialogState extends State<AdvancedFilterDialog> {
  late String? _selectedCategory;
  late String? _selectedState;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedState = widget.selectedState;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.radiusMd),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(ThemeConfig.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Advanced Filters',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ThemeConfig.lg),

              // Category Filter
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ThemeConfig.sm),
              DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                hint: Text('All Categories'),
                items: widget.categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
              ),
              SizedBox(height: ThemeConfig.lg),

              // State Filter
              Text(
                'State',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ThemeConfig.sm),
              DropdownButton<String>(
                value: _selectedState,
                isExpanded: true,
                hint: Text('All States'),
                items: widget.states.map((state) {
                  return DropdownMenuItem(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedState = value);
                },
              ),
              SizedBox(height: ThemeConfig.lg),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onClear();
                      },
                      child: Text('Clear'),
                    ),
                  ),
                  SizedBox(width: ThemeConfig.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onApply();
                      },
                      child: Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
