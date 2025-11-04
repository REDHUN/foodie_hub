import 'package:flutter/material.dart';
import 'package:foodiehub/utils/constants.dart';

/// Simple and beautiful image loader
class SimpleImageLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final Color? color;
  final String? category;

  const SimpleImageLoader({
    super.key,
    this.width,
    this.height,
    this.color,
    this.category,
  });

  @override
  State<SimpleImageLoader> createState() => _SimpleImageLoaderState();
}

class _SimpleImageLoaderState extends State<SimpleImageLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primaryColor;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Center(
            child: Opacity(
              opacity: _animation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIconByCategory(),
                    size: _getIconSize(),
                    color: color.withValues(alpha: 0.6),
                  ),
                  if (_shouldShowText()) ...[
                    const SizedBox(height: 8),
                    Text(
                      _getTextByCategory(),
                      style: TextStyle(
                        fontSize: 12,
                        color: color.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconByCategory() {
    switch (widget.category?.toLowerCase()) {
      case 'pizza':
      case 'pizzas':
        return Icons.local_pizza_outlined;
      case 'burger':
      case 'burgers':
        return Icons.lunch_dining_outlined;
      case 'dessert':
      case 'desserts':
      case 'sweet':
      case 'cake':
        return Icons.cake_outlined;
      case 'beverage':
      case 'beverages':
      case 'drink':
      case 'drinks':
        return Icons.local_drink_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      default:
        return Icons.image_outlined;
    }
  }

  String _getTextByCategory() {
    switch (widget.category?.toLowerCase()) {
      case 'pizza':
      case 'pizzas':
        return 'Pizza';
      case 'burger':
      case 'burgers':
        return 'Burger';
      case 'dessert':
      case 'desserts':
      case 'sweet':
      case 'cake':
        return 'Dessert';
      case 'beverage':
      case 'beverages':
      case 'drink':
      case 'drinks':
        return 'Beverage';
      case 'restaurant':
        return 'Restaurant';
      default:
        return 'Loading...';
    }
  }

  double _getIconSize() {
    if (widget.width != null && widget.height != null) {
      final minDimension = widget.width! < widget.height!
          ? widget.width!
          : widget.height!;
      if (minDimension < 60) return 20;
      if (minDimension < 100) return 28;
      if (minDimension < 150) return 36;
      return 48;
    }
    return 32;
  }

  bool _shouldShowText() {
    if (widget.height == null) return true;
    return widget.height! > 60;
  }
}

/// Simple shimmer loader for larger images
class SimpleShimmerLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final Color? baseColor;
  final Color? highlightColor;

  const SimpleShimmerLoader({
    super.key,
    this.width,
    this.height,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<SimpleShimmerLoader> createState() => _SimpleShimmerLoaderState();
}

class _SimpleShimmerLoaderState extends State<SimpleShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey[200]!;
    final highlightColor = widget.highlightColor ?? Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Quick access methods for simple loaders
class SimpleLoaders {
  /// Simple icon-based loader with gentle pulse animation
  static Widget icon({
    double? width,
    double? height,
    Color? color,
    String? category,
  }) {
    return SimpleImageLoader(
      width: width,
      height: height,
      color: color,
      category: category,
    );
  }

  /// Simple shimmer loader for larger images
  static Widget shimmer({
    double? width,
    double? height,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return SimpleShimmerLoader(
      width: width,
      height: height,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  /// Auto-select appropriate loader based on size
  static Widget auto({
    double? width,
    double? height,
    Color? color,
    String? category,
  }) {
    // Use shimmer for large images, icon loader for smaller ones
    if (width != null && height != null && (width > 150 || height > 150)) {
      return shimmer(width: width, height: height);
    }
    return icon(width: width, height: height, color: color, category: category);
  }
}
