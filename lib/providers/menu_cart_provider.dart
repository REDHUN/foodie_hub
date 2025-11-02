import 'package:flutter/foundation.dart';
import 'package:foodiehub/models/menu_cart_item.dart';
import 'package:foodiehub/models/menu_item.dart';

class MenuCartProvider with ChangeNotifier {
  final List<MenuCartItem> _items = [];
  final List<AppliedOffer> _appliedOffers = [];

  List<MenuCartItem> get items => _items;
  List<AppliedOffer> get appliedOffers => _appliedOffers;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.total);

  double get discountAmount =>
      _appliedOffers.fold(0.0, (sum, offer) => sum + offer.discountAmount);

  double get totalAmount => subtotalAmount - discountAmount;

  void addToCart(MenuItem menuItem, {int quantity = 1}) {
    final existingIndex = _items.indexWhere(
      (item) => item.menuItem.id == menuItem.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(MenuCartItem(menuItem: menuItem, quantity: quantity));
    }
    notifyListeners();
  }

  void removeFromCart(String menuItemId) {
    _items.removeWhere((item) => item.menuItem.id == menuItemId);
    notifyListeners();
  }

  void updateQuantity(String menuItemId, int quantity) {
    final index = _items.indexWhere((item) => item.menuItem.id == menuItemId);
    if (index >= 0) {
      if (quantity <= 0) {
        removeFromCart(menuItemId);
      } else {
        _items[index].quantity = quantity;
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(String menuItemId) {
    return _items.any((item) => item.menuItem.id == menuItemId);
  }

  int getQuantity(String menuItemId) {
    final index = _items.indexWhere((item) => item.menuItem.id == menuItemId);
    return index >= 0 ? _items[index].quantity : 0;
  }

  void applyOffer(
    String offerId,
    String title,
    String description,
    double discountAmount, {
    double? minimumAmount,
  }) {
    // Check if offer already applied
    if (_appliedOffers.any((offer) => offer.id == offerId)) {
      return;
    }

    // Check minimum amount requirement
    if (minimumAmount != null && subtotalAmount < minimumAmount) {
      return;
    }

    // Calculate actual discount (don't exceed subtotal)
    final actualDiscount = discountAmount > subtotalAmount
        ? subtotalAmount
        : discountAmount;

    _appliedOffers.add(
      AppliedOffer(
        id: offerId,
        title: title,
        description: description,
        discountAmount: actualDiscount,
        appliedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void removeOffer(String offerId) {
    _appliedOffers.removeWhere((offer) => offer.id == offerId);
    notifyListeners();
  }

  void clearOffers() {
    _appliedOffers.clear();
    notifyListeners();
  }

  bool hasOffer(String offerId) {
    return _appliedOffers.any((offer) => offer.id == offerId);
  }
}

class AppliedOffer {
  final String id;
  final String title;
  final String description;
  final double discountAmount;
  final DateTime appliedAt;

  AppliedOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.discountAmount,
    required this.appliedAt,
  });
}
