import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodiehub/models/menu_item.dart';

class MenuItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _restaurantsCollection = 'restaurants';
  static const String _menuSubcollection = 'menuItems';

  CollectionReference<Map<String, dynamic>> _menuCollection(String restaurantId) {
    return _firestore
        .collection(_restaurantsCollection)
        .doc(restaurantId)
        .collection(_menuSubcollection);
  }

  /// Get all menu items across all restaurants (collection group query)
  Future<List<MenuItem>> getAllMenuItems() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collectionGroup(_menuSubcollection).get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] ??= doc.id;
        data['restaurantId'] ??= doc.reference.parent.parent?.id ?? '';
        return MenuItem.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting all menu items: $e');
      return [];
    }
  }

  /// Get menu items for a specific restaurant
  Future<List<MenuItem>> getMenuItemsForRestaurant(String restaurantId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _menuCollection(restaurantId).get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] ??= doc.id;
        data['restaurantId'] = restaurantId;
        return MenuItem.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting menu items for restaurant: $e');
      return [];
    }
  }

  /// Get menu items by category for a restaurant
  Future<List<MenuItem>> getMenuItemsByCategory(
    String restaurantId,
    String category,
  ) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _menuCollection(restaurantId)
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] ??= doc.id;
        data['restaurantId'] = restaurantId;
        return MenuItem.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting menu items by category: $e');
      return [];
    }
  }

  /// Get a single menu item
  Future<MenuItem?> getMenuItemById(String restaurantId, String menuItemId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _menuCollection(restaurantId).doc(menuItemId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          data['id'] ??= doc.id;
          data['restaurantId'] = restaurantId;
          return MenuItem.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Error getting menu item: $e');
      return null;
    }
  }

  /// Stream menu items for a restaurant
  Stream<List<MenuItem>> getMenuItemsStream(String restaurantId) {
    return _menuCollection(restaurantId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] ??= doc.id;
        data['restaurantId'] = restaurantId;
        return MenuItem.fromJson(data);
      }).toList();
    });
  }

  /// Add a menu item under a restaurant
  Future<bool> addMenuItem(String restaurantId, MenuItem menuItem) async {
    try {
      final data = menuItem.toJson();
      data['restaurantId'] = restaurantId;
      await _menuCollection(restaurantId).doc(menuItem.id).set(data);
      return true;
    } catch (e) {
      print('Error adding menu item: $e');
      return false;
    }
  }

  /// Update a menu item under a restaurant
  Future<bool> updateMenuItem(String restaurantId, MenuItem menuItem) async {
    try {
      final data = menuItem.toJson();
      data['restaurantId'] = restaurantId;
      await _menuCollection(restaurantId).doc(menuItem.id).update(data);
      return true;
    } catch (e) {
      print('Error updating menu item: $e');
      return false;
    }
  }

  /// Delete a menu item from a restaurant
  Future<bool> deleteMenuItem(String restaurantId, String menuItemId) async {
    try {
      await _menuCollection(restaurantId).doc(menuItemId).delete();
      return true;
    } catch (e) {
      print('Error deleting menu item: $e');
      return false;
    }
  }

  /// Delete all menu items for a restaurant (used when clearing data)
  Future<void> deleteMenuItemsForRestaurant(String restaurantId) async {
    final snapshot = await _menuCollection(restaurantId).get();
    final WriteBatch batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}

