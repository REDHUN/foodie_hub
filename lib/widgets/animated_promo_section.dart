import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodiehub/providers/menu_cart_provider.dart';
import 'package:provider/provider.dart';

class AnimatedPromoSection extends StatefulWidget {
  const AnimatedPromoSection({super.key});

  @override
  State<AnimatedPromoSection> createState() => _AnimatedPromoSectionState();
}

class _AnimatedPromoSectionState extends State<AnimatedPromoSection>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fast Delivery Promo
        SlideTransition(
          position: _slideAnimation,
          child: _buildFastDeliveryPromo(),
        ),
        const SizedBox(height: 16),
        // Special Offers Grid
        _buildSpecialOffersGrid(),
        const SizedBox(height: 16),
        // Animated CTA Banner
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: _buildCTABanner(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFastDeliveryPromo() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _onFreeDeliveryTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delivery_dining,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FREE DELIVERY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'On orders above ₹199',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Order Now',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialOffersGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Special Offers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOfferCard(
                  'First Order',
                  '50% OFF',
                  'Up to ₹100',
                  Colors.orange,
                  Icons.restaurant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOfferCard(
                  'Weekend',
                  'BOGO',
                  'Buy 1 Get 1',
                  Colors.purple,
                  Icons.local_pizza,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(
    String title,
    String offer,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _onOfferCardTap(title, offer);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              offer,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTABanner() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _onBrowseMenuTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎉 HUNGRY?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Order your favorite food now!',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Text(
                      'Browse Menu',
                      style: TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(Icons.fastfood, color: Colors.white, size: 40),
            ),
          ],
        ),
      ),
    );
  }

  void _onFreeDeliveryTap() {
    final cart = Provider.of<MenuCartProvider>(context, listen: false);
    const offerId = 'free_delivery_promo';

    // Check if offer already applied
    if (cart.hasOffer(offerId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Free delivery offer is already applied!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check minimum amount requirement
    if (cart.subtotalAmount < 199) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Add ₹${(199 - cart.subtotalAmount).toInt()} more to get free delivery!',
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Order Now',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
        ),
      );
      return;
    }

    // Apply free delivery offer
    cart.applyOffer(
      offerId,
      'FREE DELIVERY',
      'Free delivery on orders above ₹199',
      50, // Delivery fee amount
      minimumAmount: 199,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Free delivery applied! Saved ₹50 🚚'),
        duration: Duration(seconds: 3),
        backgroundColor: Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onOfferCardTap(String title, String offer) {
    // Handle offer card tap
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
                  color: title == 'First Order' ? Colors.orange : Colors.purple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  title == 'First Order' ? Icons.restaurant : Icons.local_pizza,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$title $offer',
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
                title == 'First Order'
                    ? 'Get 50% off on your first order up to ₹100!'
                    : 'Weekend special! Buy 1 Get 1 Free on selected items.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      (title == 'First Order' ? Colors.orange : Colors.purple)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        (title == 'First Order' ? Colors.orange : Colors.purple)
                            .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: title == 'First Order'
                          ? Colors.orange
                          : Colors.purple,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title == 'First Order'
                            ? 'Valid for new users only'
                            : 'Valid on weekends only',
                        style: TextStyle(
                          color: title == 'First Order'
                              ? Colors.orange
                              : Colors.purple,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                _applyOffer(title, offer);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: title == 'First Order'
                    ? Colors.orange
                    : Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Apply Offer'),
            ),
          ],
        );
      },
    );
  }

  void _onBrowseMenuTap() {
    // Handle browse menu tap
    Navigator.pushNamed(context, '/search');
  }

  void _applyOffer(String title, String offer) {
    final cart = Provider.of<MenuCartProvider>(context, listen: false);
    final offerId = title.toLowerCase().replaceAll(' ', '_');

    // Check if offer already applied
    if (cart.hasOffer(offerId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title $offer is already applied!'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Apply different offers based on title
    double discountAmount = 0;
    double? minimumAmount;
    String description = '';

    if (title == 'First Order') {
      discountAmount = cart.subtotalAmount * 0.5;
      if (discountAmount > 100) discountAmount = 100; // Max ₹100 off
      description = '50% off up to ₹100 on first order';
    } else if (title == 'Weekend') {
      discountAmount = cart.subtotalAmount * 0.5; // BOGO = 50% off
      description = 'Buy 1 Get 1 Free on selected items';
    }

    // Apply the offer
    cart.applyOffer(
      offerId,
      '$title $offer',
      description,
      discountAmount,
      minimumAmount: minimumAmount,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$title $offer applied! Saved ₹${discountAmount.toInt()} 🎉',
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: title == 'First Order' ? Colors.orange : Colors.purple,
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
}
