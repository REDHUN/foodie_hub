import 'package:flutter/material.dart';
import 'package:foodiehub/utils/constants.dart';
import 'package:foodiehub/widgets/simple_image_loader.dart';

/// Showcase widget for simple image loaders
class SimpleLoaderShowcase extends StatelessWidget {
  const SimpleLoaderShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Image Loaders'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Simple & Beautiful Loading',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Clean, elegant loaders for better user experience',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Icon Loader Section
            _buildSection(
              'Icon Loader',
              'Gentle pulse animation with category-aware icons',
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildLoaderCard(
                          'Small (60x60)',
                          SimpleLoaders.icon(
                            width: 60,
                            height: 60,
                            category: 'pizza',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLoaderCard(
                          'Medium (100x100)',
                          SimpleLoaders.icon(
                            width: 100,
                            height: 100,
                            category: 'burger',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildLoaderCard(
                    'Large (300x120)',
                    SimpleLoaders.icon(
                      width: double.infinity,
                      height: 120,
                      category: 'restaurant',
                    ),
                  ),
                ],
              ),
            ),

            // Shimmer Loader Section
            _buildSection(
              'Shimmer Loader',
              'Smooth shimmer effect for large images',
              Column(
                children: [
                  _buildLoaderCard(
                    'Restaurant Header',
                    SimpleLoaders.shimmer(width: double.infinity, height: 150),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLoaderCard(
                          'Card Image',
                          SimpleLoaders.shimmer(
                            width: double.infinity,
                            height: 100,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLoaderCard(
                          'Square Image',
                          SimpleLoaders.shimmer(
                            width: double.infinity,
                            height: 100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Auto Selection Section
            _buildSection(
              'Auto Selection',
              'Automatically chooses the best loader based on size',
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildLoaderCard(
                          'Small → Icon',
                          SimpleLoaders.auto(
                            width: 80,
                            height: 80,
                            category: 'dessert',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLoaderCard(
                          'Large → Shimmer',
                          SimpleLoaders.auto(
                            width: double.infinity,
                            height: 120,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Category Examples
            _buildSection(
              'Category Examples',
              'Different icons for different food categories',
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildCategoryCard('Pizza', 'pizza')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildCategoryCard('Burger', 'burger')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildCategoryCard('Dessert', 'dessert')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCategoryCard('Beverage', 'beverage'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCategoryCard('Restaurant', 'restaurant'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _buildCategoryCard('General', 'general')),
                    ],
                  ),
                ],
              ),
            ),

            // Color Variations
            _buildSection(
              'Color Variations',
              'Custom colors for different themes',
              Row(
                children: [
                  Expanded(
                    child: _buildLoaderCard(
                      'Primary',
                      SimpleLoaders.icon(
                        width: double.infinity,
                        height: 80,
                        color: AppColors.primaryColor,
                        category: 'pizza',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLoaderCard(
                      'Success',
                      SimpleLoaders.icon(
                        width: double.infinity,
                        height: 80,
                        color: AppColors.successColor,
                        category: 'burger',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLoaderCard(
                      'Secondary',
                      SimpleLoaders.icon(
                        width: double.infinity,
                        height: 80,
                        color: AppColors.secondaryColor,
                        category: 'dessert',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String description, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        content,
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLoaderCard(String title, Widget loader) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: loader,
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, String category) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SimpleLoaders.icon(
            width: double.infinity,
            height: 80,
            category: category,
          ),
        ),
      ],
    );
  }
}
