import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:foodiehub/models/restaurant.dart';

/// Service for geolocation-based restaurant queries using geohash indexing
///
/// This service uses GeoFlutterFire Plus for efficient spatial queries:
/// - Geohash-based indexing for fast radius queries
/// - Automatic distance calculation
/// - Real-time updates via streams
///
/// How it works:
/// 1. Restaurants are stored with a 'position' field containing:
///    - geopoint: GeoPoint(latitude, longitude)
///    - geohash: Generated hash string for spatial indexing
/// 2. Queries use geohash ranges to efficiently filter restaurants
/// 3. Results are sorted by precise distance using Haversine formula
class GeolocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get nearby restaurants sorted by distance using GeoFlutterFire's geohash method
  /// This uses Firebase's geohash indexing for efficient spatial queries
  Stream<List<Restaurant>> getNearbyRestaurantsStream({
    required double userLat,
    required double userLng,
    double radiusInKM = 5.0,
  }) {
    final center = GeoFirePoint(GeoPoint(userLat, userLng));

    // Use GeoFlutterFire's geohash-based query
    // This queries Firebase using geohash ranges for efficient filtering
    return GeoCollectionReference(_firestore.collection('restaurants'))
        .subscribeWithin(
          center: center,
          radiusInKm: radiusInKM,
          field: 'position', // Field containing geohash and geopoint
          geopointFrom: (data) {
            // Extract geopoint from the position field
            if (data['position'] != null &&
                data['position']['geopoint'] != null) {
              return data['position']['geopoint'] as GeoPoint;
            }
            // Return a default GeoPoint if not found (will be filtered out)
            return GeoPoint(0, 0);
          },
          strictMode: false, // Allow documents without position field
        )
        .map((docs) {
          List<Restaurant> restaurants = [];

          for (var doc in docs) {
            try {
              final data = doc.data();
              if (data == null) continue;

              // Calculate precise distance using Haversine formula
              double? distance;
              if (data['position'] != null &&
                  data['position']['geopoint'] != null) {
                final geopoint = data['position']['geopoint'] as GeoPoint;
                distance = Geolocator.distanceBetween(
                  userLat,
                  userLng,
                  geopoint.latitude,
                  geopoint.longitude,
                );
              }

              // Add document ID and distance to data
              final restaurantData = Map<String, dynamic>.from(data);
              restaurantData['id'] = doc.id;
              restaurantData['distance'] = distance;

              restaurants.add(Restaurant.fromJson(restaurantData));
            } catch (e) {
              // Log error but continue processing other restaurants
              print('Error parsing restaurant ${doc.id}: $e');
            }
          }

          // Sort by distance (nearest first)
          restaurants.sort((a, b) {
            if (a.distance == null) return 1;
            if (b.distance == null) return -1;
            return a.distance!.compareTo(b.distance!);
          });

          print(
            'GeolocationService: Found ${restaurants.length} restaurants within ${radiusInKM}km',
          );
          return restaurants;
        });
  }

  /// Get nearby restaurants as a one-time fetch
  Future<List<Restaurant>> getNearbyRestaurants({
    required double userLat,
    required double userLng,
    double radiusInKM = 5.0,
  }) async {
    try {
      final stream = getNearbyRestaurantsStream(
        userLat: userLat,
        userLng: userLng,
        radiusInKM: radiusInKM,
      );

      return await stream.first;
    } catch (e) {
      print('Error fetching nearby restaurants: $e');
      return [];
    }
  }

  /// Get all restaurants sorted by distance using geohash-based querying
  /// Uses GeoFlutterFire's efficient geohash method for better performance
  /// Only returns restaurants within specified radius (default 5km)
  Future<List<Restaurant>> getAllRestaurantsSortedByDistance({
    required double userLat,
    required double userLng,
    double radiusInKM = 5.0,
  }) async {
    try {
      // Use the geohash-based stream method and get first result
      final stream = getNearbyRestaurantsStream(
        userLat: userLat,
        userLng: userLng,
        radiusInKM: radiusInKM,
      );

      return await stream.first;
    } catch (e) {
      print('Error fetching restaurants by distance: $e');

      // Fallback: Manual query if geohash method fails
      return await _fallbackGetRestaurantsByDistance(
        userLat: userLat,
        userLng: userLng,
        radiusInKM: radiusInKM,
      );
    }
  }

  /// Fallback method: Get all restaurants and filter manually
  /// Only used if geohash-based query fails
  Future<List<Restaurant>> _fallbackGetRestaurantsByDistance({
    required double userLat,
    required double userLng,
    double radiusInKM = 5.0,
  }) async {
    try {
      final snapshot = await _firestore.collection('restaurants').get();
      List<Restaurant> restaurants = [];
      final radiusInMeters = radiusInKM * 1000; // Convert km to meters

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();

          // Calculate distance if geopoint exists
          double? distance;
          if (data['position'] != null &&
              data['position']['geopoint'] != null) {
            final geopoint = data['position']['geopoint'] as GeoPoint;
            distance = Geolocator.distanceBetween(
              userLat,
              userLng,
              geopoint.latitude,
              geopoint.longitude,
            );

            // Skip restaurants outside the radius
            if (distance > radiusInMeters) {
              continue;
            }
          } else {
            // Skip restaurants without GPS coordinates
            continue;
          }

          data['id'] = doc.id;
          data['distance'] = distance;

          restaurants.add(Restaurant.fromJson(data));
        } catch (e) {
          print('Error parsing restaurant in fallback: $e');
        }
      }

      // Sort by distance (nearest first)
      restaurants.sort((a, b) {
        if (a.distance == null) return 1;
        if (b.distance == null) return -1;
        return a.distance!.compareTo(b.distance!);
      });

      return restaurants;
    } catch (e) {
      print('Error in fallback method: $e');
      return [];
    }
  }
}
