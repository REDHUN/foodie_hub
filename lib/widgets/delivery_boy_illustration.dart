import 'package:flutter/material.dart';

class DeliveryBoyIllustration extends StatelessWidget {
  final double size;
  
  const DeliveryBoyIllustration({
    super.key,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: DeliveryBoyPainter(),
    );
  }
}

class DeliveryBoyPainter extends CustomPainter {
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
    
    // Delivery boy body
    paint.color = const Color(0xFF4A90E2);
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.65),
        width: size.width * 0.4,
        height: size.height * 0.35,
      ),
      const Radius.circular(20),
    );
    canvas.drawRRect(bodyRect, paint);
    
    // Head
    paint.color = const Color(0xFFFFDBB5);
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.35),
      size.width * 0.12,
      paint,
    );
    
    // Helmet
    paint.color = const Color(0xFFFF6B6B);
    final helmetPath = Path();
    helmetPath.addArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.32),
        width: size.width * 0.28,
        height: size.height * 0.2,
      ),
      -3.14,
      3.14,
    );
    canvas.drawPath(helmetPath, paint);
    
    // Delivery bag
    paint.color = const Color(0xFF2ECC71);
    final bagRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.75, size.height * 0.55),
        width: size.width * 0.25,
        height: size.height * 0.2,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(bagRect, paint);
    
    // Bag strap
    paint.color = const Color(0xFF27AE60);
    paint.strokeWidth = 4;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.5),
      Offset(size.width * 0.55, size.height * 0.6),
      paint,
    );
    
    // Arms
    paint.color = const Color(0xFFFFDBB5);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.55),
      size.width * 0.06,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.55),
      size.width * 0.06,
      paint,
    );
    
    // Motorcycle wheel (simplified)
    paint.color = const Color(0xFF34495E);
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.8),
      size.width * 0.08,
      paint,
    );
    
    // Motorcycle body
    paint.color = const Color(0xFF95A5A6);
    final bikeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.4, size.height * 0.75),
        width: size.width * 0.3,
        height: size.height * 0.08,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(bikeRect, paint);
    
    // Speed lines for motion effect
    paint.color = const Color(0xFFBDC3C7);
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(size.width * 0.1, size.height * (0.3 + i * 0.1)),
        Offset(size.width * 0.2, size.height * (0.3 + i * 0.1)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}