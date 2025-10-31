import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodiehub/models/restaurant.dart';
import 'package:foodiehub/services/menu_item_service.dart';

class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'restaurants';
  final MenuItemService _menuItemService = MenuItemService();

  CollectionReference<Map<String, dynamic>> get _restaurantCollection {
    return _firestore.collection(_collection);
  }

  // Get all restaurants
  Future<List<Restaurant>> getRestaurants() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _restaurantCollection.get();
      return snapshot.docs.map((doc) => Restaurant.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error getting restaurants: $e');
      return [];
    }
  }

  // Get a single restaurant by ID
  Future<Restaurant?> getRestaurantById(String id) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _restaurantCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return Restaurant.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Error getting restaurant: $e');
      return null;
    }
  }

  // Get restaurant by owner ID
  Future<Restaurant?> getRestaurantByOwnerId(String ownerId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _restaurantCollection
          .where('ownerId', isEqualTo: ownerId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Restaurant.fromJson(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Error getting restaurant by owner: $e');
      return null;
    }
  }

  // Stream of restaurants for real-time updates
  Stream<List<Restaurant>> getRestaurantsStream() {
    return _restaurantCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Restaurant.fromJson(doc.data())).toList();
    });
  }

  // Add a new restaurant
  Future<bool> addRestaurant(Restaurant restaurant) async {
    try {
      await _restaurantCollection.doc(restaurant.id).set(restaurant.toJson());
      return true;
    } catch (e) {
      print('Error adding restaurant: $e');
      return false;
    }
  }

  // Update a restaurant
  Future<bool> updateRestaurant(Restaurant restaurant) async {
    try {
      await _restaurantCollection.doc(restaurant.id).update(restaurant.toJson());
      return true;
    } catch (e) {
      print('Error updating restaurant: $e');
      return false;
    }
  }

  // Delete a restaurant
  Future<bool> deleteRestaurant(String id) async {
    try {
      await _menuItemService.deleteMenuItemsForRestaurant(id);
      await _restaurantCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting restaurant: $e');
      return false;
    }
  }
}

