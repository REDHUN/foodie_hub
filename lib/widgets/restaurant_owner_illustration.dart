import 'dart:math';

import 'package:flutter/material.dart';

class RestaurantOwnerIllustration extends StatelessWidget {
  final double size;
  final bool isLoginMode;

  const RestaurantOwnerIllustration({
    super.key,
    this.size = 200,
    this.isLoginMode = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: RestaurantOwnerPainter(isLoginMode: isLoginMode),
    );
  }
}

class RestaurantOwnerPainter extends CustomPainter {
  final bool isLoginMode;

  RestaurantOwnerPainter({required this.isLoginMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Background circle
    paint.color = const Color(0xFFF8F9FA);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    if (isLoginMode) {
      _drawLoginIllustration(canvas, size, paint);
    } else {
      _drawSignupIllustration(canvas, size, paint);
    }
  }

  void _drawLoginIllustration(Canvas canvas, Size size, Paint paint) {
    // Chef hat
    paint.color = Colors.white;
    final hatPath = Path();
    hatPath.addOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.25),
        width: size.width * 0.4,
        height: size.height * 0.2,
      ),
    );
    canvas.drawPath(hatPath, paint);

    // Hat band
    paint.color = const Color(0xFFFF6B6B);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.32),
        width: size.width * 0.4,
        height: size.height * 0.05,
      ),
      paint,
    );

    // Head
    paint.color = const Color(0xFFFFDBB5);
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.45),
      size.width * 0.15,
      paint,
    );

    // Body (chef coat)
    paint.color = Colors.white;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.65),
        width: size.width * 0.35,
        height: size.height * 0.3,
      ),
      const Radius.circular(15),
    );
    canvas.drawRRect(bodyRect, paint);

    // Chef coat buttons
    paint.color = const Color(0xFF34495E);
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height * (0.55 + i * 0.05)),
        3,
        paint,
      );
    }

    // Arms
    paint.color = Colors.white;
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

    // Tablet/Menu in hand
    paint.color = const Color(0xFF2C3E50);
    final tabletRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.7, size.height * 0.55),
        width: size.width * 0.12,
        height: size.height * 0.08,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(tabletRect, paint);
  }

  void _drawSignupIllustration(Canvas canvas, Size size, Paint paint) {
    // Restaurant building
    paint.color = const Color(0xFFE74C3C);
    final buildingRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.6),
        width: size.width * 0.6,
        height: size.height * 0.4,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(buildingRect, paint);

    // Restaurant sign
    paint.color = const Color(0xFFF39C12);
    final signRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.45),
        width: size.width * 0.4,
        height: size.height * 0.1,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(signRect, paint);

    // Windows
    paint.color = const Color(0xFF3498DB);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.4, size.height * 0.6),
        width: size.width * 0.08,
        height: size.height * 0.08,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.6, size.height * 0.6),
        width: size.width * 0.08,
        height: size.height * 0.08,
      ),
      paint,
    );

    // Door
    paint.color = const Color(0xFF8B4513);
    final doorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.75),
        width: size.width * 0.12,
        height: size.height * 0.15,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(doorRect, paint);

    // Chef figure next to restaurant
    paint.color = const Color(0xFFFFDBB5);
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.35),
      size.width * 0.08,
      paint,
    );

    // Chef hat (smaller)
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.28),
      size.width * 0.06,
      paint,
    );

    // Stars around (success/achievement)
    paint.color = const Color(0xFFF1C40F);
    _drawStar(canvas, Offset(size.width * 0.15, size.height * 0.2), 8, paint);
    _drawStar(canvas, Offset(size.width * 0.85, size.height * 0.25), 6, paint);
    _drawStar(canvas, Offset(size.width * 0.8, size.height * 0.75), 7, paint);
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
