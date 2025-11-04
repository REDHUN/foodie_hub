/// Utility class for handling image URLs and fallbacks
class ImageUtils {
  // Reliable fallback images from different sources
  static const String _defaultRestaurantImage =
      'https://via.placeholder.com/400x200/ff6b6b/ffffff?text=Restaurant';
  static const String _defaultFoodImage =
      'https://via.placeholder.com/300x200/4ecdc4/ffffff?text=Food';
  static const String _defaultPizzaImage =
      'https://via.placeholder.com/300x200/e74c3c/ffffff?text=Pizza';
  static const String _defaultBurgerImage =
      'https://via.placeholder.com/300x200/f39c12/ffffff?text=Burger';
  static const String _defaultDessertImage =
      'https://via.placeholder.com/300x200/9b59b6/ffffff?text=Dessert';
  static const String _defaultBeverageImage =
      'https://via.placeholder.com/300x200/3498db/ffffff?text=Beverage';

  /// Get a reliable restaurant image URL with fallback
  static String getRestaurantImageUrl(String? originalUrl) {
    if (originalUrl == null || originalUrl.isEmpty) {
      return _defaultRestaurantImage;
    }

    // If it's already a placeholder or reliable URL, return as is
    if (originalUrl.contains('placeholder.com') ||
        originalUrl.contains('picsum.photos')) {
      return originalUrl;
    }

    // For Unsplash URLs, try to fix common issues
    if (originalUrl.contains('unsplash.com')) {
      // Remove query parameters that might cause issues
      final uri = Uri.parse(originalUrl);
      final cleanUrl = '${uri.scheme}://${uri.host}${uri.path}';
      return '$cleanUrl?auto=format&fit=crop&w=400&h=200&q=80';
    }

    return originalUrl;
  }

  /// Get a reliable food image URL with fallback based on category
  static String getFoodImageUrl(
    String? originalUrl, {
    String category = 'general',
  }) {
    if (originalUrl == null || originalUrl.isEmpty) {
      return _getFallbackImageByCategory(category);
    }

    // If it's already a placeholder or reliable URL, return as is
    if (originalUrl.contains('placeholder.com') ||
        originalUrl.contains('picsum.photos')) {
      return originalUrl;
    }

    // For Unsplash URLs, try to fix common issues
    if (originalUrl.contains('unsplash.com')) {
      // Remove query parameters that might cause issues
      final uri = Uri.parse(originalUrl);
      final cleanUrl = '${uri.scheme}://${uri.host}${uri.path}';
      return '$cleanUrl?auto=format&fit=crop&w=300&h=200&q=80';
    }

    return originalUrl;
  }

  /// Get fallback image based on food category
  static String _getFallbackImageByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'pizza':
      case 'pizzas':
        return _defaultPizzaImage;
      case 'burger':
      case 'burgers':
        return _defaultBurgerImage;
      case 'dessert':
      case 'desserts':
      case 'sweet':
      case 'cake':
        return _defaultDessertImage;
      case 'beverage':
      case 'beverages':
      case 'drink':
      case 'drinks':
        return _defaultBeverageImage;
      default:
        return _defaultFoodImage;
    }
  }

  /// Generate a reliable Picsum image URL
  static String getPicsumImageUrl({
    required String seed,
    int width = 300,
    int height = 200,
  }) {
    return 'https://picsum.photos/seed/$seed/$width/$height';
  }

  /// Generate a placeholder image URL with custom text and colors
  static String getPlaceholderImageUrl({
    required String text,
    int width = 300,
    int height = 200,
    String backgroundColor = 'cccccc',
    String textColor = 'ffffff',
  }) {
    return 'https://via.placeholder.com/${width}x$height/$backgroundColor/$textColor?text=${Uri.encodeComponent(text)}';
  }

  /// List of reliable restaurant image URLs
  static List<String> getReliableRestaurantImages() {
    return [
      getPicsumImageUrl(seed: 'restaurant1', width: 400, height: 200),
      getPicsumImageUrl(seed: 'restaurant2', width: 400, height: 200),
      getPicsumImageUrl(seed: 'restaurant3', width: 400, height: 200),
      getPicsumImageUrl(seed: 'restaurant4', width: 400, height: 200),
      getPicsumImageUrl(seed: 'restaurant5', width: 400, height: 200),
      getPicsumImageUrl(seed: 'food1', width: 400, height: 200),
      getPicsumImageUrl(seed: 'food2', width: 400, height: 200),
      getPicsumImageUrl(seed: 'food3', width: 400, height: 200),
      getPicsumImageUrl(seed: 'food4', width: 400, height: 200),
      getPicsumImageUrl(seed: 'food5', width: 400, height: 200),
    ];
  }

  /// List of reliable food image URLs by category
  static List<String> getReliableFoodImages(String category) {
    final seed = category.toLowerCase();
    return [
      getPicsumImageUrl(seed: '${seed}1', width: 300, height: 200),
      getPicsumImageUrl(seed: '${seed}2', width: 300, height: 200),
      getPicsumImageUrl(seed: '${seed}3', width: 300, height: 200),
      getPicsumImageUrl(seed: '${seed}4', width: 300, height: 200),
      getPicsumImageUrl(seed: '${seed}5', width: 300, height: 200),
    ];
  }
}
