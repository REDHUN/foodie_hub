import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodiehub/models/menu_item.dart';

class MenuItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'menuItems';

  // Get all menu items
  Future<List<MenuItem>> getMenuItems() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => MenuItem.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting menu items: $e');
      return [];
    }
  }

  // Get menu items by restaurant ID
  Future<List<MenuItem>> getMenuItemsByRestaurant(String restaurantId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId)
          .get();
      return snapshot.docs
          .map((doc) => MenuItem.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting menu items by restaurant: $e');
      return [];
    }
  }

  // Get a single menu item by ID
  Future<MenuItem?> getMenuItemById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return MenuItem.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting menu item: $e');
      return null;
    }
  }

  // Stream of menu items for real-time updates
  Stream<List<MenuItem>> getMenuItemsStream() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuItem.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Stream of menu items by restaurant ID for real-time updates
  Stream<List<MenuItem>> getMenuItemsByRestaurantStream(String restaurantId) {
    return _firestore
        .collection(_collection)
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuItem.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Add a new menu item
  Future<bool> addMenuItem(MenuItem menuItem) async {
    try {
      await _firestore.collection(_collection).doc(menuItem.id).set(menuItem.toJson());
      return true;
    } catch (e) {
      print('Error adding menu item: $e');
      return false;
    }
  }

  // Update a menu item
  Future<bool> updateMenuItem(MenuItem menuItem) async {
    try {
      await _firestore.collection(_collection).doc(menuItem.id).update(menuItem.toJson());
      return true;
    } catch (e) {
      print('Error updating menu item: $e');
      return false;
    }
  }

  // Delete a menu item
  Future<bool> deleteMenuItem(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting menu item: $e');
      return false;
    }
  }

  // Get menu items by category
  Future<List<MenuItem>> getMenuItemsByCategory(String restaurantId, String category) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('restaurantId', isEqualTo: restaurantId)
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs
          .map((doc) => MenuItem.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting menu items by category: $e');
      return [];
    }
  }
}

