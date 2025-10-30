import 'package:flutter/foundation.dart';
import 'package:foodiehub/models/menu_cart_item.dart';
import 'package:foodiehub/models/menu_item.dart';

class MenuCartProvider with ChangeNotifier {
  final List<MenuCartItem> _items = [];

  List<MenuCartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.total);

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
}
