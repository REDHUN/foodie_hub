# Restaurant Provider Refactoring

## Summary

Refactored the `RestaurantProvider` to use a unified stream management approach, reducing code duplication and improving maintainability.

## Changes Made

### Before: Separate Subscribe Methods
Previously, the provider had separate methods for subscribing to regular and geolocation-based streams:
- `_subscribeToRestaurants()` - for regular restaurant stream
- `_subscribeToNearbyRestaurants()` - for geolocation-based stream

This led to code duplication and made it harder to maintain.

### After: Unified Stream Management

#### New `refreshStream()` Method
A single flexible method that automatically chooses the correct stream based on geolocation state:

```dart
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
```

#### Simplified Enable/Disable Methods

**Enable Geolocation:**
```dart
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
```

**Disable Geolocation:**
```dart
Future<void> disableGeolocationSorting() async {
  _useGeolocation = false;
  _userLat = null;
  _userLng = null;
  _isListening = false;
  await refreshStream();
}
```

## Benefits

1. **Less Code Duplication**: Single stream management logic instead of two separate methods
2. **Easier Maintenance**: Changes to stream handling only need to be made in one place
3. **Better Consistency**: Same error handling and loading state management for both stream types
4. **Cleaner API**: Enable/disable methods are now simpler and more focused
5. **Automatic Stream Selection**: The provider automatically chooses the right stream based on state

## Usage

The API remains the same from the consumer's perspective:

```dart
// Enable geolocation-based filtering
await restaurantProvider.enableGeolocationSorting(
  latitude,
  longitude,
  radiusInKM: 5.0,
);

// Disable geolocation and return to regular listing
await restaurantProvider.disableGeolocationSorting();

// Refresh the current stream (respects geolocation state)
await restaurantProvider.refreshStream();
```

## Technical Details

- The `refreshStream()` method uses a ternary operator to select the appropriate stream
- Both enable/disable methods now properly await the stream refresh
- The `_isListening` flag is reset before refreshing to ensure proper state management
- Error handling is unified across both stream types
