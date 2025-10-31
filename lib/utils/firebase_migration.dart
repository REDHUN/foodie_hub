import 'package:foodiehub/services/menu_item_service.dart';
import 'package:foodiehub/services/restaurant_service.dart';
import 'package:foodiehub/utils/constants.dart';

/// This script helps migrate sample data from constants.dart to Firebase
/// Run this once to populate your Firebase database with initial data
class FirebaseMigration {
  final RestaurantService _restaurantService = RestaurantService();
  final MenuItemService _menuItemService = MenuItemService();

  /// Migrate restaurants and menu items from sample data
  Future<void> migrateSampleData() async {
    print('Starting Firebase migration...');
    
    // First, migrate restaurants
    await _migrateRestaurants();
    
    // Then, migrate menu items
    await _migrateMenuItems();
    
    print('Firebase migration completed!');
  }

  /// Migrate sample restaurants to Firebase
  Future<void> _migrateRestaurants() async {
    print('Migrating restaurants...');
    for (final restaurant in sampleRestaurants) {
      final success = await _restaurantService.addRestaurant(restaurant);
      if (success) {
        print('✓ Added restaurant: ${restaurant.name}');
      } else {
        print('✗ Failed to add restaurant: ${restaurant.name}');
      }
    }
  }

  /// Migrate sample menu items to Firebase
  Future<void> _migrateMenuItems() async {
    print('Migrating menu items...');
    for (final menuItem in sampleMenuItems) {
      final success = await _menuItemService.addMenuItem(menuItem);
      if (success) {
        print('✓ Added menu item: ${menuItem.name}');
      } else {
        print('✗ Failed to add menu item: ${menuItem.name}');
      }
    }
  }

  /// Clear all data from Firebase (use with caution!)
  Future<void> clearAllData() async {
    print('⚠️  Clearing all data from Firebase...');
    
    // Get all restaurants and delete them
    final restaurants = await _restaurantService.getRestaurants();
    for (final restaurant in restaurants) {
      await _restaurantService.deleteRestaurant(restaurant.id);
    }
    
    // Get all menu items and delete them
    final menuItems = await _menuItemService.getMenuItems();
    for (final menuItem in menuItems) {
      await _menuItemService.deleteMenuItem(menuItem.id);
    }
    
    print('All data cleared from Firebase');
  }
}

