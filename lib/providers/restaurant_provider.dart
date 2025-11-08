import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:foodiehub/models/restaurant.dart';
import 'package:foodiehub/services/geolocation_service.dart';
import 'package:foodiehub/services/restaurant_service.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantService _restaurantService = RestaurantService();
  final GeolocationService _geolocationService = GeolocationService();
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Restaurant>>? _subscription;
  bool _isListening = false;
  bool _useGeolocation = false;
  double? _userLat;
  double? _userLng;
  double _radiusInKM = 30.0;

  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get useGeolocation => _useGeolocation;
  double get radiusInKM => _radiusInKM;

  RestaurantProvider() {
    // Don't auto-subscribe - wait for GPS location first
    // _subscribeToRestaurants();
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
      await refreshStream();
    } else if (!_isLoading && _restaurants.isEmpty) {
      await loadRestaurants();
    }
  }

  /// Unified method to refresh the restaurant stream
  /// Automatically uses geolocation stream if enabled, otherwise uses regular stream
  Future<void> refreshStream() async {
    _subscription?.cancel();
    _isListening = true;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final stream = _useGeolocation && _userLat != null && _userLng != null
        ? _geolocationService.getNearbyRestaurantsStream(
            userLat: _userLat!,
            userLng: _userLng!,
            radiusInKM: _radiusInKM,
          )
        : _restaurantService.getRestaurantsStream();

    _subscription = stream.listen(
      (data) {
        _restaurants = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load restaurants: $e';
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

  /// Enable geolocation-based sorting
  Future<void> enableGeolocationSorting(
    double userLat,
    double userLng, {
    double radiusInKM = 30.0,
  }) async {
    _useGeolocation = true;
    _userLat = userLat;
    _userLng = userLng;
    _radiusInKM = radiusInKM;
    _isListening = false;
    await refreshStream();
  }

  /// Disable geolocation and use regular sorting
  Future<void> disableGeolocationSorting() async {
    _useGeolocation = false;
    _userLat = null;
    _userLng = null;
    _isListening = false;
    await refreshStream();
  }

  /// Load restaurants sorted by distance (one-time fetch)
  Future<void> loadRestaurantsByDistance(
    double userLat,
    double userLng, {
    double radiusInKM = 30.0,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _restaurants = await _geolocationService
          .getAllRestaurantsSortedByDistance(
            userLat: userLat,
            userLng: userLng,
            radiusInKM: radiusInKM,
          );
      _error = null;
    } catch (e) {
      _error = 'Failed to load restaurants: $e';
      _restaurants = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
