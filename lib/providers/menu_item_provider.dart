import 'package:flutter/foundation.dart';
import 'package:foodiehub/models/menu_item.dart';
import 'package:foodiehub/services/menu_item_service.dart';

class MenuItemProvider with ChangeNotifier {
  final MenuItemService _menuItemService = MenuItemService();
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String? _error;

  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all menu items from Firebase
  Future<void> loadMenuItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _menuItems = await _menuItemService.getMenuItems();
      _error = null;
    } catch (e) {
      _error = 'Failed to load menu items: $e';
      _menuItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load menu items by restaurant ID
  Future<void> loadMenuItemsByRestaurant(String restaurantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _menuItems = await _menuItemService.getMenuItemsByRestaurant(restaurantId);
      _error = null;
    } catch (e) {
      _error = 'Failed to load menu items: $e';
      _menuItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load initial data if Firebase is empty
  Future<void> initializeMenuItems() async {
    // First, try to load from Firebase
    await loadMenuItems();
    
    // If Firebase is empty, add sample data
    if (_menuItems.isEmpty) {
      await _addSampleMenuItems();
    }
  }

  Future<void> _addSampleMenuItems() async {
    // Add sample menu items to Firebase
    // This is a one-time setup when Firebase is empty
    // You can comment this out after initial setup
  }

  // Get menu items for a specific restaurant
  List<MenuItem> getMenuItemsByRestaurant(String restaurantId) {
    return _menuItems.where((item) => item.restaurantId == restaurantId).toList();
  }

  // Get menu item by ID
  MenuItem? getMenuItemById(String id) {
    try {
      return _menuItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get unique categories for a restaurant
  List<String> getCategoriesByRestaurant(String restaurantId) {
    final items = getMenuItemsByRestaurant(restaurantId);
    final categories = items.map((item) => item.category).toSet().toList();
    return categories;
  }

  // Add a new menu item
  Future<bool> addMenuItem(MenuItem menuItem) async {
    final success = await _menuItemService.addMenuItem(menuItem);
    if (success) {
      await loadMenuItems();
    }
    return success;
  }

  // Update a menu item
  Future<bool> updateMenuItem(MenuItem menuItem) async {
    final success = await _menuItemService.updateMenuItem(menuItem);
    if (success) {
      await loadMenuItems();
    }
    return success;
  }

  // Delete a menu item
  Future<bool> deleteMenuItem(String id) async {
    final success = await _menuItemService.deleteMenuItem(id);
    if (success) {
      await loadMenuItems();
    }
    return success;
  }
}

