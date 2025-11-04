import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodiehub/utils/image_utils.dart';
import 'package:foodiehub/widgets/simple_image_loader.dart';

/// A reliable image widget that handles network errors gracefully
class ReliableImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String category;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ReliableImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.category = 'general',
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final reliableUrl = ImageUtils.getFoodImageUrl(
      imageUrl,
      category: category,
    );

    Widget imageWidget = CachedNetworkImage(
      imageUrl: reliableUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildDefaultErrorWidget(),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildDefaultPlaceholder() {
    return SimpleLoaders.auto(width: width, height: height, category: category);
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconByCategory(),
            size: (height != null && height! > 100) ? 32 : 24,
            color: Colors.grey[600],
          ),
          if (height != null && height! > 60) ...[
            const SizedBox(height: 4),
            Text(
              _getTextByCategory(),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIconByCategory() {
    switch (category.toLowerCase()) {
      case 'pizza':
      case 'pizzas':
        return Icons.local_pizza;
      case 'burger':
      case 'burgers':
        return Icons.lunch_dining;
      case 'dessert':
      case 'desserts':
      case 'sweet':
      case 'cake':
        return Icons.cake;
      case 'beverage':
      case 'beverages':
      case 'drink':
      case 'drinks':
        return Icons.local_drink;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.fastfood;
    }
  }

  String _getTextByCategory() {
    switch (category.toLowerCase()) {
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
        return 'Food';
    }
  }
}

/// A reliable restaurant image widget
class ReliableRestaurantImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ReliableRestaurantImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final reliableUrl = ImageUtils.getRestaurantImageUrl(imageUrl);

    Widget imageWidget = CachedNetworkImage(
      imageUrl: reliableUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => SimpleLoaders.auto(
        width: width,
        height: height,
        category: 'restaurant',
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: (height != null && height! > 100) ? 48 : 32,
              color: Colors.grey[600],
            ),
            if (height != null && height! > 80) ...[
              const SizedBox(height: 8),
              Text(
                'Restaurant',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }
}
