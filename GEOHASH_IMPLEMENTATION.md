# Geohash-Based Location Queries Implementation

## Overview

The app now uses **geohash-based spatial indexing** for efficient location queries. This is significantly faster than scanning all restaurants and calculating distances manually.

## What is Geohash?

Geohash is a geocoding system that encodes geographic coordinates into a short string of letters and digits. Nearby locations share similar geohash prefixes, making it perfect for spatial queries.

**Example:**
- Location A: `tdr1y` (Bangalore, India)
- Location B: `tdr1z` (Nearby in Bangalore)
- Location C: `u4pru` (Mumbai, India - different prefix)

## How It Works

### 1. Data Storage

Each restaurant is stored with a `position` field containing:

```json
{
  "name": "Pizza Hut",
  "position": {
    "geopoint": GeoPoint(12.9716, 77.5946),
    "geohash": "tdr1y7h8"
  }
}
```

The geohash is automatically generated when saving:

```dart
if (geopoint != null) {
  final geoFirePoint = GeoFirePoint(geopoint!);
  json['position'] = {
    'geopoint': geopoint,
    'geohash': geoFirePoint.geohash,
  };
}
```

### 2. Querying

When searching for nearby restaurants:

```dart
final center = GeoFirePoint(GeoPoint(userLat, userLng));

GeoCollectionReference(_firestore.collection('restaurants'))
  .subscribeWithin(
    center: center,
    radiusInKm: 5.0,
    field: 'position',
    geopointFrom: (data) => data['position']['geopoint'],
  )
```

**What happens:**
1. Calculate geohash for user's location
2. Generate geohash ranges that cover the radius
3. Query Firebase using these ranges (very fast!)
4. Calculate precise distances for results
5. Sort by distance

### 3. Performance Benefits

**Without Geohash (Old Method):**
- Fetch ALL restaurants from database
- Calculate distance for EACH restaurant
- Filter by radius
- Sort by distance
- **Time: O(n)** where n = total restaurants

**With Geohash (New Method):**
- Query only restaurants in geohash range
- Calculate distance for FILTERED results only
- Sort by distance
- **Time: O(log n + m)** where m = restaurants in radius

**Example:**
- 10,000 restaurants in database
- 50 restaurants within 5km
- Old method: Calculate 10,000 distances
- New method: Calculate ~50 distances
- **~200x faster!**

## Implementation Details

### GeolocationService Methods

#### 1. Stream-Based Query (Real-time)
```dart
Stream<List<Restaurant>> getNearbyRestaurantsStream({
  required double userLat,
  required double userLng,
  double radiusInKM = 5.0,
})
```
- Returns a stream that updates in real-time
- Uses geohash for efficient filtering
- Automatically sorts by distance

#### 2. One-Time Fetch
```dart
Future<List<Restaurant>> getNearbyRestaurants({
  required double userLat,
  required double userLng,
  double radiusInKM = 5.0,
})
```
- Gets first result from stream
- Good for one-time queries

#### 3. Sorted Distance Query
```dart
Future<List<Restaurant>> getAllRestaurantsSortedByDistance({
  required double userLat,
  required double userLng,
  double radiusInKM = 5.0,
})
```
- Primary method used by RestaurantProvider
- Uses geohash method with fallback
- Returns sorted list by distance

### Fallback Mechanism

If geohash query fails (e.g., network issues), the service falls back to manual filtering:

```dart
Future<List<Restaurant>> _fallbackGetRestaurantsByDistance({
  required double userLat,
  required double userLng,
  double radiusInKM = 5.0,
})
```

This ensures the app always works, even if the geohash query has issues.

## Firebase Index Requirements

For optimal performance, create a composite index in Firebase:

**Collection:** `restaurants`
**Fields:**
- `position.geohash` (Ascending)
- `position.geopoint` (Ascending)

This index is automatically suggested by Firebase when you first run the query.

## Distance Calculation

After geohash filtering, precise distances are calculated using the **Haversine formula**:

```dart
distance = Geolocator.distanceBetween(
  userLat,
  userLng,
  restaurantLat,
  restaurantLng,
);
```

This gives accurate distances in meters, accounting for Earth's curvature.

## Usage in App

### Home Screen
```dart
// Load restaurants within 5km using geohash
await restaurantProvider.loadRestaurantsByDistance(
  position.latitude,
  position.longitude,
  radiusInKM: 5.0,
);
```

### Restaurant Provider
```dart
// Enable geolocation with stream updates
await restaurantProvider.enableGeolocationSorting(
  latitude,
  longitude,
  radiusInKM: 5.0,
);
```

## Benefits Summary

✅ **Fast Queries**: Only fetch nearby restaurants, not all restaurants
✅ **Scalable**: Performance doesn't degrade as database grows
✅ **Real-time**: Stream-based updates when restaurants change
✅ **Accurate**: Precise distance calculation using Haversine formula
✅ **Reliable**: Fallback mechanism if geohash query fails
✅ **Efficient**: Reduces Firebase read operations (saves costs)

## Technical Stack

- **geoflutterfire_plus**: ^0.0.4 - Geohash generation and queries
- **geolocator**: ^13.0.2 - Distance calculation and GPS access
- **cloud_firestore**: Firebase backend with geohash indexing

## Debugging

To verify geohash is working, check the logs:

```
GeolocationService: Found 12 restaurants within 5.0km
```

If you see this message, geohash queries are working correctly!

## Migration Notes

Existing restaurants without geohash will be automatically updated when:
1. Restaurant owner edits the restaurant
2. New restaurants are created with GPS coordinates

The `position` field with geohash is generated in `Restaurant.toJson()`:

```dart
if (geopoint != null) {
  final geoFirePoint = GeoFirePoint(geopoint!);
  json['position'] = {
    'geopoint': geopoint,
    'geohash': geoFirePoint.geohash,
  };
}
```
