import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodiehub/utils/geohash_utils.dart';

/// Example usage of GeohashUtils in the FoodieHub app
class GeohashExample {
  /// Example 1: Calculate distance between two geohashes
  void example1() {
    print('=== Example 1: Distance from Geohashes ===');

    final hash1 = 'tdr1y7h8'; // Restaurant 1
    final hash2 = 'tdr1y7h9'; // Restaurant 2

    final distance = GeohashUtils.distanceFromGeohashes(hash1, hash2);

    print('Distance: ${GeohashUtils.formatDistance(distance)}');
    print('');
  }

  /// Example 2: Calculate distance between coordinates
  void example2() {
    print('=== Example 2: Distance from Coordinates ===');

    // Bangalore coordinates
    final bangaloreLat = 12.9716;
    final bangaloreLng = 77.5946;

    // Chennai coordinates
    final chennaiLat = 13.0827;
    final chennaiLng = 80.2707;

    final distance = GeohashUtils.haversineDistance(
      bangaloreLat,
      bangaloreLng,
      chennaiLat,
      chennaiLng,
    );

    print('Bangalore to Chennai: ${GeohashUtils.formatDistance(distance)}');
    print('');
  }

  /// Example 3: Encode coordinates to geohash
  void example3() {
    print('=== Example 3: Encode Geohash ===');

    final lat = 12.9716;
    final lng = 77.5946;

    final geohash = GeohashUtils.encodeGeohash(lat, lng, precision: 9);

    print('Coordinates: ($lat, $lng)');
    print('Geohash: $geohash');
    print('');
  }

  /// Example 4: Check if restaurant is nearby
  void example4() {
    print('=== Example 4: Check if Nearby ===');

    final userLat = 12.9716;
    final userLng = 77.5946;

    final restaurantLat = 12.9352;
    final restaurantLng = 77.6245;

    final isNearby = GeohashUtils.isWithinDistance(
      userLat,
      userLng,
      restaurantLat,
      restaurantLng,
      maxDistanceKm: 5.0,
    );

    final distance = GeohashUtils.haversineDistance(
      userLat,
      userLng,
      restaurantLat,
      restaurantLng,
    );

    print('User location: ($userLat, $userLng)');
    print('Restaurant location: ($restaurantLat, $restaurantLng)');
    print('Distance: ${GeohashUtils.formatDistance(distance)}');
    print('Within 5km? ${isNearby ? "Yes ✅" : "No ❌"}');
    print('');
  }

  /// Example 5: Format distances
  void example5() {
    print('=== Example 5: Format Distances ===');

    final distances = [0.05, 0.5, 1.2, 5.7, 15.3, 100.0];

    for (final distance in distances) {
      print('${distance} km = ${GeohashUtils.formatDistance(distance)}');
    }
    print('');
  }

  /// Example 6: Geohash precision errors
  void example6() {
    print('=== Example 6: Geohash Precision ===');

    for (int precision = 1; precision <= 9; precision++) {
      final error = GeohashUtils.getGeohashPrecisionError(precision);
      print('Precision $precision: ±${GeohashUtils.formatDistance(error)}');
    }
    print('');
  }

  /// Example 7: Working with GeoPoint
  void example7() {
    print('=== Example 7: GeoPoint to Geohash ===');

    final geopoint = GeoPoint(12.9716, 77.5946);
    final geohash = GeohashUtils.geohashFromGeoPoint(geopoint, precision: 8);

    print('GeoPoint: (${geopoint.latitude}, ${geopoint.longitude})');
    print('Geohash: $geohash');
    print('');
  }

  /// Run all examples
  void runAllExamples() {
    print('\n🌍 Geohash Utils Examples\n');

    example1();
    example2();
    example3();
    example4();
    example5();
    example6();
    example7();

    print('✅ All examples completed!\n');
  }
}

/// Main function to run examples
void main() {
  final examples = GeohashExample();
  examples.runAllExamples();
}
