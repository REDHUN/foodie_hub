import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:foodiehub/models/restaurant.dart';
import 'package:foodiehub/services/restaurant_service.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantService _restaurantService = RestaurantService();
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Restaurant>>? _subscription;
  bool _isListening = false;

  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RestaurantProvider() {
    _subscribeToRestaurants();
  }

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
    if (!_isListening) {
      _subscribeToRestaurants();
    } else if (!_isLoading && _restaurants.isEmpty) {
      await loadRestaurants();
    }
  }

  void _subscribeToRestaurants() {
    if (_isListening) return;
    _isListening = true;
    _isLoading = true;
    notifyListeners();

    _subscription = _restaurantService.getRestaurantsStream().listen(
      (restaurants) {
        _restaurants = restaurants;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load restaurants: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
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
    return success;
  }

  // Update a restaurant
  Future<bool> updateRestaurant(Restaurant restaurant) async {
    final success = await _restaurantService.updateRestaurant(restaurant);
    return success;
  }

  // Delete a restaurant
  Future<bool> deleteRestaurant(String id) async {
    final success = await _restaurantService.deleteRestaurant(id);
    return success;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
