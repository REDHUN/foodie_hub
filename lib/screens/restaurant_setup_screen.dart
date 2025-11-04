import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodiehub/models/restaurant.dart';
import 'package:foodiehub/providers/auth_provider.dart';
import 'package:foodiehub/providers/location_provider.dart';
import 'package:foodiehub/services/restaurant_service.dart';
import 'package:foodiehub/utils/constants.dart';
import 'package:foodiehub/widgets/beautiful_button.dart';
import 'package:foodiehub/widgets/beautiful_text_field.dart';
import 'package:provider/provider.dart';

class RestaurantSetupScreen extends StatefulWidget {
  const RestaurantSetupScreen({super.key});

  @override
  State<RestaurantSetupScreen> createState() => _RestaurantSetupScreenState();
}

class _RestaurantSetupScreenState extends State<RestaurantSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _restaurantService = RestaurantService();

  // Form controllers
  final _nameController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _deliveryTimeController = TextEditingController();
  final _deliveryFeeController = TextEditingController();
  final _imageController = TextEditingController();
  final _discountController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cuisineController.dispose();
    _deliveryTimeController.dispose();
    _deliveryFeeController.dispose();
    _imageController.dispose();
    _discountController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your Restaurant'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Restaurant Information',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in your restaurant details to get started',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Restaurant Name
              BeautifulTextField(
                controller: _nameController,
                label: 'Restaurant Name',
                hint: 'Enter your restaurant name',
                prefixIcon: Icons.restaurant,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Restaurant name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Cuisine Type
              BeautifulTextField(
                controller: _cuisineController,
                label: 'Cuisine Type',
                hint: 'e.g., Italian, Chinese, Indian',
                prefixIcon: Icons.restaurant_menu,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Cuisine type is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Location (Required Field)
              BeautifulTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'e.g., Downtown, City Center',
                prefixIcon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Delivery Time
              BeautifulTextField(
                controller: _deliveryTimeController,
                label: 'Delivery Time',
                hint: 'e.g., 30-45 mins',
                prefixIcon: Icons.access_time,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Delivery time is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Delivery Fee
              BeautifulTextField(
                controller: _deliveryFeeController,
                label: 'Delivery Fee (₹)',
                hint: 'Enter delivery fee',
                prefixIcon: Icons.delivery_dining,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Delivery fee is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Restaurant Image URL
              BeautifulTextField(
                controller: _imageController,
                label: 'Restaurant Image URL',
                hint: 'Enter image URL',
                prefixIcon: Icons.image,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Image URL is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Discount Offer (Optional)
              BeautifulTextField(
                controller: _discountController,
                label: 'Discount Offer (Optional)',
                hint: 'e.g., 50% OFF UPTO ₹100',
                prefixIcon: Icons.local_offer,
              ),
              const SizedBox(height: 32),

              // Create Restaurant Button
              SizedBox(
                width: double.infinity,
                child: BeautifulButton(
                  text: _isLoading
                      ? 'Creating Restaurant...'
                      : 'Create Restaurant',
                  onPressed: _isLoading ? null : _createRestaurant,
                  isLoading: _isLoading,
                ),
              ),
              const SizedBox(height: 20),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Important',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Make sure to provide accurate information. You can edit these details later from your dashboard.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createRestaurant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;

      if (user == null) {
        throw Exception('You must be logged in to create a restaurant');
      }

      // Check if user already has a restaurant
      final existingRestaurant = await _restaurantService
          .getRestaurantByOwnerId(user.uid);
      if (existingRestaurant != null) {
        throw Exception('You already have a restaurant registered');
      }

      final deliveryFee =
          double.tryParse(_deliveryFeeController.text.trim()) ?? 0.0;

      final restaurant = Restaurant(
        id: 'restaurant_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        cuisine: _cuisineController.text.trim(),
        rating: 4.0, // Default rating for new restaurants
        deliveryTime: _deliveryTimeController.text.trim(),
        deliveryFee: deliveryFee,
        image: _imageController.text.trim(),
        discount: _discountController.text.trim().isEmpty
            ? null
            : _discountController.text.trim(),
        ownerId: user.uid,
        location: _locationController.text.trim(), // Include location field
      );

      final success = await _restaurantService.addRestaurant(restaurant);

      if (!mounted) return;

      if (success) {
        // Update location provider with the new restaurant location
        final locationProvider = context.read<LocationProvider>();
        locationProvider.updateLocationFromRestaurant(restaurant.location);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restaurant created successfully! 🎉'),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back or to dashboard
        Navigator.of(context).pop();
      } else {
        throw Exception('Failed to create restaurant');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
