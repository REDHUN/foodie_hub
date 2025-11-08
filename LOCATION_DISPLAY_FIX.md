# Location Display Fix - Restaurant Cards

## Issue

Restaurant cards were showing incorrect or confusing location information because they displayed the `restaurant.location` field, which is a static text field entered when the restaurant was created, not the actual reverse-geocoded place name.

## Problem

```dart
// Before: Showing potentially wrong location
'${distance} km • ${restaurant.location}'
// Example: "0.5 km • muhamma" (might not be accurate)
```

The `location` field could be:
- Manually entered text (might be wrong)
- Old/outdated information
- Not matching the actual GPS coordinates

## Solution

Changed the display to show only the distance, which is calculated from actual GPS coordinates:

### Small Cards (Horizontal Scroll)
```dart
// After: Show only distance
'${distance} km away'
// Example: "0.5 km away" (accurate from GPS)
```

### Full Cards (All Restaurants Section)
```dart
// After: Show distance if available, otherwise show location field
if (restaurant.distance != null)
  '${distance} km away'
else if (restaurant.location != null)
  restaurant.location  // Fallback for restaurants without GPS
```

## Changes Made

### 1. Small Restaurant Card
**Before:**
```dart
Text(
  '${(restaurant.distance! / 1000).toStringAsFixed(1)} km${restaurant.location != null ? ' • ${restaurant.location}' : ''}',
)
```

**After:**
```dart
Text(
  '${(restaurant.distance! / 1000).toStringAsFixed(1)} km away',
)
```

### 2. Full Restaurant Card
**Before:**
```dart
if (restaurant.distance != null)
  Text('${distance} km • ${restaurant.location}')
else
  Text(restaurant.location ?? restaurant.cuisine)
```

**After:**
```dart
if (restaurant.distance != null)
  Row([
    Icon(Icons.location_on),
    Text('${distance} km away'),
  ])
else if (restaurant.location != null)
  Row([
    Icon(Icons.location_on),
    Text(restaurant.location),
  ])
```

## Display Logic

### Priority Order:
1. **Distance** (if GPS coordinates available) - Most accurate
2. **Location field** (if no GPS) - Fallback
3. **Cuisine** (if nothing else) - Last resort

### Examples:

**With GPS coordinates:**
```
📍 0.5 km away
📍 2.3 km away
📍 4.8 km away
```

**Without GPS coordinates:**
```
📍 Koramangala, Bangalore
📍 Indiranagar
```

## Benefits

✅ **Accurate**: Distance is calculated from actual GPS coordinates
✅ **Clear**: Simple "X km away" message
✅ **Consistent**: Same format for all restaurants with GPS
✅ **No Confusion**: Doesn't show potentially wrong location names
✅ **Clean UI**: Shorter text, easier to read

## Technical Details

### Distance Calculation
```dart
// Distance is in meters from Geolocator
final distanceInKm = restaurant.distance! / 1000;

// Display with 1 decimal place
'${distanceInKm.toStringAsFixed(1)} km away'
```

### Fallback Behavior
```dart
// 1. Try to show distance (most accurate)
if (restaurant.distance != null) {
  return '${distance} km away';
}

// 2. Fallback to location field
else if (restaurant.location != null) {
  return restaurant.location;
}

// 3. Last resort: show cuisine
else {
  return restaurant.cuisine;
}
```

## User Experience

### Before:
- "0.5 km • muhamma" ❌ (confusing, might be wrong)
- "2.3 km • Bangalore" ❌ (too generic)
- "4.8 km • " ❌ (empty location)

### After:
- "0.5 km away" ✅ (clear and accurate)
- "2.3 km away" ✅ (simple and precise)
- "4.8 km away" ✅ (consistent format)

## Files Modified

- `lib/screens/new_home_screen.dart`
  - Updated `_buildRestaurantCard()` - Small card display
  - Updated `_buildFullRestaurantCard()` - Full card display

## Migration Notes

- No database changes needed
- Existing restaurants work as before
- Only UI display logic changed
- Backward compatible

## Future Enhancement (Optional)

If you want to show actual place names in the future, you could:

1. **Reverse geocode restaurant coordinates** when loading:
```dart
final placemark = await placemarkFromCoordinates(
  restaurant.geopoint!.latitude,
  restaurant.geopoint!.longitude,
);
final placeName = placemark.first.locality; // e.g., "Bangalore"
```

2. **Cache the place name** in the restaurant data
3. **Display**: "0.5 km • Koramangala" (accurate place name)

But for now, showing just the distance is clearer and more accurate!
