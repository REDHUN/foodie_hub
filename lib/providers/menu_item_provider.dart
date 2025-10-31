import 'package:flutter/foundation.dart';
import 'package:foodiehub/models/menu_item.dart';
import 'package:foodiehub/services/menu_item_service.dart';

class MenuItemProvider with ChangeNotifier {
  final MenuItemService _menuItemService = MenuItemService();
  final Map<String, List<MenuItem>> _menuItemsByRestaurant = {};
  List<MenuItem> _allMenuItems = [];
  bool _isLoading = false;
  String? _error;

  List<MenuItem> get menuItems => _allMenuItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load every menu item (uses collection group query)
  Future<void> loadAllMenuItems() async {
    _setLoading(true);
    try {
      final items = await _menuItemService.getAllMenuItems();
      _setMenuItems(items);
      _error = null;
    } catch (e) {
      _handleError('Failed to load menu items: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load menu items for a specific restaurant
  Future<void> loadMenuItemsForRestaurant(String restaurantId) async {
    _setLoading(true);
    try {
      final items = await _menuItemService.getMenuItemsForRestaurant(restaurantId);
      _menuItemsByRestaurant[restaurantId] = items;
      _refreshAllMenuItems();
      _error = null;
      notifyListeners();
    } catch (e) {
      _handleError('Failed to load menu items: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load initial data from Firebase (with optional sample fallback)
  Future<void> initializeMenuItems() async {
    await loadAllMenuItems();

    if (_allMenuItems.isEmpty) {
      await _addSampleMenuItems();
    }
  }

  Future<void> _addSampleMenuItems() async {
    // Intentionally left empty. To add sample data, use Firebase migration.
  }

  List<MenuItem> getMenuItemsByRestaurant(String restaurantId) {
    return _menuItemsByRestaurant[restaurantId] ?? [];
  }

  MenuItem? getMenuItemById(String restaurantId, String id) {
    try {
      return getMenuItemsByRestaurant(restaurantId).firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  List<String> getCategoriesByRestaurant(String restaurantId) {
    final items = getMenuItemsByRestaurant(restaurantId);
    final categories = items.map((item) => item.category).toSet().toList();
    categories.sort();
    return categories;
  }

  Future<bool> addMenuItem(String restaurantId, MenuItem menuItem) async {
    final success = await _menuItemService.addMenuItem(restaurantId, menuItem);
    if (success) {
      await loadMenuItemsForRestaurant(restaurantId);
    }
    return success;
  }

  Future<bool> updateMenuItem(String restaurantId, MenuItem menuItem) async {
    final success = await _menuItemService.updateMenuItem(restaurantId, menuItem);
    if (success) {
      await loadMenuItemsForRestaurant(restaurantId);
    }
    return success;
  }

  Future<bool> deleteMenuItem(String restaurantId, String menuItemId) async {
    final success = await _menuItemService.deleteMenuItem(restaurantId, menuItemId);
    if (success) {
      await loadMenuItemsForRestaurant(restaurantId);
    }
    return success;
  }

  void _setMenuItems(List<MenuItem> items) {
    _allMenuItems = items;
    _menuItemsByRestaurant.clear();
    for (final item in items) {
      final list = _menuItemsByRestaurant[item.restaurantId] ?? [];
      list.add(item);
      _menuItemsByRestaurant[item.restaurantId] = list;
    }
    notifyListeners();
  }

  void _refreshAllMenuItems() {
    _allMenuItems = _menuItemsByRestaurant.values.expand((items) => items).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _handleError(String message) {
    _error = message;
    notifyListeners();
  }
}

