import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodiehub/models/menu_item.dart';
import 'package:foodiehub/services/menu_item_service.dart';
import 'package:foodiehub/services/restaurant_service.dart';
import 'package:foodiehub/utils/constants.dart';

/// This script helps migrate sample data from constants.dart to Firebase
/// Run this once to populate your Firebase database with initial data
class FirebaseMigration {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final RestaurantService _restaurantService = RestaurantService();
  final MenuItemService _menuItemService = MenuItemService();

  /// Migrate restaurants and menu items from sample data
  Future<void> migrateSampleData() async {
    print('Starting Firebase migration...');
    
    // Step 1: Create sample owner accounts
    final ownerIds = await _migrateOwnerAccounts();

    // Step 2: Migrate restaurants
    await _migrateRestaurants(ownerIds);
    
    // Step 3: Migrate menu items
    await _migrateMenuItems();
    
    print('Firebase migration completed!');
  }

  /// Create sample owner accounts and return map of restaurantId -> ownerId
  Future<Map<String, String>> _migrateOwnerAccounts() async {
    print('Creating sample owner accounts...');
    final Map<String, String> ownerIds = {};

    for (final account in sampleOwnerAccounts) {
      try {
        final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: account.email,
          password: account.password,
        );
        final uid = credential.user?.uid;
        if (uid != null) {
          ownerIds[account.restaurantId] = uid;
          print('✓ Created owner account: ${account.email}');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          try {
            final credential = await _firebaseAuth.signInWithEmailAndPassword(
              email: account.email,
              password: account.password,
            );
            final uid = credential.user?.uid;
            if (uid != null) {
              ownerIds[account.restaurantId] = uid;
              print('• Owner account exists: ${account.email}');
            }
          } on FirebaseAuthException catch (signInError) {
            print('✗ Failed to sign in existing owner ${account.email}: ${signInError.code}');
          }
        } else {
          print('✗ Failed to create owner ${account.email}: ${e.code}');
        }
      } catch (e) {
        print('✗ Unexpected error creating owner ${account.email}: $e');
      } finally {
        if (_firebaseAuth.currentUser != null) {
          await _firebaseAuth.signOut();
        }
      }
    }

    return ownerIds;
  }

  /// Migrate sample restaurants to Firebase
  Future<void> _migrateRestaurants(Map<String, String> ownerIds) async {
    print('Migrating restaurants...');
    for (final restaurant in sampleRestaurants) {
      final ownerId = ownerIds[restaurant.id];
      final restaurantToAdd = ownerId != null
          ? restaurant.copyWith(ownerId: ownerId)
          : restaurant;
      final success = await _restaurantService.addRestaurant(restaurantToAdd);
      if (success) {
        print('✓ Added restaurant: ${restaurant.name}');
      } else {
        print('✗ Failed to add restaurant: ${restaurant.name}');
      }
    }
  }

  /// Migrate sample menu items to Firebase (stored under each restaurant)
  Future<void> _migrateMenuItems() async {
    print('Migrating menu items...');
    final Map<String, List<MenuItem>> menuItemsByRestaurant = {};

    for (final menuItem in sampleMenuItems) {
      menuItemsByRestaurant.putIfAbsent(menuItem.restaurantId, () => []);
      menuItemsByRestaurant[menuItem.restaurantId]!.add(menuItem);
    }

    for (final entry in menuItemsByRestaurant.entries) {
      final restaurantId = entry.key;
      for (final menuItem in entry.value) {
        final success = await _menuItemService.addMenuItem(restaurantId, menuItem);
        if (success) {
          print('✓ Added menu item to $restaurantId: ${menuItem.name}');
        } else {
          print('✗ Failed to add menu item to $restaurantId: ${menuItem.name}');
        }
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

    print('All data cleared from Firebase');
  }
}

