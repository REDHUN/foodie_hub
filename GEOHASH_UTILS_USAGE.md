# Geohash Utils - Usage Guide

## Overview

The `GeohashUtils` class provides utility functions for geohash operations and distance calculations in Flutter, similar to the JavaScript geohash library.

## Installation

No additional packages needed! The utility uses:
- `geoflutterfire_plus` (already installed)
- `cloud_firestore` (already installed)
- `dart:math` (built-in)

## Usage Examples

### 1. Calculate Distance Between Two Geohashes

```dart
import 'package:foodiehub/utils/geohash_utils.dart';

// Calculate distance between two geohashes
final distance = GeohashUtils.distanceFromGeohashes(
  'tdr1y7h8',  // Restaurant 1 geohash
  'tdr1y7h9',  // Restaurant 2 geohash
);

print('Distance: ${distance.toStringAsFixed(2)} km');
// Output: Distance: 0.15 km
```

### 2. Calculate Distance Between Coordinates

```dart
// Using Haversine formula
final distance = GeohashUtils.haversineDistance(
  12.9716, 77.5946,  // Bangalore coordinates
  12.9352, 77.6245,  // Another location
);

print('Distance: ${distance.toStringAsFixed(2)} km');
// Output: Distance: 5.23 km
```

### 3. Calculate Distance in Meters

```dart
final distanceInMeters = GeohashUtils.haversineDistanceInMeters(
  12.9716, 77.5946,
  12.9352, 77.6245,
);

print('Distance: ${distanceInMeters.toStringAsFixed(0)} m');
// Output: Distance: 5230 m
```

### 4. Encode Coordinates to Geohash

```dart
final geohash = GeohashUtils.encodeGeohash(
  12.9716,  // latitude
  77.5946,  // longitude
  precision: 9,  // optional, default is 9
);

print('Geohash: $geohash');
// Output: Geohash: tdr1y7h8q
```

### 5. Check if Locations are Within Distance

```dart
final isNearby = GeohashUtils.isWithinDistance(
  12.9716, 77.5946,  // User location
  12.9352, 77.6245,  // Restaurant location
  maxDistanceKm: 5.0,
);

if (isNearby) {
  print('Restaurant is within 5km!');
} else {
  print('Restaurant is too far away');
}
```

### 6. Format Distance for Display

```dart
print(GeohashUtils.formatDistance(0.5));   // "500 m"
print(GeohashUtils.formatDistance(1.2));   // "1.2 km"
print(GeohashUtils.formatDistance(15.7));  // "15.7 km"
```

### 7. Get Geohash from GeoPoint

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

final geopoint = GeoPoint(12.9716, 77.5946);
final geohash = GeohashUtils.geohashFromGeoPoint(geopoint);

print('Geohash: $geohash');
```

### 8. Get Geohash Precision Error

```dart
// Check accuracy for different precision levels
for (int i = 1; i <= 9; i++) {
  final error = GeohashUtils.getGeohashPrecisionError(i);
  print('Precision $i: ±${error} km');
}

// Output:
// Precision 1: ±5000.0 km
// Precision 2: ±1250.0 km
// Precision 3: ±156.0 km
// Precision 4: ±39.1 km
// Precision 5: ±4.9 km
// Precision 6: ±1.2 km
// Precision 7: ±0.152 km (152 m)
// Precision 8: ±0.038 km (38 m)
// Precision 9: ±0.0047 km (4.7 m)
```

## Real-World Examples

### Example 1: Find Nearby Restaurants

```dart
import 'package:foodiehub/utils/geohash_utils.dart';

