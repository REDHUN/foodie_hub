import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:foodiehub/services/restaurant_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider with ChangeNotifier {
  String _currentLocation = 'Select Location';
  String _selectedArea = '';
  bool _isInitialized = false;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  String? _locationError;
  String _locationName = '';
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
  Position? get currentPosition => _currentPosition;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get locationError => _locationError;
  String get locationName => _locationName;

  double? get userLatitude => _currentPosition?.latitude;
  double? get userLongitude => _currentPosition?.longitude;

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

  /// Request and get user's current GPS location
  Future<Position?> getUserLocation() async {
    _isLoadingLocation = true;
    _locationError = null;
    notifyListeners();

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationError = 'Location services are disabled';
        if (kDebugMode) {
          print('LocationProvider: Location services are disabled');
        }
        _isLoadingLocation = false;
        notifyListeners();
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationError = 'Location permissions are denied';
          if (kDebugMode) {
            print('LocationProvider: Location permissions denied');
          }
          _isLoadingLocation = false;
          notifyListeners();
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _locationError = 'Location permissions are permanently denied';
        if (kDebugMode) {
          print('LocationProvider: Location permissions permanently denied');
        }
        _isLoadingLocation = false;
        notifyListeners();
        return null;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (kDebugMode) {
        print(
          'LocationProvider: Got GPS location - Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}',
        );
      }

      // Get location name using reverse geocoding
      await _getLocationName(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      _isLoadingLocation = false;
      notifyListeners();
      return _currentPosition;
    } catch (e) {
      _locationError = 'Failed to get location: $e';
      if (kDebugMode) {
        print('LocationProvider: Error getting location: $e');
      }
      _isLoadingLocation = false;
      notifyListeners();
      return null;
    }
  }

  /// Get location name from coordinates (reverse geocoding)
  Future<void> _getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // Build location name from available components
        List<String> locationParts = [];

        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          locationParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          locationParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          locationParts.add(place.administrativeArea!);
        }

        _locationName = locationParts.isNotEmpty
            ? locationParts.join(', ')
            : 'Current Location';

        _currentLocation = _locationName;

        if (kDebugMode) {
          print('LocationProvider: Location name: $_locationName');
        }
      } else {
        _locationName = 'Current Location';
        _currentLocation = _locationName;
      }
    } catch (e) {
      if (kDebugMode) {
        print('LocationProvider: Error getting location name: $e');
      }
      _locationName = 'Current Location';
      _currentLocation = _locationName;
    }
  }

  /// Get coordinates from address (forward geocoding)
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        final location = locations.first;
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('LocationProvider: Error getting coordinates from address: $e');
      }
      return null;
    }
  }

  /// Calculate distance between two points in meters
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
