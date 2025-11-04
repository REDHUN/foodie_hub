import 'package:flutter/material.dart';
import 'package:foodiehub/utils/constants.dart';
import 'package:foodiehub/widgets/beautiful_image_loader.dart';

/// Showcase widget to demonstrate different loader types
class LoaderShowcase extends StatelessWidget {
  const LoaderShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beautiful Image Loaders'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Image Loading Animations',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Shimmer Loader
            _buildLoaderSection(
              'Shimmer Loader',
              'Smooth shimmer effect for large images',
              BeautifulImageLoader(
                width: double.infinity,
                height: 120,
                type: LoaderType.shimmer,
              ),
            ),

            // Pulse Loader
            _buildLoaderSection(
              'Pulse Loader',
              'Gentle pulsing animation for small images',
              BeautifulImageLoader(
                width: double.infinity,
                height: 80,
                type: LoaderType.pulse,
              ),
            ),

            // Wave Loader
            _buildLoaderSection(
              'Wave Loader',
              'Animated wave dots for dynamic loading',
              BeautifulImageLoader(
                width: double.infinity,
                height: 60,
                type: LoaderType.wave,
              ),
            ),

            // Spinner Loader
            _buildLoaderSection(
              'Spinner Loader',
              'Classic spinning loader with custom design',
              BeautifulImageLoader(
                width: double.infinity,
                height: 60,
                type: LoaderType.spinner,
              ),
            ),

            // Dots Loader
            _buildLoaderSection(
              'Dots Loader',
              'Subtle animated dots for minimal design',
              BeautifulImageLoader(
                width: double.infinity,
                height: 60,
                type: LoaderType.dots,
              ),
            ),

            // Gradient Loader
            _buildLoaderSection(
              'Gradient Loader',
              'Radial gradient animation with icon',
              BeautifulImageLoader(
                width: double.infinity,
                height: 100,
                type: LoaderType.gradient,
              ),
            ),

            const SizedBox(height: 20),

            // Different sizes showcase
            const Text(
              'Different Sizes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                // Small
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Small (60x60)',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      BeautifulImageLoader(
                        width: 60,
                        height: 60,
                        type: LoaderType.pulse,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Medium
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Medium (100x100)',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      BeautifulImageLoader(
                        width: 100,
                        height: 100,
                        type: LoaderType.gradient,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Large
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Large (120x80)',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      BeautifulImageLoader(
                        width: 120,
                        height: 80,
                        type: LoaderType.shimmer,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Color variations
            const Text(
              'Color Variations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: BeautifulImageLoader(
                    width: double.infinity,
                    height: 80,
                    type: LoaderType.shimmer,
                    primaryColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BeautifulImageLoader(
                    width: double.infinity,
                    height: 80,
                    type: LoaderType.shimmer,
                    primaryColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BeautifulImageLoader(
                    width: double.infinity,
                    height: 80,
                    type: LoaderType.shimmer,
                    primaryColor: Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Quick access examples
            const Text(
              'Quick Access Methods',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: ImageLoaders.shimmer(height: 60)),
                    const SizedBox(width: 8),
                    Expanded(child: ImageLoaders.pulse(height: 60)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: ImageLoaders.wave(height: 60)),
                    const SizedBox(width: 8),
                    Expanded(child: ImageLoaders.gradient(height: 60)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLoaderSection(String title, String description, Widget loader) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: loader,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
