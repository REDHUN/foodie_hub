import 'package:flutter/material.dart';
import 'package:foodiehub/utils/constants.dart';

/// A widget that generates the FoodieHub app icon design
/// This can be used for testing or as a reference for the actual icon
class AppIconGenerator extends StatelessWidget {
  final double size;

  const AppIconGenerator({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background circle with subtle pattern
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Fork and Spoon icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.rotate(
                      angle: -0.3,
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: size * 0.15,
                      ),
                    ),
                    SizedBox(width: size * 0.05),
                    Transform.rotate(
                      angle: 0.3,
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: size * 0.15,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size * 0.08),

                // Food items
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pizza slice
                    Container(
                      width: size * 0.08,
                      height: size * 0.08,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(size * 0.02),
                      ),
                      child: Center(
                        child: Container(
                          width: size * 0.03,
                          height: size * 0.03,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: size * 0.03),

                    // Burger
                    Container(
                      width: size * 0.08,
                      height: size * 0.08,
                      decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.circular(size * 0.04),
                      ),
                      child: Center(
                        child: Container(
                          width: size * 0.06,
                          height: size * 0.02,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(size * 0.01),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size * 0.08),

                // App name
                Text(
                  'FH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          // Delivery indicator
          Positioned(
            top: size * 0.15,
            right: size * 0.15,
            child: Container(
              width: size * 0.12,
              height: size * 0.12,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.delivery_dining,
                color: Colors.white,
                size: size * 0.06,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Preview screen to test the app icon design
class AppIconPreviewScreen extends StatelessWidget {
  const AppIconPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColor,
      appBar: AppBar(
        title: const Text('App Icon Preview'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'FoodieHub App Icon',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 30),

            // Large preview
            const AppIconGenerator(size: 200),

            const SizedBox(height: 40),

            // Different sizes
            const Text(
              'Different Sizes:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                AppIconGenerator(size: 48),
                AppIconGenerator(size: 72),
                AppIconGenerator(size: 96),
                AppIconGenerator(size: 120),
              ],
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'To use this design, create a 1024x1024 PNG file and run: flutter pub run flutter_launcher_icons',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text('Generate App Icons'),
            ),
          ],
        ),
      ),
    );
  }
}