class RestaurantFinder {
  List<Restaurant> findNearbyRestaurants(
    double userLat,
    double userLng,
    List<Restaurant> allRestaurants,
    double maxDistanceKm,
  ) {
    return allRestaurants.where((restaurant) {
      if (restaurant.geopoint == null) return false;
      
      return GeohashUtils.isWithinDistance(
        userLat,
        userLng,
        restaurant.geopoint!.latitude,
        restaurant.geopoint!.longitude,
        maxDistanceKm: maxDistanceKm,
      );
    }).toList();
  }
}
```

### Example 2: Sort Restaurants by Distance

```dart
List<Restaurant> sortRestaurantsByDistance(
  double userLat,
  double userLng,
  List<Restaurant> restaurants,
) {
  // Calculate distance for each restaurant
  final restaurantsWithDistance = restaurants.map((restaurant) {
    if (restaurant.geopoint == null) {
      return MapEntry(restaurant, double.infinity);
    }
    
    final distance = GeohashUtils.haversineDistance(
      userLat,
      userLng,
      restaurant.geopoint!.latitude,
      restaurant.geopoint!.longitude,
    );
    
    return MapEntry(restaurant, distance);
  }).toList();
  
  // Sort by distance
  restaurantsWithDistance.sort((a, b) => a.value.compareTo(b.value));
  
  return restaurantsWithDistance.map((e) => e.key).toList();
}
```

### Example 3: Display Distance in UI

```dart
Widget buildRestaurantCard(Restaurant restaurant, double userLat, double userLng) {
  final distance = restaurant.geopoint != null
      ? GeohashUtils.haversineDistance(
          userLat,
          userLng,
          restaurant.geopoint!.latitude,
          restaurant.geopoint!.longitude,
        )
      : null;

  return Card(
    child: ListTile(
      title: Text(restaurant.name),
      subtitle: distance != null
          ? Text('${GeohashUtils.formatDistance(distance)} away')
          : Text('Distance unknown'),
    ),
  );
}
```

### Example 4: Compare Two Geohashes

```dart
void compareRestaurantLocations(Restaurant r1, Restaurant r2) {
  if (r1.geopoint == null || r2.geopoint == null) {
    print('Missing location data');
    return;
  }
  
  // Get geohashes
  final hash1 = GeohashUtils.geohashFromGeoPoint(r1.geopoint!);
  final hash2 = GeohashUtils.geohashFromGeoPoint(r2.geopoint!);
  
  // Calculate distance
  final distance = GeohashUtils.distanceFromGeohashes(hash1, hash2);
  
  print('${r1.name} and ${r2.name} are ${GeohashUtils.formatDistance(distance)} apart');
}
```

## API Reference

### Methods

| Method | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `distanceFromGeohashes` | `String hash1, String hash2` | `double` | Distance in km between two geohashes |
| `haversineDistance` | `double lat1, lon1, lat2, lon2` | `double` | Distance in km using Haversine formula |
| `haversineDistanceInMeters` | `double lat1, lon1, lat2, lon2` | `double` | Distance in meters |
| `encodeGeohash` | `double lat, lon, {int precision}` | `String` | Encode coordinates to geohash |
| `geohashFromGeoPoint` | `GeoPoint geopoint, {int precision}` | `String` | Get geohash from GeoPoint |
| `isWithinDistance` | `double lat1, lon1, lat2, lon2, {double maxDistanceKm}` | `bool` | Check if within distance |
| `formatDistance` | `double distanceInKm` | `String` | Format distance for display |
| `getGeohashPrecisionError` | `int precision` | `double` | Get error margin for precision |

## Haversine Formula

The Haversine formula calculates the great-circle distance between two points on a sphere given their longitudes and latitudes.

**Formula:**
```
a = sin²(Δφ/2) + cos φ1 ⋅ cos φ2 ⋅ sin²(Δλ/2)
c = 2 ⋅ atan2(√a, √(1−a))
d = R ⋅ c
```

Where:
- φ = latitude
- λ = longitude
- R = Earth's radius (6371 km)
- d = distance

## Geohash Precision

| Precision | Cell Width | Cell Height | Example Use Case |
|-----------|-----------|-------------|------------------|
| 1 | ±2500 km | ±5000 km | Continent |
| 2 | ±630 km | ±1250 km | Large region |
| 3 | ±78 km | ±156 km | City |
| 4 | ±20 km | ±39 km | District |
| 5 | ±2.4 km | ±4.9 km | Neighborhood |
| 6 | ±0.61 km | ±1.2 km | Street |
| 7 | ±0.076 km | ±0.15 km | Building |
| 8 | ±0.019 km | ±0.038 km | House |
| 9 | ±0.0024 km | ±0.0047 km | Room |

**Recommendation:** Use precision 8-9 for restaurant locations.

## Performance

- **Geohash comparison**: O(1) - Very fast
- **Haversine calculation**: O(1) - Fast
- **Distance from geohash**: O(n) where n = geohash length - Still very fast

## Integration with Existing Code

The utility works seamlessly with your existing geolocation service:

```dart
// In GeolocationService
import 'package:foodiehub/utils/geohash_utils.dart';

// You can now use GeohashUtils instead of Geolocator.distanceBetween
distance = GeohashUtils.haversineDistanceInMeters(
  userLat,
  userLng,
  geopoint.latitude,
  geopoint.longitude,
);
```

## Testing

```dart
void testGeohashUtils() {
  // Test distance calculation
  final distance = GeohashUtils.haversineDistance(
    12.9716, 77.5946,  // Bangalore
    13.0827, 80.2707,  // Chennai
  );
  
  assert(distance > 300 && distance < 350, 'Distance should be ~330 km');
  
  // Test geohash encoding
  final geohash = GeohashUtils.encodeGeohash(12.9716, 77.5946);
  assert(geohash.startsWith('tdr1'), 'Geohash should start with tdr1');
  
  print('All tests passed! ✅');
}
```

## Notes

- All distances are calculated using the Haversine formula for accuracy
- Earth's radius is assumed to be 6371 km (mean radius)
- Geohash precision of 9 provides ~4.7m accuracy
- The utility is compatible with Firebase GeoPoint objects
