import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodiehub/models/order.dart' as app_order;

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  // Create a new order
  Future<bool> createOrder(app_order.Order order) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(order.id)
          .set(order.toJson());
      return true;
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }

  // Get orders for a specific restaurant
  Stream<List<app_order.Order>> getRestaurantOrders(String restaurantId) {
    return _firestore
        .collection(_collection)
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return app_order.Order.fromJson(data);
          }).toList();
        });
  }

  // Get orders for a specific customer
  Stream<List<app_order.Order>> getCustomerOrders(String customerId) {
    return _firestore
        .collection(_collection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return app_order.Order.fromJson(data);
          }).toList();
        });
  }

  // Update order status
  Future<bool> updateOrderStatus(
    String orderId,
    app_order.OrderStatus status,
  ) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // Get pending orders count for a restaurant
  Stream<int> getPendingOrdersCount(String restaurantId) {
    return _firestore
        .collection(_collection)
        .where('restaurantId', isEqualTo: restaurantId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get all orders (for admin)
  Stream<List<app_order.Order>> getAllOrders() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return app_order.Order.fromJson(data);
          }).toList();
        });
  }

  // Delete order
  Future<bool> deleteOrder(String orderId) async {
    try {
      await _firestore.collection(_collection).doc(orderId).delete();
      return true;
    } catch (e) {
      print('Error deleting order: $e');
      return false;
    }
  }

  // Get order by ID
  Future<app_order.Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      if (doc.exists) {
        return app_order.Order.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }
}
