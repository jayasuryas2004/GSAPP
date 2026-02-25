import 'package:flutter/material.dart';
import 'package:mobile_app/config/theme_config.dart';

/// Loading Shimmer Widget
/// Skeleton loader for content placeholders
class LoadingShimmer extends StatefulWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const LoadingShimmer({
    Key? key,
    this.height = 20,
    this.width,
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                ThemeConfig.borderColor,
                ThemeConfig.surfaceColor,
                ThemeConfig.borderColor,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Loading Shimmer List Widget
/// Multiple shimmer loaders for list placeholders
class LoadingShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets padding;

  const LoadingShimmerList({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: ThemeConfig.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LoadingShimmer(height: 20, width: 200),
              SizedBox(height: ThemeConfig.sm),
              LoadingShimmer(height: itemHeight - 20),
            ],
          ),
        );
      },
    );
  }
}
