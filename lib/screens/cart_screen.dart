import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodiehub/models/menu_cart_item.dart';
import 'package:foodiehub/providers/menu_cart_provider.dart';
import 'package:foodiehub/utils/constants.dart';
import 'package:foodiehub/widgets/shimmer_loading.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Your Cart',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<MenuCartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add items from restaurants to get started',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: _isLoading
                    ? ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return ShimmerLoading(
                            isLoading: true,
                            child: const CartItemShimmer(),
                          );
                        },
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshCart,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            ...cart.items.map((item) {
                              return _buildCartItem(context, item);
                            }),
                            if (cart.appliedOffers.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _buildAppliedOffersSection(context, cart),
                            ],
                          ],
                        ),
                      ),
              ),
              _buildCartFooter(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, MenuCartItem item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      margin: const EdgeInsets.only(bottom: 16),

      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.menuItem.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.menuItem.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.menuItem.description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${item.menuItem.price.toInt()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            color: AppColors.primaryColor,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Provider.of<MenuCartProvider>(
                                context,
                                listen: false,
                              ).updateQuantity(
                                item.menuItem.id,
                                item.quantity - 1,
                              );
                            },
                          ),
                          Container(
                            width: 30,
                            alignment: Alignment.center,
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            color: AppColors.primaryColor,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Provider.of<MenuCartProvider>(
                                context,
                                listen: false,
                              ).addToCart(item.menuItem);
                            },
                          ),
                        ],
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

  Widget _buildCartFooter(BuildContext context, MenuCartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                '₹${cart.subtotalAmount.toInt()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (cart.appliedOffers.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Discount',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
                Text(
                  '-₹${cart.discountAmount.toInt()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery Fee',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                '₹50',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${(cart.totalAmount + 50).toInt()}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order placed successfully!'),
                    backgroundColor: AppColors.successColor,
                    duration: Duration(seconds: 2),
                  ),
                );
                Provider.of<MenuCartProvider>(
                  context,
                  listen: false,
                ).clearCart();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'PLACE ORDER',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedOffersSection(
    BuildContext context,
    MenuCartProvider cart,
  ) {
    return Card(
      color: Colors.green.withValues(alpha: 0.1),
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_offer, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Applied Offers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...cart.appliedOffers.map((offer) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            offer.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '-₹${offer.discountAmount.toInt()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            cart.removeOffer(offer.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${offer.title} removed'),
                                duration: const Duration(seconds: 2),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                          child: const Text(
                            'Remove',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshCart() async {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Simulate cart refresh (recalculate totals, validate offers, etc.)
      await Future.delayed(const Duration(milliseconds: 500));

      // Refresh loading state
      setState(() {
        _isLoading = true;
      });

      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 300));

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
          const SnackBar(
            content: Text('Cart refreshed! 🛒'),
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
            content: Text('Failed to refresh cart: $error'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
