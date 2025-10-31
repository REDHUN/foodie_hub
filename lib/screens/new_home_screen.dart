import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodiehub/models/restaurant.dart';
import 'package:foodiehub/providers/menu_cart_provider.dart';
import 'package:foodiehub/providers/restaurant_provider.dart';
import 'package:foodiehub/screens/cart_screen.dart';
import 'package:foodiehub/screens/restaurant_detail_screen.dart';
import 'package:foodiehub/utils/constants.dart';
import 'package:foodiehub/widgets/star_rating.dart';
import 'package:provider/provider.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load restaurants from Firebase on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(context, listen: false).initializeRestaurants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              _buildHeader(context),
              // Search Bar
              _buildSearchBar(context),
              const SizedBox(height: 20),
              // Categories Section
              _buildCategoriesSection(),
              const SizedBox(height: 30),
              // Top-rated Section
              _buildTopRatedSection(context),
              const SizedBox(height: 30),
              // All Restaurants Section
              _buildAllRestaurantsSection(context),
            ],
          ),
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
                  'Koramangala, Bangalore',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.darkColor,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'JS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              'Search for restaurants and food',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
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
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryItem('Biryani', Icons.rice_bowl),
              _buildCategoryItem('Pizza', Icons.local_pizza),
              _buildCategoryItem('Burgers', Icons.lunch_dining),
              _buildCategoryItem('Cakes', Icons.cake),
              _buildCategoryItem('Chinese', Icons.restaurant),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String name, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 32, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTopRatedSection(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, restaurantProvider, child) {
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
          child: ListView(
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
        final restaurants = restaurantProvider.restaurants.isNotEmpty
            ? restaurantProvider.restaurants
            : sampleRestaurants;

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterButton('Filter'),
                    const SizedBox(width: 8),
                    _buildFilterButton('Sort By'),
                    const SizedBox(width: 8),
                    _buildFilterButton('Fast Delivery'),
                    const SizedBox(width: 8),
                    _buildFilterButton('New on Swiggy'),
                    const SizedBox(width: 8),
                    _buildFilterButton('Ratings'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  return _buildFullRestaurantCard(
                    context,
                    restaurants[index],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, Restaurant restaurant) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
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
}
