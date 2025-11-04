import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodiehub/models/restaurant.dart';
import 'package:foodiehub/screens/restaurant_detail_screen.dart';
import 'package:foodiehub/utils/constants.dart';
import 'package:foodiehub/widgets/reliable_image.dart';
import 'package:foodiehub/widgets/shimmer_loading.dart';
import 'package:foodiehub/widgets/star_rating.dart';

class CategoryRestaurantsScreen extends StatefulWidget {
  final String category;
  final List<Restaurant> restaurants;

  const CategoryRestaurantsScreen({
    super.key,
    required this.category,
    required this.restaurants,
  });

  @override
  State<CategoryRestaurantsScreen> createState() =>
      _CategoryRestaurantsScreenState();
}

class _CategoryRestaurantsScreenState extends State<CategoryRestaurantsScreen> {
  String _selectedSortBy = 'Relevance';
  bool _showOffersOnly = false;
  double _minRating = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredRestaurants = _applyFilters(widget.restaurants);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: Column(
        children: [
          // Filter section - Sticky
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${filteredRestaurants.length} restaurants serving ${widget.category}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFilterChips(),
              ],
            ),
          ),
          // Restaurant list
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return ShimmerLoading(
                        isLoading: true,
                        child: const FullRestaurantCardShimmer(),
                      );
                    },
                  )
                : filteredRestaurants.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _refreshRestaurants,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredRestaurants.length,
                      itemBuilder: (context, index) {
                        return _buildRestaurantCard(filteredRestaurants[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final hasActiveFilters =
        _selectedSortBy != 'Relevance' || _showOffersOnly || _minRating > 0;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildSortByChip(),
          const SizedBox(width: 8),
          _buildOffersChip(),
          const SizedBox(width: 8),
          _buildRatingsChip(),
          if (hasActiveFilters) ...[
            const SizedBox(width: 8),
            _buildClearAllChip(),
          ],
        ],
      ),
    );
  }

  Widget _buildSortByChip() {
    return GestureDetector(
      onTap: () => _showSortByBottomSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
          color: _selectedSortBy != 'Relevance'
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort By',
              style: TextStyle(
                fontSize: 12,
                color: _selectedSortBy != 'Relevance'
                    ? AppColors.primaryColor
                    : Colors.black,
                fontWeight: _selectedSortBy != 'Relevance'
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: _selectedSortBy != 'Relevance'
                  ? AppColors.primaryColor
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersChip() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showOffersOnly = !_showOffersOnly;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: _showOffersOnly ? AppColors.primaryColor : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20),
          color: _showOffersOnly
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_offer,
              size: 14,
              color: _showOffersOnly ? AppColors.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              'Offers',
              style: TextStyle(
                fontSize: 12,
                color: _showOffersOnly ? AppColors.primaryColor : Colors.black,
                fontWeight: _showOffersOnly
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsChip() {
    return GestureDetector(
      onTap: () => _showRatingsBottomSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: _minRating > 0 ? AppColors.primaryColor : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20),
          color: _minRating > 0
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              size: 14,
              color: _minRating > 0 ? AppColors.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              _minRating > 0
                  ? 'Ratings ${_minRating.toStringAsFixed(1)}+'
                  : 'Ratings',
              style: TextStyle(
                fontSize: 12,
                color: _minRating > 0 ? AppColors.primaryColor : Colors.black,
                fontWeight: _minRating > 0
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearAllChip() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSortBy = 'Relevance';
          _showOffersOnly = false;
          _minRating = 0.0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red[300]!),
          borderRadius: BorderRadius.circular(20),
          color: Colors.red[50],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.clear, size: 14, color: Colors.red[600]),
            const SizedBox(width: 4),
            Text(
              'Clear All',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RestaurantDetailScreen(restaurant: restaurant),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  ReliableRestaurantImage(
                    imageUrl: restaurant.image,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                  if (restaurant.discount != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          restaurant.discount!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StarRating(rating: restaurant.rating, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${restaurant.rating}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.deliveryTime,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    restaurant.cuisine,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.delivery_dining,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '₹${restaurant.deliveryFee} delivery fee',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No restaurants found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or check back later',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Restaurant> _applyFilters(List<Restaurant> restaurants) {
    List<Restaurant> filtered = List.from(restaurants);

    // Apply offers filter
    if (_showOffersOnly) {
      filtered = filtered
          .where((r) => r.discount != null && r.discount!.isNotEmpty)
          .toList();
    }

    // Apply rating filter
    if (_minRating > 0) {
      filtered = filtered.where((r) => r.rating >= _minRating).toList();
    }

    // Apply sorting
    switch (_selectedSortBy) {
      case 'Rating: High to Low':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Delivery Time':
        filtered.sort((a, b) {
          final timeA =
              int.tryParse(a.deliveryTime.replaceAll(RegExp(r'[^0-9]'), '')) ??
              60;
          final timeB =
              int.tryParse(b.deliveryTime.replaceAll(RegExp(r'[^0-9]'), '')) ??
              60;
          return timeA.compareTo(timeB);
        });
        break;
      case 'Cost: Low to High':
        filtered.sort((a, b) => a.deliveryFee.compareTo(b.deliveryFee));
        break;
      case 'Cost: High to Low':
        filtered.sort((a, b) => b.deliveryFee.compareTo(a.deliveryFee));
        break;
      default:
        // Keep original order for 'Relevance'
        break;
    }

    return filtered;
  }

  void _showSortByBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...[
                'Relevance',
                'Rating: High to Low',
                'Delivery Time',
                'Cost: Low to High',
                'Cost: High to Low',
              ].map(
                (option) => ListTile(
                  title: Text(option),
                  trailing: _selectedSortBy == option
                      ? const Icon(Icons.check, color: AppColors.primaryColor)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedSortBy = option;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRatingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Rating',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...[0.0, 3.0, 3.5, 4.0, 4.5].map(
                (rating) => ListTile(
                  title: Text(
                    rating == 0.0
                        ? 'Any Rating'
                        : '${rating.toStringAsFixed(1)}+ Stars',
                  ),
                  trailing: _minRating == rating
                      ? const Icon(Icons.check, color: AppColors.primaryColor)
                      : null,
                  onTap: () {
                    setState(() {
                      _minRating = rating;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _refreshRestaurants() async {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Simulate refresh delay
      setState(() {
        _isLoading = true;
      });

      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Add success haptic feedback
      HapticFeedback.selectionClick();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.category} restaurants refreshed! 🍽️'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      // Add error haptic feedback
      HapticFeedback.heavyImpact();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: $error'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
