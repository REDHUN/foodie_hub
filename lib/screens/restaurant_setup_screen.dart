import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  bool _isGettingLocation = false;

  // Store GPS data directly (no need for text controllers)
  GeoPoint? _geopoint;
  String _gpsLocationName = '';

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
                label: 'Location Address',
                hint: 'e.g., Downtown, City Center',
                prefixIcon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // GPS Location Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.my_location,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'GPS Coordinates (Optional)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Display current location if set
                    if (_geopoint != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location Set',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green[900],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _gpsLocationName.isNotEmpty
                                        ? _gpsLocationName
                                        : 'Lat: ${_geopoint!.latitude.toStringAsFixed(4)}, Lng: ${_geopoint!.longitude.toStringAsFixed(4)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.green[700],
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _geopoint = null;
                                  _gpsLocationName = '';
                                });
                              },
                              tooltip: 'Remove location',
                            ),
                          ],
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _isGettingLocation
                            ? null
                            : _getCurrentLocation,
                        icon: _isGettingLocation
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.gps_fixed, size: 18),
                        label: Text(
                          _isGettingLocation
                              ? 'Getting Location...'
                              : 'Set Current Location',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Set GPS location to enable location-based restaurant discovery',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
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

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final locationProvider = context.read<LocationProvider>();
      final position = await locationProvider.getUserLocation();

      if (position != null) {
        setState(() {
          // Store GPS coordinates directly as GeoPoint
          _geopoint = GeoPoint(position.latitude, position.longitude);

          // Store GPS location name
          _gpsLocationName = locationProvider.locationName;

          // Also update location address field if empty
          if (_locationController.text.isEmpty &&
              locationProvider.locationName.isNotEmpty) {
            _locationController.text = locationProvider.locationName;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location obtained successfully! 📍'),
              backgroundColor: AppColors.successColor,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                locationProvider.locationError ?? 'Failed to get location',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
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

      // Use the stored GeoPoint (no parsing needed!)
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
        location: _locationController.text.trim(),
        geopoint: _geopoint, // Use stored GeoPoint directly
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
