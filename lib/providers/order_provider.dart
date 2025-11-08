import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:foodiehub/models/order.dart' as app_order;
import 'package:foodiehub/services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<app_order.Order> _orders = [];
  List<app_order.Order> _customerOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _pendingOrdersCount = 0;

  StreamSubscription<List<app_order.Order>>? _ordersSubscription;
  StreamSubscription<List<app_order.Order>>? _customerOrdersSubscription;
  StreamSubscription<int>? _pendingCountSubscription;

  // Getters
  List<app_order.Order> get orders => _orders;
  List<app_order.Order> get customerOrders => _customerOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get pendingOrdersCount => _pendingOrdersCount;

  // Create a new order
  Future<bool> createOrder(app_order.Order order) async {
    _setLoading(true);
    try {
      final success = await _orderService.createOrder(order);
      if (success) {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to create order';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load restaurant orders
  void loadRestaurantOrders(String restaurantId) {
    _ordersSubscription?.cancel();
    _ordersSubscription = _orderService
        .getRestaurantOrders(restaurantId)
        .listen(
          (orders) {
            _orders = orders;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = error.toString();
            notifyListeners();
          },
        );
  }

  // Load customer orders
  void loadCustomerOrders(String customerId) {
    _customerOrdersSubscription?.cancel();
    _customerOrdersSubscription = _orderService
        .getCustomerOrders(customerId)
        .listen(
          (orders) {
            _customerOrders = orders;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = error.toString();
            notifyListeners();
          },
        );
  }

  // Load pending orders count
  void loadPendingOrdersCount(String restaurantId) {
    _pendingCountSubscription?.cancel();
    _pendingCountSubscription = _orderService
        .getPendingOrdersCount(restaurantId)
        .listen(
          (count) {
            _pendingOrdersCount = count;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = error.toString();
            notifyListeners();
          },
        );
  }

  // Update order status
  Future<bool> updateOrderStatus(
    String orderId,
    app_order.OrderStatus status,
  ) async {
    _setLoading(true);
    try {
      final success = await _orderService.updateOrderStatus(orderId, status);
      if (success) {
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = 'Failed to update order status';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get orders by status
  List<app_order.Order> getOrdersByStatus(app_order.OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Get today's orders
  List<app_order.Order> getTodaysOrders() {
    final today = DateTime.now();
    return _orders.where((order) {
      return order.createdAt.year == today.year &&
          order.createdAt.month == today.month &&
          order.createdAt.day == today.day;
    }).toList();
  }

  // Calculate today's revenue
  double getTodaysRevenue() {
    final todaysOrders = getTodaysOrders();
    return todaysOrders
        .where((order) => order.status == app_order.OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.grandTotal);
  }

  // Get order statistics
  Map<String, int> getOrderStatistics() {
    return {
      'total': _orders.length,
      'pending': getOrdersByStatus(app_order.OrderStatus.pending).length,
      'confirmed': getOrdersByStatus(app_order.OrderStatus.confirmed).length,
      'preparing': getOrdersByStatus(app_order.OrderStatus.preparing).length,
      'ready': getOrdersByStatus(app_order.OrderStatus.ready).length,
      'delivered': getOrdersByStatus(app_order.OrderStatus.delivered).length,
      'cancelled': getOrdersByStatus(app_order.OrderStatus.cancelled).length,
    };
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _customerOrdersSubscription?.cancel();
    _pendingCountSubscription?.cancel();
    super.dispose();
  }
}
