import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodiehub/providers/menu_cart_provider.dart';
import 'package:foodiehub/utils/constants.dart';
import 'package:provider/provider.dart';

class PromotionalBanner extends StatefulWidget {
  final List<PromoBanner> banners;
  final double height;
  final EdgeInsets margin;

  const PromotionalBanner({
    super.key,
    required this.banners,
    this.height = 180,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  State<PromotionalBanner> createState() => _PromotionalBannerState();
}

class _PromotionalBannerState extends State<PromotionalBanner>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Auto-scroll banners
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && widget.banners.isNotEmpty) {
        final nextIndex = (_currentIndex + 1) % widget.banners.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Container(
      height: widget.height,
      margin: widget.margin,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return _buildBannerCard(banner);
            },
          ),
          // Page indicators
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.banners.length,
                (index) => _buildIndicator(index == _currentIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(PromoBanner banner) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () {
        HapticFeedback.lightImpact();
        _onBannerTap(banner);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Background image
                    CachedNetworkImage(
                      imageUrl: banner.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: banner.backgroundColor.withValues(alpha: 0.3),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: banner.backgroundColor,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            banner.backgroundColor.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (banner.offerText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                banner.offerText!,
                                style: TextStyle(
                                  color: banner.backgroundColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            banner.title,
                            style: TextStyle(
                              color: banner.textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            banner.subtitle,
                            style: TextStyle(
                              color: banner.textColor.withValues(alpha: 0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (banner.expiryDate != null) ...[
                            const SizedBox(height: 8),
                            _buildCountdownTimer(banner.expiryDate!),
                          ],
                        ],
                      ),
                    ),
                    // Action button
                    if (banner.buttonText != null)
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            banner.buttonText!,
                            style: TextStyle(
                              color: banner.backgroundColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildCountdownTimer(DateTime expiryDate) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final difference = expiryDate.difference(now);

        if (difference.isNegative) {
          return const Text(
            'Offer Expired',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          );
        }

        final hours = difference.inHours;
        final minutes = difference.inMinutes % 60;
        final seconds = difference.inSeconds % 60;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Expires in ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  void _onBannerTap(PromoBanner banner) {
    // Handle banner tap based on banner type and deepLink
    if (banner.deepLink != null) {
      _handleDeepLink(banner.deepLink!);
    } else {
      // Default action based on banner content
      _handleDefaultAction(banner);
    }
  }

  void _handleDeepLink(String deepLink) {
    // Handle different deep link patterns
    if (deepLink.startsWith('/search')) {
      // Navigate to search with specific query
      Navigator.pushNamed(context, '/search');
    } else if (deepLink.startsWith('/category/')) {
      // Navigate to specific category
      final category = deepLink.split('/').last;
      Navigator.pushNamed(context, '/category', arguments: category);
    } else if (deepLink.startsWith('/restaurant/')) {
      // Navigate to specific restaurant
      final restaurantId = deepLink.split('/').last;
      Navigator.pushNamed(context, '/restaurant', arguments: restaurantId);
    } else if (deepLink.startsWith('/offers')) {
      // Navigate to offers page
      Navigator.pushNamed(context, '/offers');
    } else {
      // Fallback to showing banner details
      _showBannerDetails(deepLink);
    }
  }

  void _handleDefaultAction(PromoBanner banner) {
    // Handle default actions based on banner content
    switch (banner.id) {
      case 'promo1': // FREE DELIVERY
        _showOfferDetails(banner, 'Free delivery on orders above ₹199!');
        break;
      case 'promo2': // 50% OFF
        _showOfferDetails(banner, 'Get 50% off on your first order!');
        break;
      case 'promo3': // WEEKEND SPECIAL
        _showOfferDetails(banner, 'Buy 1 Get 1 Free on selected restaurants!');
        break;
      case 'promo4': // FLASH SALE
        _showOfferDetails(banner, 'Up to 70% off on premium restaurants!');
        break;
      case 'promo5': // MIDNIGHT CRAVINGS
        _showOfferDetails(
          banner,
          '24/7 delivery available for late night cravings!',
        );
        break;
      default:
        _showBannerDetails(banner.title);
    }
  }

  void _showOfferDetails(PromoBanner banner, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: banner.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_offer,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  banner.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                banner.subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Text(message, style: const TextStyle(fontSize: 14)),
              if (banner.expiryDate != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Expires: ${_formatExpiryDate(banner.expiryDate!)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _applyOffer(banner);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: banner.backgroundColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(banner.buttonText ?? 'Apply Offer'),
            ),
          ],
        );
      },
    );
  }

  void _showBannerDetails(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped on $title'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _applyOffer(PromoBanner banner) {
    final cart = Provider.of<MenuCartProvider>(context, listen: false);

    // Check if offer already applied
    if (cart.hasOffer(banner.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${banner.title} is already applied!'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Apply different offers based on banner type
    double discountAmount = 0;
    double? minimumAmount;
    String description = '';

    switch (banner.id) {
      case 'promo1': // FREE DELIVERY
        discountAmount = 50; // Free delivery worth ₹50
        minimumAmount = 199;
        description = 'Free delivery on orders above ₹199';
        break;
      case 'promo2': // 50% OFF
        discountAmount = cart.subtotalAmount * 0.5;
        if (discountAmount > 100) discountAmount = 100; // Max ₹100 off
        description = '50% off up to ₹100 on first order';
        break;
      case 'promo3': // WEEKEND SPECIAL
        discountAmount = cart.subtotalAmount * 0.5; // BOGO = 50% off
        description = 'Buy 1 Get 1 Free on selected items';
        break;
      case 'promo4': // FLASH SALE
        discountAmount = cart.subtotalAmount * 0.7;
        if (discountAmount > 200) discountAmount = 200; // Max ₹200 off
        description = 'Up to 70% off on premium restaurants';
        break;
      case 'promo5': // MIDNIGHT CRAVINGS
        discountAmount = 30; // ₹30 off for late night orders
        description = 'Late night delivery discount';
        break;
      default:
        discountAmount = 50;
        description = banner.subtitle;
    }

    // Check minimum amount requirement
    if (minimumAmount != null && cart.subtotalAmount < minimumAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimum order amount ₹${minimumAmount.toInt()} required',
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Apply the offer
    cart.applyOffer(
      banner.id,
      banner.title,
      description,
      discountAmount,
      minimumAmount: minimumAmount,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${banner.title} offer applied! Saved ₹${discountAmount.toInt()}',
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: banner.backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );
  }

  String _formatExpiryDate(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} left';
    } else {
      return 'Expires soon';
    }
  }
}
