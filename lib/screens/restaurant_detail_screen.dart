import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodiehub/models/menu_item.dart';
import 'package:foodiehub/models/restaurant.dart';
import 'package:foodiehub/providers/menu_cart_provider.dart';
import 'package:foodiehub/providers/menu_item_provider.dart';
import 'package:foodiehub/screens/cart_screen.dart';
import 'package:foodiehub/utils/constants.dart';
import 'package:foodiehub/widgets/reliable_image.dart';
import 'package:foodiehub/widgets/shimmer_loading.dart';
import 'package:foodiehub/widgets/star_rating.dart';
import 'package:provider/provider.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuItemProvider>(
        context,
        listen: false,
      ).loadMenuItemsForRestaurant(widget.restaurant.id);
    });

    // Listen to scroll changes to show/hide restaurant name in app bar
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show title when scrolled past the image (approximately 150px)
    final shouldShowTitle = _scrollController.offset > 150;
    if (shouldShowTitle != _showTitle) {
      setState(() {
        _showTitle = shouldShowTitle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItemProvider = Provider.of<MenuItemProvider>(context);
    final providerMenuItems = menuItemProvider.getMenuItemsByRestaurant(
      widget.restaurant.id,
    );
    final fallbackMenuItems = sampleMenuItems
        .where((item) => item.restaurantId == widget.restaurant.id)
        .toList();
    final menuItems = providerMenuItems.isNotEmpty
        ? providerMenuItems
        : (menuItemProvider.isLoading ? <MenuItem>[] : fallbackMenuItems);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshMenuItems,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRestaurantInfo(),

                        _buildMenuSection(
                          menuItems,
                          isLoading: menuItemProvider.isLoading,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (Provider.of<MenuCartProvider>(context).itemCount > 0)
            _buildCartFooter(context),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: _showTitle ? AppColors.darkColor : Colors.white,
      elevation: _showTitle ? 1 : 0,
      title: AnimatedOpacity(
        opacity: _showTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          widget.restaurant.name,
          style: TextStyle(
            color: AppColors.darkColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: _showTitle ? AppColors.darkColor : Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            ReliableRestaurantImage(
              imageUrl: widget.restaurant.image,
              fit: BoxFit.cover,
            ),
            // Gradient overlay for better text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.restaurant.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              StarRating(rating: widget.restaurant.rating, size: 18),
              const SizedBox(width: 8),
              Text(
                '${widget.restaurant.rating}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 16),
              Text(
                widget.restaurant.deliveryTime,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.restaurant.cuisine,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.motorcycle, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '₹${widget.restaurant.deliveryFee} delivery fee',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          if (widget.restaurant.discount != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer, color: AppColors.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.restaurant.discount!,
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          const Text(
            'Menu',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(List<MenuItem> menuItems, {bool isLoading = false}) {
    if (isLoading && menuItems.isEmpty) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: ShimmerLoading(
              isLoading: true,
              child: const MenuItemShimmer(),
            ),
          );
        },
      );
    }

    if (menuItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No menu items available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return _buildMenuItemCard(menuItems[index]);
      },
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section with Category Badge
              Stack(
                children: [
                  ReliableImage(
                    imageUrl: item.image,
                    width: 120,
                    height: 140,
                    fit: BoxFit.cover,
                    category: item.category,
                    borderRadius: BorderRadius.zero,
                  ),
                  // Category Badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        item.category,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Description
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Price and Add Button Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Price
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.currency_rupee,
                                size: 16,
                                color: AppColors.primaryColor,
                              ),
                              Text(
                                item.price.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          // Add/Quantity Controls
                          Consumer<MenuCartProvider>(
                            builder: (context, cart, child) {
                              final quantity = cart.getQuantity(item.id);
                              final canAddMore = quantity < item.quantity;

                              if (quantity > 0) {
                                return Container(
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryColor
                                            .withValues(alpha: 0.3),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          cart.updateQuantity(
                                            item.id,
                                            quantity - 1,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: const Icon(
                                            Icons.remove,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        child: Text(
                                          '$quantity',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: canAddMore
                                            ? () {
                                                cart.addToCart(item);
                                              }
                                            : () {
                                                // Show message when max quantity reached
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Maximum available quantity (${item.quantity}) reached',
                                                    ),
                                                    duration: const Duration(
                                                      seconds: 2,
                                                    ),
                                                    backgroundColor:
                                                        Colors.orange,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                              },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            size: 14,
                                            color: canAddMore
                                                ? Colors.white
                                                : Colors.white.withValues(
                                                    alpha: 0.5,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                // Check if item is out of stock
                                if (!item.isInStock) {
                                  return Container(
                                    height: 28,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'OUT OF STOCK',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                          letterSpacing: 0.5,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return ElevatedButton(
                                  onPressed: item.isInStock
                                      ? () {
                                          cart.addToCart(item);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${item.name} added to cart!',
                                              ),
                                              duration: const Duration(
                                                seconds: 1,
                                              ),
                                              backgroundColor:
                                                  AppColors.successColor,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(0, 28),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    elevation: 1.5,
                                    shadowColor: AppColors.primaryColor
                                        .withValues(alpha: 0.3),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'ADD',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: 3),
                                      Icon(Icons.add, size: 12),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartFooter(BuildContext context) {
    return Consumer<MenuCartProvider>(
      builder: (context, cart, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    const Icon(
                      Icons.shopping_bag,
                      color: Colors.white,
                      size: 24,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cart.itemCount} items',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '₹${cart.totalAmount.toInt()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'VIEW CART',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _refreshMenuItems() async {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Reload menu items for this restaurant
      final menuItemProvider = Provider.of<MenuItemProvider>(
        context,
        listen: false,
      );

      await menuItemProvider.loadMenuItemsForRestaurant(widget.restaurant.id);

      // Add success haptic feedback
      HapticFeedback.lightImpact();

      // Show success message
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Menu refreshed! 🍽️'),
      //       duration: Duration(seconds: 2),
      //       backgroundColor: AppColors.successColor,
      //       behavior: SnackBarBehavior.floating,
      //     ),
      //   );
      // }
    } catch (error) {
      // Add error haptic feedback
      HapticFeedback.lightImpact();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh menu: $error'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
