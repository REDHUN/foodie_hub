# Distance and Delivery Time Display on Restaurant Cards

## Implementation Summary

Added distance and estimated delivery time information to restaurant cards throughout the home screen.

## Changes Made

### 1. Restaurant Card Display (Horizontal Scroll)
- **Location**: `_buildRestaurantCard()` method
- **Features**:
  - Shows distance in km (e.g., "5.6 km")
  - Displays location name if available
  - Calculates estimated delivery time based on distance
  - Format: "5.6 km • Location Name"

### 2. Full Restaurant Card Display (All Restaurants Section)
- **Location**: `_buildFullRestaurantCard()` method
- **Features**:
  - Shows distance in km with location icon
  - Displays location name if available
  - Calculates estimated delivery time based on distance
  - Format: "5.6 km • Location Name"

## Delivery Time Calculation

The estimated delivery time is calculated dynamically based on the restaurant's distance:

```dart
// Convert distance from meters to km
final distanceInKm = restaurant.distance! / 1000;

// Estimate: 5 min base + 5 min per km
final minTime = 5 + (distanceInKm * 5).round();
final maxTime = minTime + 15;
estimatedTime = '$minTime-$maxTime min';
```

### Examples:
- **1 km away**: 10-25 min
- **2 km away**: 15-30 min
- **3 km away**: 20-35 min
- **5 km away**: 30-45 min

## Display Format

### Small Cards (Top-rated section):
```
Restaurant Name
⭐ 4.5  30-45 min
📍 5.6 km • Koramangala
```

### Full Cards (All Restaurants section):
```
Restaurant Name
⭐ 4.5  30-45 min
📍 5.6 km • Koramangala
Italian, Pizza
₹40 delivery fee
```

## Technical Details

- Distance is stored in meters in the database
- Converted to kilometers for display: `distance / 1000`
- Location field from Restaurant model is used for place name
- Falls back to cuisine if distance/location not available
- Icon color matches app primary color for consistency

## User Experience

- Users can quickly see how far restaurants are
- Estimated delivery time helps with decision making
- Location name provides context about the area
- Visual indicators (icons) make information scannable
