import 'dart:math';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility class for geohash operations and distance calculations
class GeohashUtils {
  /// Calculate distance between two geohashes in kilometers
  ///
  /// Example:
  /// ```dart
  /// final distance = GeohashUtils.distanceFromGeohashes('tdr1y7h8', 'tdr1y7h9');
  /// print('Distance: $distance km');
  /// ```
  static double distanceFromGeohashes(String hash1, String hash2) {
    final coord1 = _decodeGeohash(hash1);
    final coord2 = _decodeGeohash(hash2);

    return haversineDistance(
      coord1.latitude,
      coord1.longitude,
      coord2.latitude,
      coord2.longitude,
    );
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  ///
  /// Example:
  /// ```dart
  /// final distance = GeohashUtils.haversineDistance(12.9716, 77.5946, 12.9352, 77.6245);
  /// print('Distance: $distance km');
  /// ```
  static double haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Earth radius in km

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // distance in km
  }

  /// Calculate distance in meters (for compatibility with Geolocator)
  static double haversineDistanceInMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return haversineDistance(lat1, lon1, lat2, lon2) * 1000;
  }

  /// Convert degrees to radians
  static double _toRadians(double degrees) => degrees * pi / 180;

  /// Decode geohash to coordinates
  /// Returns a GeoPoint with latitude and longitude
  static GeoPoint _decodeGeohash(String geohash) {
    // Use GeoFlutterFire to decode geohash
    // This is a simplified version - GeoFlutterFire handles the complex decoding

    // For now, we'll use a basic decoding algorithm
    const base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
    final bounds = _Bounds(
      minLat: -90.0,
      maxLat: 90.0,
      minLon: -180.0,
      maxLon: 180.0,
    );

    bool isEven = true;
    for (int i = 0; i < geohash.length; i++) {
      final char = geohash[i];
      final idx = base32.indexOf(char);

      if (idx == -1) {
        throw ArgumentError('Invalid geohash character: $char');
      }

      for (int n = 4; n >= 0; n--) {
        final bitN = (idx >> n) & 1;
        if (isEven) {
          // longitude
          final mid = (bounds.minLon + bounds.maxLon) / 2;
          if (bitN == 1) {
            bounds.minLon = mid;
          } else {
            bounds.maxLon = mid;
          }
        } else {
          // latitude
          final mid = (bounds.minLat + bounds.maxLat) / 2;
          if (bitN == 1) {
            bounds.minLat = mid;
          } else {
            bounds.maxLat = mid;
          }
        }
        isEven = !isEven;
      }
    }

    final lat = (bounds.minLat + bounds.maxLat) / 2;
    final lon = (bounds.minLon + bounds.maxLon) / 2;

    return GeoPoint(lat, lon);
  }

  /// Encode coordinates to geohash
  ///
  /// Example:
  /// ```dart
  /// final geohash = GeohashUtils.encodeGeohash(12.9716, 77.5946);
  /// print('Geohash: $geohash'); // Output: tdr1y7h8...
  /// ```
  static String encodeGeohash(
    double latitude,
    double longitude, {
    int precision = 9,
  }) {
    final geopoint = GeoPoint(latitude, longitude);
    final geoFirePoint = GeoFirePoint(geopoint);
    return geoFirePoint.geohash.substring(0, precision);
  }

  /// Get geohash from GeoPoint
  static String geohashFromGeoPoint(GeoPoint geopoint, {int precision = 9}) {
    return encodeGeohash(
      geopoint.latitude,
      geopoint.longitude,
      precision: precision,
    );
  }

  /// Check if two locations are within a certain distance (in km)
  ///
  /// Example:
  /// ```dart
  /// final isNearby = GeohashUtils.isWithinDistance(
  ///   12.9716, 77.5946,
  ///   12.9352, 77.6245,
  ///   maxDistanceKm: 5.0,
  /// );
  /// ```
  static bool isWithinDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2, {
    required double maxDistanceKm,
  }) {
    final distance = haversineDistance(lat1, lon1, lat2, lon2);
    return distance <= maxDistanceKm;
  }

  /// Get the approximate error margin for a geohash precision
  /// Returns error in kilometers
  static double getGeohashPrecisionError(int precision) {
    // Approximate error margins for different geohash lengths
    const errorMargins = {
      1: 5000.0, // ±5000 km
      2: 1250.0, // ±1250 km
      3: 156.0, // ±156 km
      4: 39.1, // ±39.1 km
      5: 4.9, // ±4.9 km
      6: 1.2, // ±1.2 km
      7: 0.152, // ±152 m
      8: 0.038, // ±38 m
      9: 0.0047, // ±4.7 m
      10: 0.0012, // ±1.2 m
    };

    return errorMargins[precision] ?? 0.0047;
  }

  /// Format distance for display
  ///
  /// Example:
  /// ```dart
  /// print(GeohashUtils.formatDistance(0.5));  // "500 m"
  /// print(GeohashUtils.formatDistance(1.2));  // "1.2 km"
  /// print(GeohashUtils.formatDistance(15.7)); // "15.7 km"
  /// ```
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()} m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }
}

/// Helper class for geohash bounds
class _Bounds {
  double minLat;
  double maxLat;
  double minLon;
  double maxLon;

  _Bounds({
    required this.minLat,
    required this.maxLat,
    required this.minLon,
    required this.maxLon,
  });
}
