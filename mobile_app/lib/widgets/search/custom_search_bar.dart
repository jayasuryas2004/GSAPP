import 'package:flutter/material.dart';
import 'package:mobile_app/config/theme_config.dart';

/// Custom Search Bar Widget
/// Search input with clear button and filter support
class CustomSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final IconData icon;

  const CustomSearchBar({
    Key? key,
    required this.onChanged,
    this.onClear,
    this.hintText = 'Search schemes...',
    this.icon = Icons.search,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusMd),
        border: Border.all(color: ThemeConfig.borderColor),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ThemeConfig.md,
          vertical: ThemeConfig.sm,
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: ThemeConfig.textSecondary),
            SizedBox(width: ThemeConfig.md),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: widget.onChanged,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  widget.onChanged('');
                  widget.onClear?.call();
                },
                child: Icon(
                  Icons.clear,
                  color: ThemeConfig.textSecondary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
