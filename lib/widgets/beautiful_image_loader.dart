import 'package:flutter/material.dart';
import 'package:foodiehub/utils/constants.dart';

/// Beautiful animated loaders for images
class BeautifulImageLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final LoaderType type;
  final Color? primaryColor;
  final Color? backgroundColor;

  const BeautifulImageLoader({
    super.key,
    this.width,
    this.height,
    this.type = LoaderType.shimmer,
    this.primaryColor,
    this.backgroundColor,
  });

  @override
  State<BeautifulImageLoader> createState() => _BeautifulImageLoaderState();
}

class _BeautifulImageLoaderState extends State<BeautifulImageLoader>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _rotationController;

  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Wave animation
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // Rotation animation
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() {
    _shimmerController.repeat();
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? AppColors.primaryColor;
    final backgroundColor = widget.backgroundColor ?? Colors.grey[200]!;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildLoader(primaryColor, backgroundColor),
    );
  }

  Widget _buildLoader(Color primaryColor, Color backgroundColor) {
    switch (widget.type) {
      case LoaderType.shimmer:
        return _buildShimmerLoader(primaryColor, backgroundColor);
      case LoaderType.pulse:
        return _buildPulseLoader(primaryColor);
      case LoaderType.wave:
        return _buildWaveLoader(primaryColor);
      case LoaderType.spinner:
        return _buildSpinnerLoader(primaryColor);
      case LoaderType.dots:
        return _buildDotsLoader(primaryColor);
      case LoaderType.gradient:
        return _buildGradientLoader(primaryColor);
    }
  }

  Widget _buildShimmerLoader(Color primaryColor, Color backgroundColor) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                backgroundColor,
                primaryColor.withValues(alpha: 0.3),
                backgroundColor,
              ],
              stops: [
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulseLoader(Color primaryColor) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Center(
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.image, color: Colors.white, size: 20),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveLoader(Color primaryColor) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final delay = index * 0.2;
              final animationValue = (_waveAnimation.value - delay).clamp(
                0.0,
                1.0,
              );
              final scale =
                  0.5 + (0.5 * (1 - (animationValue - 0.5).abs() * 2));

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildSpinnerLoader(Color primaryColor) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Center(
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                  width: 3,
                ),
              ),
              child: CustomPaint(painter: SpinnerPainter(primaryColor)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDotsLoader(Color primaryColor) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final delay = index * 0.1;
              final animationValue = (_waveAnimation.value + delay) % 1.0;
              final opacity =
                  (0.3 + 0.7 * (1 - (animationValue - 0.5).abs() * 2)).clamp(
                    0.0,
                    1.0,
                  );

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildGradientLoader(Color primaryColor) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: RadialGradient(
              center: Alignment(
                _shimmerAnimation.value * 0.5,
                _shimmerAnimation.value * 0.3,
              ),
              radius: 0.8,
              colors: [
                primaryColor.withValues(alpha: 0.4),
                primaryColor.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              color: primaryColor.withValues(alpha: 0.6),
              size: 24,
            ),
          ),
        );
      },
    );
  }
}

class SpinnerPainter extends CustomPainter {
  final Color color;

  SpinnerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      3.14159, // Half circle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum LoaderType { shimmer, pulse, wave, spinner, dots, gradient }

/// Quick access to different loader types
class ImageLoaders {
  static Widget shimmer({double? width, double? height, Color? color}) {
    return BeautifulImageLoader(
      width: width,
      height: height,
      type: LoaderType.shimmer,
      primaryColor: color,
    );
  }

  static Widget pulse({double? width, double? height, Color? color}) {
    return BeautifulImageLoader(
      width: width,
      height: height,
      type: LoaderType.pulse,
      primaryColor: color,
    );
  }

  static Widget wave({double? width, double? height, Color? color}) {
    return BeautifulImageLoader(
      width: width,
      height: height,
      type: LoaderType.wave,
      primaryColor: color,
    );
  }

  static Widget spinner({double? width, double? height, Color? color}) {
    return BeautifulImageLoader(
      width: width,
      height: height,
      type: LoaderType.spinner,
      primaryColor: color,
    );
  }

  static Widget dots({double? width, double? height, Color? color}) {
    return BeautifulImageLoader(
      width: width,
      height: height,
      type: LoaderType.dots,
      primaryColor: color,
    );
  }

  static Widget gradient({double? width, double? height, Color? color}) {
    return BeautifulImageLoader(
      width: width,
      height: height,
      type: LoaderType.gradient,
      primaryColor: color,
    );
  }
}
