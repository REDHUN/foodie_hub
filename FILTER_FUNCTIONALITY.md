# Filter Functionality - Home Screen

## Overview
Added comprehensive filter functionality to the home screen similar to popular food delivery apps like Swiggy/Zomato.

## Features Added

### 1. **Sort By Filter**
- **Options**: Relevance, Rating: High to Low, Delivery Time, Cost: Low to High, Cost: High to Low
- **UI**: Dropdown chip with arrow indicator
- **Behavior**: Opens bottom sheet with selectable options

### 2. **Offers Filter**
- **Function**: Shows only restaurants with active discounts/offers
- **UI**: Toggle chip with offer icon
- **Behavior**: Filters restaurants that have non-empty discount field

### 3. **Ratings Filter**
- **Options**: Any Rating, 3.0+, 3.5+, 4.0+, 4.5+ Stars
- **UI**: Star icon with rating threshold
- **Behavior**: Shows restaurants above selected rating

### 4. **Price Range Filter**
- **Options**: Rs. 0-300, Rs. 0-500, Rs. 0-700, Rs. 0-1000+
- **UI**: Price range display
- **Behavior**: Filters based on delivery fee (can be extended to menu prices)

### 5. **Fast Delivery Filter**
- **Function**: Shows restaurants with delivery time ≤ 25 minutes
- **UI**: Lightning bolt icon
- **Behavior**: Parses delivery time string and filters accordingly

### 6. **Clear All Filter**
- **Function**: Resets all filters to default state
- **UI**: Red-colored chip with clear icon
- **Behavior**: Only appears when filters are active

## Visual Features

### Filter Chips Design
- **Active State**: Primary color border and background tint
- **Inactive State**: Gray border with white background
- **Shadow**: Subtle shadow for depth
- **Icons**: Relevant icons for each filter type

### Results Counter
- Shows "X restaurants found" below filters
- Updates dynamically as filters change

### Bottom Sheets
- Clean, modal design for multi-option filters
- Check mark indicator for selected option
- Rounded corners and proper padding

## Technical Implementation

### State Management
```dart
String _selectedSortBy = 'Relevance';
bool _showOffersOnly = false;
double _minRating = 0.0;
double _maxPrice = 1000.0;
bool _fastDeliveryOnly = false;
```

### Filter Logic
- Combines multiple filter conditions
- Applies sorting after filtering
- Maintains original data integrity

### Performance
- Filters applied on UI thread (suitable for current data size)
- Can be optimized with background processing for larger datasets

## Usage

1. **Sort By**: Tap to open options, select desired sorting method
2. **Offers**: Tap to toggle offers-only view
3. **Ratings**: Tap to select minimum rating threshold
4. **Price Range**: Tap to select maximum price limit
5. **Fast Delivery**: Tap to toggle fast delivery filter
6. **Clear All**: Tap to reset all filters (appears when filters are active)

## Future Enhancements

1. **Cuisine Filter**: Filter by food type (Pizza, Chinese, etc.)
2. **Distance Filter**: Filter by restaurant proximity
3. **Vegetarian Filter**: Show only vegetarian restaurants
4. **New Restaurants**: Filter recently added restaurants
5. **Favorites**: Show only favorited restaurants
6. **Search Integration**: Combine with search functionality

## Files Modified
- `lib/screens/new_home_screen.dart`: Added complete filter system
- Enhanced with interactive UI components and filter logic