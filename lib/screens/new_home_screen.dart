import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodiehub/models/restaurant.dart';
import 'package:foodiehub/providers/auth_provider.dart';
import 'package:foodiehub/providers/menu_cart_provider.dart';
import 'package:foodiehub/providers/restaurant_provider.dart';
import 'package:foodiehub/screens/cart_screen.dart';
import 'package:foodiehub/screens/category_restaurants_screen.dart';
import 'package:foodiehub/screens/owner_dashboard_screen.dart';
import 'package:foodiehub/screens/owner_login_screen.dart';
import 'package:foodiehub/screens/restaurant_detail_screen.dart';
import 'package:foodiehub/screens/search_screen.dart';
import 'package:foodiehub/utils/constants.dart';
import 'package:foodiehub/widgets/back_to_top_button.dart';
import 'package:foodiehub/widgets/featured_deals.dart';
import 'package:foodiehub/widgets/promotional_banner.dart';
import 'package:foodiehub/widgets/shimmer_loading.dart';
import 'package:foodiehub/widgets/star_rating.dart';
import 'package:provider/provider.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  // Filter state variables
  String _selectedSortBy = 'Relevance';
  bool _showOffersOnly = false;
  double _minRating = 0.0;
  double _maxPrice = 1000.0;
  bool _fastDeliveryOnly = false;

  // Scroll controller for back to top functionality
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    // Load restaurants from Firebase on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(
        context,
        listen: false,
      ).initializeRestaurants();
    });

    // Add scroll listener for back to top button
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= 200) {
      if (!_showBackToTop) {
        setState(() {
          _showBackToTop = true;
        });
      }
    } else {
      if (_showBackToTop) {
        setState(() {
          _showBackToTop = false;
        });
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _refreshData() async {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Show loading state and refresh data
      final restaurantProvider = Provider.of<RestaurantProvider>(
        context,
        listen: false,
      );

      // Force reload restaurants from Firebase
      await restaurantProvider.loadRestaurants();

      // Add success haptic feedback
      HapticFeedback.selectionClick();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Refreshed successfully! 🎉'),
            duration: Duration(seconds: 2),
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
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _refreshData,
            ),
          ),
        );
      }
    }
  }

  String _getOwnerInitials(String? email) {
    if (email == null || email.isEmpty) {
      return 'ME';
    }
    final localPart = email.split('@').first;
    if (localPart.length >= 2) {
      return localPart.substring(0, 2).toUpperCase();
    }
    return localPart.toUpperCase();
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: BackToTopButton(
        onPressed: _scrollToTop,
        isVisible: _showBackToTop,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header and Search Bar
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
              child: Column(
                children: [
                  // Top Header
                  _buildHeader(context),
                  // Search Bar - Always visible
                  _buildSearchBar(context),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Promotional Banners
                      Consumer<RestaurantProvider>(
                        builder: (context, restaurantProvider, child) {
                          final isLoading =
                              restaurantProvider.restaurants.isEmpty;
                          return isLoading
                              ? ShimmerLoading(
                                  isLoading: true,
                                  child: const PromoBannerShimmer(),
                                )
                              : PromotionalBanner(
                                  banners: samplePromoBanners,
                                  height: 180,
                                );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Animated Promo Section
                      const SizedBox(height: 20),
                      // Categories Section
                      Consumer<RestaurantProvider>(
                        builder: (context, restaurantProvider, child) {
                          final isLoading =
                              restaurantProvider.restaurants.isEmpty;
                          return isLoading
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ShimmerLoading(
                                        isLoading: true,
                                        child: const ShimmerBox(
                                          width: 200,
                                          height: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        height: 120,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: 8,
                                          itemBuilder: (context, index) {
                                            return ShimmerLoading(
                                              isLoading: true,
                                              child:
                                                  const CategoryItemShimmer(),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : _buildCategoriesSection();
                        },
                      ),
                      const SizedBox(height: 30),
                      // Top-rated Section
                      _buildTopRatedSection(context),
                      const SizedBox(height: 10),
                      // Featured Deals
                      Consumer<RestaurantProvider>(
                        builder: (context, restaurantProvider, child) {
                          final isLoading =
                              restaurantProvider.restaurants.isEmpty;
                          return isLoading
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: ShimmerLoading(
                                        isLoading: true,
                                        child: const ShimmerBox(
                                          width: 150,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 200,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        itemCount: 3,
                                        itemBuilder: (context, index) {
                                          return ShimmerLoading(
                                            isLoading: true,
                                            child: const FeaturedDealShimmer(),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : FeaturedDeals(deals: sampleFeaturedDeals);
                        },
                      ),
                      const SizedBox(height: 20),
                      // All Restaurants Section
                      //  const AnimatedPromoSection(),
                      // const SizedBox(height: 20),
                      _buildAllRestaurantsSection(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.home, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 20),
                  ],
                ),
                Text(
                  'Muhamma, Alappuzha',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final isAuthenticated = auth.isAuthenticated;
              final initials = _getOwnerInitials(auth.user?.email);
              return Tooltip(
                message: isAuthenticated
                    ? 'Manage restaurant'
                    : 'Restaurant owner login',
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => isAuthenticated
                            ? const OwnerDashboardScreen()
                            : const OwnerLoginScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isAuthenticated
                          ? AppColors.darkColor
                          : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isAuthenticated
                          ? Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Icon(
                              Icons.person_outline,
                              color: AppColors.darkColor,
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            child: Consumer<MenuCartProvider>(
              builder: (context, cart, child) {
                return Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shopping_bag,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _navigateToSearch();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.primaryColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search for restaurants and food',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.mic, color: AppColors.primaryColor, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "What's on your mind?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryItem(
                'Biryani',
                'https://images.unsplash.com/photo-1563379091339-03246963d51a?w=200',
                const Color(0xFFFF6B6B),
                'Biryani',
              ),
              _buildCategoryItem(
                'Pizza',
                'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200',
                const Color(0xFFFFD93D),
                'Pizza',
              ),
              _buildCategoryItem(
                'Burgers',
                'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=200',
                const Color(0xFF6BCF7F),
                'Burgers',
              ),
              _buildCategoryItem(
                'Desserts',
                'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=200',
                const Color(0xFFFF8A65),
                'Desserts',
              ),
              _buildCategoryItem(
                'Chinese',
                'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=200',
                const Color(0xFF4ECDC4),
                'Chinese',
              ),
              _buildCategoryItem(
                'Sushi',
                'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=200',
                const Color(0xFF45B7D1),
                'Sushi',
              ),
              _buildCategoryItem(
                'Ice Cream',
                'https://images.unsplash.com/photo-1567206563064-6f60f40a2b57?w=200',
                const Color(0xFFBA68C8),
                'Ice Cream',
              ),
              _buildCategoryItem(
                'Coffee',
                'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=200',
                const Color(0xFF8D6E63),
                'Coffee',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    String name,
    String imageUrl,
    Color backgroundColor,
    String cuisine,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _navigateToCategoryRestaurants(cuisine);
        },
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: backgroundColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: backgroundColor.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            backgroundColor.withValues(alpha: 0.8),
                            backgroundColor.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: backgroundColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(name),
                          size: 32,
                          color: backgroundColor,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: backgroundColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(name),
                          size: 32,
                          color: backgroundColor,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'biryani':
        return Icons.rice_bowl;
      case 'pizza':
        return Icons.local_pizza;
      case 'burgers':
        return Icons.lunch_dining;
      case 'desserts':
        return Icons.cake;
      case 'chinese':
        return Icons.restaurant;
      case 'sushi':
        return Icons.set_meal;
      case 'ice cream':
        return Icons.icecream;
      case 'coffee':
        return Icons.coffee;
      default:
        return Icons.restaurant;
    }
  }

  void _navigateToCategoryRestaurants(String cuisine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryRestaurantsScreen(
          category: cuisine,
          restaurants: _getRestaurantsByCategory(cuisine),
        ),
      ),
    );
  }

  List<Restaurant> _getRestaurantsByCategory(String category) {
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );
    final allRestaurants = restaurantProvider.restaurants.isNotEmpty
        ? restaurantProvider.restaurants
        : sampleRestaurants;

    return allRestaurants.where((restaurant) {
      final cuisine = restaurant.cuisine.toLowerCase();
      final categoryLower = category.toLowerCase();

      // Enhanced matching logic for better category filtering
      switch (categoryLower) {
        case 'biryani':
          return cuisine.contains('biryani') ||
              cuisine.contains('mughlai') ||
              cuisine.contains('persian');
        case 'pizza':
          return cuisine.contains('pizza') || cuisine.contains('italian');
        case 'burgers':
          return cuisine.contains('burger') ||
              cuisine.contains('american') ||
              cuisine.contains('fast food');
        case 'desserts':
          return cuisine.contains('dessert') ||
              cuisine.contains('cake') ||
              cuisine.contains('ice cream') ||
              cuisine.contains('sweet') ||
              cuisine.contains('bakery');
        case 'chinese':
          return cuisine.contains('chinese') ||
              cuisine.contains('noodles') ||
              cuisine.contains('asian');
        case 'sushi':
          return cuisine.contains('sushi') || cuisine.contains('japanese');
        case 'ice cream':
          return cuisine.contains('ice cream') || cuisine.contains('dessert');
        case 'coffee':
          return cuisine.contains('coffee') ||
              cuisine.contains('beverages') ||
              cuisine.contains('cafe');
        default:
          return cuisine.contains(categoryLower);
      }
    }).toList();
  }

  Widget _buildTopRatedSection(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, restaurantProvider, child) {
        final isLoading = restaurantProvider.restaurants.isEmpty;
        final restaurants = restaurantProvider.restaurants.isNotEmpty
            ? restaurantProvider.restaurants
            : sampleRestaurants;
        final topRestaurants = restaurants.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Top-rated near you',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: isLoading
                  ? ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: List.generate(
                        3,
                        (index) => ShimmerLoading(
                          isLoading: true,
                          child: const RestaurantCardShimmer(),
                        ),
                      ),
                    )
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: topRestaurants.map((restaurant) {
                        return _buildRestaurantCard(context, restaurant);
                      }).toList(),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAllRestaurantsSection(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, restaurantProvider, child) {
        final allRestaurants = restaurantProvider.restaurants.isNotEmpty
            ? restaurantProvider.restaurants
            : sampleRestaurants;

        // Apply filters
        final filteredRestaurants = _applyFilters(allRestaurants);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Restaurants',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Restaurants with online food delivery in Bangalore',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Filter Chips
            _buildFilterChips(),
            const SizedBox(height: 12),
            // Results counter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '${filteredRestaurants.length} restaurants found',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredRestaurants.length,
                itemBuilder: (context, index) {
                  return _buildFullRestaurantCard(
                    context,
                    filteredRestaurants[index],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChips() {
    final hasActiveFilters =
        _selectedSortBy != 'Relevance' ||
        _showOffersOnly ||
        _minRating > 0 ||
        _maxPrice < 1000 ||
        _fastDeliveryOnly;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildSortByChip(),
            const SizedBox(width: 8),
            _buildOffersChip(),
            const SizedBox(width: 8),
            _buildRatingsChip(),
            const SizedBox(width: 8),
            _buildPriceRangeChip(),
            const SizedBox(width: 8),
            _buildFastDeliveryChip(),
            if (hasActiveFilters) ...[
              const SizedBox(width: 8),
              _buildClearAllChip(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSortByChip() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showSortByBottomSheet();
      },
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
        HapticFeedback.lightImpact();
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
      onTap: () {
        HapticFeedback.lightImpact();
        _showRatingsBottomSheet();
      },
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

  Widget _buildPriceRangeChip() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showPriceRangeBottomSheet();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: _maxPrice < 1000
                ? AppColors.primaryColor
                : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20),
          color: _maxPrice < 1000
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _maxPrice < 1000 ? 'Rs. 0-${_maxPrice.toInt()}' : 'Rs. 0-1000+',
              style: TextStyle(
                fontSize: 12,
                color: _maxPrice < 1000 ? AppColors.primaryColor : Colors.black,
                fontWeight: _maxPrice < 1000
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFastDeliveryChip() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _fastDeliveryOnly = !_fastDeliveryOnly;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: _fastDeliveryOnly
                ? AppColors.primaryColor
                : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20),
          color: _fastDeliveryOnly
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.flash_on,
              size: 14,
              color: _fastDeliveryOnly ? AppColors.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              'Fast Delivery',
              style: TextStyle(
                fontSize: 12,
                color: _fastDeliveryOnly
                    ? AppColors.primaryColor
                    : Colors.black,
                fontWeight: _fastDeliveryOnly
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, Restaurant restaurant) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RestaurantDetailScreen(restaurant: restaurant),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: restaurant.image,
                    width: 160,
                    height: 140,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 160,
                      height: 140,
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 160,
                      height: 140,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
                if (restaurant.discount != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        restaurant.discount!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              restaurant.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                StarRating(rating: restaurant.rating, size: 10),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${restaurant.rating}',
                    style: const TextStyle(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    restaurant.deliveryTime,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              restaurant.cuisine,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullRestaurantCard(BuildContext context, Restaurant restaurant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RestaurantDetailScreen(restaurant: restaurant),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: restaurant.image,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
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
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          restaurant.discount!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StarRating(rating: restaurant.rating, size: 14),
                      Text(
                        '${restaurant.rating}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        restaurant.deliveryTime,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.cuisine,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${restaurant.deliveryFee} delivery fee',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
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
        HapticFeedback.lightImpact();
        setState(() {
          _selectedSortBy = 'Relevance';
          _showOffersOnly = false;
          _minRating = 0.0;
          _maxPrice = 1000.0;
          _fastDeliveryOnly = false;
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

  // Filter logic
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

    // Apply fast delivery filter (assuming delivery time <= 25 mins is fast)
    if (_fastDeliveryOnly) {
      filtered = filtered.where((r) {
        final timeString = r.deliveryTime.replaceAll(RegExp(r'[^0-9]'), '');
        final time = int.tryParse(timeString) ?? 60;
        return time <= 25;
      }).toList();
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

  // Bottom sheet methods
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

  void _showPriceRangeBottomSheet() {
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
                'Price Range',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...[1000.0, 300.0, 500.0, 700.0].map(
                (price) => ListTile(
                  title: Text(
                    price == 1000.0 ? 'Rs. 0-1000+' : 'Rs. 0-${price.toInt()}',
                  ),
                  trailing: _maxPrice == price
                      ? const Icon(Icons.check, color: AppColors.primaryColor)
                      : null,
                  onTap: () {
                    setState(() {
                      _maxPrice = price;
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
}
