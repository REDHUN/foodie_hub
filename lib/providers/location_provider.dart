import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:foodiehub/services/restaurant_service.dart';

class LocationProvider with ChangeNotifier {
  String _currentLocation = 'Select Location';
  String _selectedArea = '';
  bool _isInitialized = false;
  final RestaurantService _restaurantService = RestaurantService();
  StreamSubscription<User?>? _authSubscription;

  LocationProvider() {
    // Initialize location when provider is created
    initializeLocationDelayed();

    // Listen to auth state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      handleAuthStateChange,
    );
  }

  String get currentLocation => _currentLocation;
  String get selectedArea => _selectedArea;
  bool get isInitialized => _isInitialized;

  /// Set the current location
  void setLocation(String location, {String area = ''}) {
    _currentLocation = location;
    _selectedArea = area;
    notifyListeners();
  }

  /// Update location from restaurant data
  void updateLocationFromRestaurant(String? restaurantLocation) {
    if (restaurantLocation != null && restaurantLocation.isNotEmpty) {
      setLocation(restaurantLocation);
    }
  }

  /// Get display location with fallback
  String getDisplayLocation() {
    if (_currentLocation == 'Select Location' || _currentLocation.isEmpty) {
      return ''; // Return empty string when no location
    }
    return _currentLocation;
  }

  /// Reset to default location (empty)
  void resetToDefault() {
    setLocation(''); // Set to empty instead of default location
  }

  /// Check if location should be displayed
  bool get shouldShowLocation {
    final location = getDisplayLocation();
    return location.isNotEmpty;
  }

  /// Initialize location on app start
  Future<void> initializeLocation() async {
    if (_isInitialized) return;

    try {
      // Check if restaurant owner is logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.isAnonymous) {
        if (kDebugMode) {
          print(
            'LocationProvider: Found logged-in owner, loading restaurant location',
          );
        }

        // Get restaurant data for the logged-in owner
        final restaurant = await _restaurantService.getRestaurantByOwnerId(
          user.uid,
        );
        if (restaurant != null && restaurant.location != null) {
          setLocation(restaurant.location!);
          if (kDebugMode) {
            print('LocationProvider: Location set to ${restaurant.location}');
          }
        } else {
          if (kDebugMode) {
            print(
              'LocationProvider: No restaurant or location found, using default',
            );
          }
          resetToDefault();
        }
      } else {
        if (kDebugMode) {
          print('LocationProvider: No logged-in owner, using default location');
        }
        resetToDefault();
      }
    } catch (e) {
      if (kDebugMode) {
        print('LocationProvider: Error initializing location: $e');
      }
      resetToDefault();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Initialize location with delay (for app startup)
  Future<void> initializeLocationDelayed() async {
    // Wait a bit for Firebase Auth to initialize
    await Future.delayed(const Duration(milliseconds: 500));
    await initializeLocation();
  }

  /// Handle auth state changes to update location
  Future<void> handleAuthStateChange(User? user) async {
    if (kDebugMode) {
      print('LocationProvider: Auth state changed - ${user?.uid}');
    }

    if (user != null && !user.isAnonymous) {
      // Restaurant owner logged in
      try {
        final restaurant = await _restaurantService.getRestaurantByOwnerId(
          user.uid,
        );
        if (restaurant != null && restaurant.location != null) {
          setLocation(restaurant.location!);
          if (kDebugMode) {
            print(
              'LocationProvider: Updated location to ${restaurant.location} for logged-in owner',
            );
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('LocationProvider: Error updating location on auth change: $e');
        }
      }
    } else {
      // Owner logged out
      resetToDefault();
      if (kDebugMode) {
        print('LocationProvider: Reset to default location on logout');
      }
    }
  }

  /// Check if location is set
  bool get hasLocation =>
      _currentLocation.isNotEmpty && _currentLocation != 'Select Location';

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
