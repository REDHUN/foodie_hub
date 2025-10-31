import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodiehub/models/restaurant.dart';

class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'restaurants';

  // Get all restaurants
  Future<List<Restaurant>> getRestaurants() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => Restaurant.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting restaurants: $e');
      return [];
    }
  }

  // Get a single restaurant by ID
  Future<Restaurant?> getRestaurantById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Restaurant.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting restaurant: $e');
      return null;
    }
  }

  // Stream of restaurants for real-time updates
  Stream<List<Restaurant>> getRestaurantsStream() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Restaurant.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Add a new restaurant
  Future<bool> addRestaurant(Restaurant restaurant) async {
    try {
      await _firestore.collection(_collection).doc(restaurant.id).set(restaurant.toJson());
      return true;
    } catch (e) {
      print('Error adding restaurant: $e');
      return false;
    }
  }

  // Update a restaurant
  Future<bool> updateRestaurant(Restaurant restaurant) async {
    try {
      await _firestore.collection(_collection).doc(restaurant.id).update(restaurant.toJson());
      return true;
    } catch (e) {
      print('Error updating restaurant: $e');
      return false;
    }
  }

  // Delete a restaurant
  Future<bool> deleteRestaurant(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting restaurant: $e');
      return false;
    }
  }
}

