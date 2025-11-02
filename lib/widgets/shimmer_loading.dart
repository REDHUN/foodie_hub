import 'package:flutter/material.dart';

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
    this.baseColor = const Color(0xFFF8F9FA),
    this.highlightColor = const Color(0xFFFFFFFF),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isLoading) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading) {
      _animationController.repeat();
    } else {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [0.0, 0.4, 1.0],
              transform: GradientRotation(_animation.value * 3.14159 / 4),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

class RestaurantCardShimmer extends StatelessWidget {
  const RestaurantCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: 160,
            height: 140,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 8),
          const ShimmerBox(width: 120, height: 16),
          const SizedBox(height: 4),
          const ShimmerBox(width: 80, height: 12),
          const SizedBox(height: 4),
          const ShimmerBox(width: 100, height: 12),
        ],
      ),
    );
  }
}

class FullRestaurantCardShimmer extends StatelessWidget {
  const FullRestaurantCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: double.infinity,
            height: 150,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 200, height: 18),
                const SizedBox(height: 8),
                const ShimmerBox(width: 150, height: 14),
                const SizedBox(height: 4),
                const ShimmerBox(width: 180, height: 14),
                const SizedBox(height: 4),
                const ShimmerBox(width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItemShimmer extends StatelessWidget {
  const CategoryItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          ShimmerBox(
            width: 80,
            height: 80,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 8),
          const ShimmerBox(width: 60, height: 12),
        ],
      ),
    );
  }
}

class PromoBannerShimmer extends StatelessWidget {
  const PromoBannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ShimmerBox(
        width: double.infinity,
        height: 180,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class FeaturedDealShimmer extends StatelessWidget {
  const FeaturedDealShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: ShimmerBox(
        width: 280,
        height: 200,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class SearchResultShimmer extends StatelessWidget {
  const SearchResultShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          ShimmerBox(
            width: 60,
            height: 60,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 150, height: 16),
                const SizedBox(height: 4),
                const ShimmerBox(width: 100, height: 12),
                const SizedBox(height: 4),
                const ShimmerBox(width: 80, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItemShimmer extends StatelessWidget {
  const MenuItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF0F0F0).withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 180, height: 18),
                const SizedBox(height: 8),
                const ShimmerBox(width: double.infinity, height: 14),
                const SizedBox(height: 4),
                const ShimmerBox(width: 120, height: 14),
                const SizedBox(height: 12),
                const ShimmerBox(width: 80, height: 16),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              ShimmerBox(
                width: 100,
                height: 80,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 8),
              ShimmerBox(
                width: 80,
                height: 32,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CartItemShimmer extends StatelessWidget {
  const CartItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(
              width: 80,
              height: 80,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 150, height: 16),
                  const SizedBox(height: 4),
                  const ShimmerBox(width: 200, height: 12),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ShimmerBox(width: 60, height: 18),
                      ShimmerBox(
                        width: 120,
                        height: 32,
                        borderRadius: BorderRadius.circular(16),
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
}

class OwnerDashboardShimmer extends StatelessWidget {
  const OwnerDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stats cards shimmer
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: 100,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: 100,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
        // Chart shimmer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ShimmerBox(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 20),
        // List items shimmer
        ...List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ShimmerBox(
              width: double.infinity,
              height: 80,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
