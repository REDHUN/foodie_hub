import 'package:flutter/foundation.dart';
import 'package:foodiehub/models/restaurant.dart';
import 'package:foodiehub/services/restaurant_service.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantService _restaurantService = RestaurantService();
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String? _error;

  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load restaurants from Firebase
  Future<void> loadRestaurants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _restaurants = await _restaurantService.getRestaurants();
      _error = null;
    } catch (e) {
      _error = 'Failed to load restaurants: $e';
      _restaurants = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load initial data if Firebase is empty
  Future<void> initializeRestaurants() async {
    // First, try to load from Firebase
    await loadRestaurants();

    // If Firebase is empty, add sample data
    if (_restaurants.isEmpty) {
      //  await _addSampleRestaurants();
    }
  }

  Future<void> _addSampleRestaurants() async {
    // Add sample restaurants to Firebase
    // This is a one-time setup when Firebase is empty
    // You can comment this out after initial setup
  }

  // Get restaurant by ID
  Restaurant? getRestaurantById(String id) {
    try {
      return _restaurants.firstWhere((restaurant) => restaurant.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add a new restaurant
  Future<bool> addRestaurant(Restaurant restaurant) async {
    final success = await _restaurantService.addRestaurant(restaurant);
    if (success) {
      await loadRestaurants();
    }
    return success;
  }

  // Update a restaurant
  Future<bool> updateRestaurant(Restaurant restaurant) async {
    final success = await _restaurantService.updateRestaurant(restaurant);
    if (success) {
      await loadRestaurants();
    }
    return success;
  }

  // Delete a restaurant
  Future<bool> deleteRestaurant(String id) async {
    final success = await _restaurantService.deleteRestaurant(id);
    if (success) {
      await loadRestaurants();
    }
    return success;
  }
}
