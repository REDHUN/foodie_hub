import 'dart:math';

import 'package:flutter/material.dart';

class RestaurantOwnerIllustration extends StatefulWidget {
  final double size;
  final bool isLoginMode;

  const RestaurantOwnerIllustration({
    super.key,
    this.size = 200,
    this.isLoginMode = true,
  });

  @override
  State<RestaurantOwnerIllustration> createState() =>
      _RestaurantOwnerIllustrationState();
}

class _RestaurantOwnerIllustrationState
    extends State<RestaurantOwnerIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: RestaurantOwnerPainter(isLoginMode: widget.isLoginMode),
            ),
          ),
        );
      },
    );
  }
}

class RestaurantOwnerPainter extends CustomPainter {
  final bool isLoginMode;

  RestaurantOwnerPainter({required this.isLoginMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Beautiful gradient background
    paint.shader =
        RadialGradient(
          colors: [
            const Color(0xFFFFE5E5),
            const Color(0xFFF8F9FA),
            const Color(0xFFE8F4FD),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: size.width / 2,
          ),
        );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    // Add subtle decorative elements
    _drawBackgroundElements(canvas, size);

    if (isLoginMode) {
      _drawLoginIllustration(canvas, size, paint);
    } else {
      _drawSignupIllustration(canvas, size, paint);
    }
  }

  void _drawBackgroundElements(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.3);

    // Floating circles
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.2), 8, paint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.8), 6, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.3), 4, paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.7), 5, paint);
  }

  void _drawLoginIllustration(Canvas canvas, Size size, Paint paint) {
    // Chef hat with gradient
    paint.shader =
        LinearGradient(
          colors: [Colors.white, const Color(0xFFF8F9FA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height * 0.25),
            width: size.width * 0.4,
            height: size.height * 0.2,
          ),
        );

    final hatPath = Path();
    hatPath.addOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.25),
        width: size.width * 0.4,
        height: size.height * 0.2,
      ),
    );
    canvas.drawPath(hatPath, paint);

    // Hat band with gradient
    paint.shader =
        LinearGradient(
          colors: [const Color(0xFFFF6B6B), const Color(0xFFE74C3C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height * 0.32),
            width: size.width * 0.4,
            height: size.height * 0.05,
          ),
        );

    final bandRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.32),
        width: size.width * 0.4,
        height: size.height * 0.05,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(bandRect, paint);

    // Head with skin tone gradient
    paint.shader =
        RadialGradient(
          colors: [const Color(0xFFFFE4C4), const Color(0xFFFFDBB5)],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width / 2, size.height * 0.45),
            radius: size.width * 0.15,
          ),
        );
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.45),
      size.width * 0.15,
      paint,
    );

    // Eyes
    paint.shader = null;
    paint.color = const Color(0xFF2C3E50);
    canvas.drawCircle(Offset(size.width * 0.46, size.height * 0.42), 2, paint);
    canvas.drawCircle(Offset(size.width * 0.54, size.height * 0.42), 2, paint);

    // Smile
    final smilePath = Path();
    smilePath.addArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.47),
        width: size.width * 0.08,
        height: size.height * 0.04,
      ),
      0,
      pi,
    );
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawPath(smilePath, paint);
    paint.style = PaintingStyle.fill;

    // Body (chef coat) with gradient
    paint.shader =
        LinearGradient(
          colors: [Colors.white, const Color(0xFFF8F9FA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height * 0.65),
            width: size.width * 0.35,
            height: size.height * 0.3,
          ),
        );

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.65),
        width: size.width * 0.35,
        height: size.height * 0.3,
      ),
      const Radius.circular(15),
    );
    canvas.drawRRect(bodyRect, paint);

    // Chef coat buttons with metallic look
    paint.shader = RadialGradient(
      colors: [const Color(0xFF95A5A6), const Color(0xFF34495E)],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: 4));

    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height * (0.55 + i * 0.05)),
        4,
        paint,
      );
    }

    // Arms with gradient
    paint.shader =
        LinearGradient(
          colors: [Colors.white, const Color(0xFFF0F0F0)],
        ).createShader(
          Rect.fromCircle(center: Offset.zero, radius: size.width * 0.08),
        );

    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.6),
      size.width * 0.08,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.6),
      size.width * 0.08,
      paint,
    );

    // Modern tablet/device in hand
    paint.shader =
        LinearGradient(
          colors: [const Color(0xFF34495E), const Color(0xFF2C3E50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(
          Rect.fromCenter(
            center: Offset(size.width * 0.7, size.height * 0.55),
            width: size.width * 0.12,
            height: size.height * 0.08,
          ),
        );

    final tabletRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.7, size.height * 0.55),
        width: size.width * 0.12,
        height: size.height * 0.08,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(tabletRect, paint);

    // Screen glow
    paint.shader =
        RadialGradient(
          colors: [
            const Color(0xFF3498DB).withOpacity(0.8),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCenter(
            center: Offset(size.width * 0.7, size.height * 0.55),
            width: size.width * 0.1,
            height: size.height * 0.06,
          ),
        );

    final screenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.7, size.height * 0.55),
        width: size.width * 0.1,
        height: size.height * 0.06,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(screenRect, paint);
  }

  void _drawSignupIllustration(Canvas canvas, Size size, Paint paint) {
    // Restaurant building with gradient
    paint.shader =
        LinearGradient(
          colors: [const Color(0xFFE74C3C), const Color(0xFFC0392B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height * 0.6),
            width: size.width * 0.6,
            height: size.height * 0.4,
          ),
        );

    final buildingRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.6),
        width: size.width * 0.6,
        height: size.height * 0.4,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(buildingRect, paint);

    // Restaurant sign with gradient
    paint.shader =
        LinearGradient(
          colors: [const Color(0xFFF39C12), const Color(0xFFE67E22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height * 0.45),
            width: size.width * 0.4,
            height: size.height * 0.1,
          ),
        );

    final signRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.45),
        width: size.width * 0.4,
        height: size.height * 0.1,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(signRect, paint);

    // Sign text effect
    paint.shader = null;
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.45),
          width: size.width * 0.35,
          height: size.height * 0.06,
        ),
        const Radius.circular(4),
      ),
      paint,
    );
    paint.style = PaintingStyle.fill;

    // Windows with glass effect
    paint.shader =
        LinearGradient(
          colors: [
            const Color(0xFF3498DB).withOpacity(0.8),
            const Color(0xFF2980B9).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(
          Rect.fromCenter(
            center: Offset(size.width * 0.4, size.height * 0.6),
            width: size.width * 0.08,
            height: size.height * 0.08,
          ),
        );

    final window1 = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.4, size.height * 0.6),
        width: size.width * 0.08,
        height: size.height * 0.08,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(window1, paint);

    final window2 = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.6, size.height * 0.6),
        width: size.width * 0.08,
        height: size.height * 0.08,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(window2, paint);

    // Window reflections
    paint.shader =
        LinearGradient(
          colors: [Colors.white.withOpacity(0.6), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(
          Rect.fromCenter(
            center: Offset(size.width * 0.4, size.height * 0.58),
            width: size.width * 0.04,
            height: size.height * 0.04,
          ),
        );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.4, size.height * 0.58),
          width: size.width * 0.04,
          height: size.height * 0.04,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.6, size.height * 0.58),
          width: size.width * 0.04,
          height: size.height * 0.04,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Door with gradient
    paint.shader =
        LinearGradient(
          colors: [const Color(0xFF8B4513), const Color(0xFF654321)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height * 0.75),
            width: size.width * 0.12,
            height: size.height * 0.15,
          ),
        );

    final doorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.75),
        width: size.width * 0.12,
        height: size.height * 0.15,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(doorRect, paint);

    // Door handle
    paint.shader = RadialGradient(
      colors: [const Color(0xFFFFD700), const Color(0xFFDAA520)],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: 3));

    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.75), 3, paint);

    // Chef figure with better details
    paint.shader =
        RadialGradient(
          colors: [const Color(0xFFFFE4C4), const Color(0xFFFFDBB5)],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.25, size.height * 0.35),
            radius: size.width * 0.08,
          ),
        );

    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.35),
      size.width * 0.08,
      paint,
    );

    // Chef hat with gradient
    paint.shader =
        LinearGradient(
          colors: [Colors.white, const Color(0xFFF8F9FA)],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.25, size.height * 0.28),
            radius: size.width * 0.06,
          ),
        );

    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.28),
      size.width * 0.06,
      paint,
    );

    // Chef eyes and smile
    paint.shader = null;
    paint.color = const Color(0xFF2C3E50);
    canvas.drawCircle(
      Offset(size.width * 0.23, size.height * 0.34),
      1.5,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.27, size.height * 0.34),
      1.5,
      paint,
    );

    // Success stars with glow effect
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFFF1C40F),
        const Color(0xFFF39C12),
        Colors.transparent,
      ],
      stops: const [0.0, 0.7, 1.0],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: 12));

    _drawStar(canvas, Offset(size.width * 0.15, size.height * 0.2), 8, paint);
    _drawStar(canvas, Offset(size.width * 0.85, size.height * 0.25), 6, paint);
    _drawStar(canvas, Offset(size.width * 0.8, size.height * 0.75), 7, paint);

    // Add sparkle effects
    paint.shader = null;
    paint.color = Colors.white.withOpacity(0.8);
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi) / 5;
      final sparkleX = size.width * 0.75 + 15 * cos(angle);
      final sparkleY = size.height * 0.3 + 15 * sin(angle);
      canvas.drawCircle(Offset(sparkleX, sparkleY), 1.5, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * 3.14159) / 5 - 3.14159 / 2;
      final x = center.dx + radius * 0.6 * (i % 2 == 0 ? 1 : 0.4) * cos(angle);
      final y = center.dy + radius * 0.6 * (i % 2 == 0 ? 1 : 0.4) * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
