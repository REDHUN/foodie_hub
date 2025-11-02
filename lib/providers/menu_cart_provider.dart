import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:foodiehub/models/menu_cart_item.dart';
import 'package:foodiehub/models/menu_item.dart';
import 'package:foodiehub/services/firebase_cart_service.dart';
import 'package:foodiehub/services/restaurant_service.dart';

class MenuCartProvider with ChangeNotifier {
  final List<MenuCartItem> _items = [];
  final List<AppliedOffer> _appliedOffers = [];
  final FirebaseCartService _firebaseCartService = FirebaseCartService();

  bool _isLoading = false;
  bool _isInitialized = false;
  bool _hasLoadedFromFirebase = false;
  bool _isCurrentlyLoading = false; // Prevent multiple simultaneous loads
  StreamSubscription<User?>? _authSubscription;

  MenuCartProvider() {
    // Initialize cart immediately when provider is created
    _initializeCartDelayed();
  }

  /// Initialize cart with delay to allow Firebase to initialize
  void _initializeCartDelayed() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_isInitialized) {
        initializeCart();
      }
    });
  }

  List<MenuCartItem> get items => _items;
  List<AppliedOffer> get appliedOffers => _appliedOffers;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isOwnerLoggedIn => _firebaseCartService.isOwnerLoggedIn;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.total);

  double get discountAmount =>
      _appliedOffers.fold(0.0, (sum, offer) => sum + offer.discountAmount);

  double get totalAmount => subtotalAmount - discountAmount;

  /// Initialize cart and listen to auth state changes
  Future<void> initializeCart() async {
    if (_isInitialized) return;

    // Listen to authentication state changes
    _authSubscription = _firebaseCartService.authStateChanges.listen((user) {
      _handleAuthStateChange(user);
    });

    // Wait for Firebase Auth to initialize and then check if user is logged in
    await _waitForAuthAndLoadCart();

    _isInitialized = true;
    notifyListeners();
  }

  /// Wait for Firebase Auth to initialize and load cart if user is logged in
  Future<void> _waitForAuthAndLoadCart() async {
    // Wait a bit for Firebase Auth to initialize
    await Future.delayed(const Duration(milliseconds: 100));

    // Check multiple times with increasing delays to catch auth state
    for (int i = 0; i < 5; i++) {
      if (_firebaseCartService.isOwnerLoggedIn) {
        if (kDebugMode) {
          print('User found logged in during initialization - loading cart');
        }
        // On app restart, don't migrate (just load from Firebase)
        await _loadCartFromFirebase(shouldMigrate: false);
        return;
      }
      // Wait progressively longer each time
      await Future.delayed(Duration(milliseconds: 200 * (i + 1)));
    }

    if (kDebugMode) {
      print('No logged in user found during initialization');
    }
  }

  /// Manually load cart from Firebase (call this after login)
  Future<void> loadCartAfterLogin() async {
    if (kDebugMode) {
      print(
        'Manual cart load requested - owner logged in: ${_firebaseCartService.isOwnerLoggedIn}',
      );
    }

    if (_firebaseCartService.isOwnerLoggedIn) {
      // Add a delay to ensure restaurant data is available
      await Future.delayed(const Duration(milliseconds: 1000));
      // Only migrate if this is a fresh login (cart is empty)
      final shouldMigrate = _items.isEmpty;
      await _loadCartFromFirebase(shouldMigrate: shouldMigrate);
    }
  }

  /// Force refresh cart from Firebase
  Future<void> refreshCartFromFirebase() async {
    if (_firebaseCartService.isOwnerLoggedIn) {
      await _loadCartFromFirebase(shouldMigrate: false);
    }
  }

  /// Load cart on app resume (call when app becomes active)
  Future<void> loadCartOnAppResume() async {
    if (kDebugMode) {
      print('App resumed - checking if cart needs to be loaded');
    }

    // Wait a bit for any pending auth state changes
    await Future.delayed(const Duration(milliseconds: 500));

    // Only load if user is logged in, cart is empty, not currently loading, and hasn't loaded yet
    if (_firebaseCartService.isOwnerLoggedIn &&
        _items.isEmpty &&
        !_isCurrentlyLoading &&
        !_hasLoadedFromFirebase) {
      if (kDebugMode) {
        print('User is logged in but cart is empty - loading from Firebase');
      }
      await _loadCartFromFirebase(shouldMigrate: false);
    } else if (kDebugMode) {
      print(
        'App resume load skipped - already loaded: $_hasLoadedFromFirebase, loading: $_isCurrentlyLoading, items: ${_items.length}',
      );
    }
  }

  /// Force load cart from Firebase (for testing/debugging)
  Future<void> forceLoadCartFromFirebase() async {
    if (kDebugMode) {
      print('Force loading cart from Firebase...');
    }

    await debugCartState();

    if (_firebaseCartService.isOwnerLoggedIn) {
      await _loadCartFromFirebase(shouldMigrate: false);
      if (kDebugMode) {
        print('Force load completed. Cart items: ${_items.length}');
      }
    } else {
      if (kDebugMode) {
        print('Cannot force load - user not logged in');
      }
    }
  }

  /// Test Firebase connection and data
  Future<void> testFirebaseConnection() async {
    if (kDebugMode) {
      print('=== TESTING FIREBASE CONNECTION ===');

      try {
        // Test Firebase Auth
        final user = FirebaseAuth.instance.currentUser;
        print('Firebase Auth User: ${user?.uid}');
        print('User Email: ${user?.email}');
        print('Is Anonymous: ${user?.isAnonymous}');

        if (user != null && !user.isAnonymous) {
          // Test restaurant service
          final restaurant = await RestaurantService().getRestaurantByOwnerId(
            user.uid,
          );
          print(
            'Restaurant found: ${restaurant?.name} (ID: ${restaurant?.id})',
          );

          if (restaurant != null) {
            // Test direct Firestore access
            final cartRef = FirebaseFirestore.instance
                .collection('restaurants')
                .doc(restaurant.id)
                .collection('cart');

            final snapshot = await cartRef.get();
            print('Cart documents in Firebase: ${snapshot.docs.length}');

            for (final doc in snapshot.docs) {
              print('Cart item: ${doc.id} - ${doc.data()}');
            }
          }
        }
      } catch (e) {
        print('Firebase test error: $e');
      }

      print('=== END FIREBASE TEST ===');
    }
  }

  /// Handle authentication state changes
  void _handleAuthStateChange(User? user) async {
    if (kDebugMode) {
      print(
        'Auth state changed: ${user?.uid} (anonymous: ${user?.isAnonymous})',
      );
    }

    if (user != null && !user.isAnonymous) {
      // Restaurant owner logged in - only load if we haven't loaded yet and not currently loading
      if (!_hasLoadedFromFirebase && !_isCurrentlyLoading) {
        if (kDebugMode) {
          print(
            'Restaurant owner logged in via auth state change - loading cart from Firebase',
          );
        }
        // Add a delay to ensure restaurant data is available
        await Future.delayed(const Duration(milliseconds: 1000));
        await _loadCartFromFirebase(shouldMigrate: false);
      } else {
        if (kDebugMode) {
          print(
            'Auth state change detected but cart already loaded/loading from Firebase - skipping',
          );
        }
      }
    } else {
      // Owner logged out - clear cart since it's restaurant-specific
      if (kDebugMode) {
        print('Restaurant owner logged out - clearing cart');
      }
      _clearCartOnLogout();
    }
  }

  /// Clear cart when restaurant owner logs out
  void _clearCartOnLogout() {
    if (_items.isNotEmpty || _appliedOffers.isNotEmpty) {
      if (kDebugMode) {
        print(
          'Clearing cart on logout: ${_items.length} items, ${_appliedOffers.length} offers',
        );
      }
      _items.clear();
      _appliedOffers.clear();
      _hasLoadedFromFirebase = false; // Reset flag for next login
      _isCurrentlyLoading = false; // Reset loading flag
      notifyListeners();
    }
  }

  /// Load cart from Firebase for logged-in restaurant owners
  Future<void> _loadCartFromFirebase({bool shouldMigrate = true}) async {
    if (!_firebaseCartService.isOwnerLoggedIn) return;

    // Prevent multiple simultaneous loads
    if (_isCurrentlyLoading) {
      if (kDebugMode) {
        print('Cart load already in progress - skipping duplicate request');
      }
      return;
    }

    // If already loaded from Firebase and not migrating, skip
    if (_hasLoadedFromFirebase && !shouldMigrate) {
      if (kDebugMode) {
        print('Cart already loaded from Firebase - skipping duplicate load');
      }
      return;
    }

    _isCurrentlyLoading = true;
    _isLoading = true;
    notifyListeners();

    try {
      // Load cart from Firebase
      final cartItems = await _firebaseCartService.loadCartFromFirebase();
      final offers = await _firebaseCartService.loadOffersFromFirebase();

      if (shouldMigrate && !_hasLoadedFromFirebase) {
        // Store current local cart for migration (only on first load)
        final localItems = List<MenuCartItem>.from(_items);
        final localOffers = List<AppliedOffer>.from(_appliedOffers);

        // If owner had local cart items, migrate them
        if (localItems.isNotEmpty || localOffers.isNotEmpty) {
          if (kDebugMode) {
            print(
              'Migrating local cart to Firebase: ${localItems.length} items, ${localOffers.length} offers',
            );
          }
          await _firebaseCartService.migrateLocalCartToFirebase(
            localItems,
            localOffers,
          );
          // Reload after migration
          final mergedItems = await _firebaseCartService.loadCartFromFirebase();
          final mergedOffers = await _firebaseCartService
              .loadOffersFromFirebase();

          _items.clear();
          _items.addAll(mergedItems);
          _appliedOffers.clear();
          _appliedOffers.addAll(mergedOffers);
        } else {
          // Just load Firebase cart
          _items.clear();
          _items.addAll(cartItems);
          _appliedOffers.clear();
          _appliedOffers.addAll(offers);
        }
      } else {
        // Just replace with Firebase cart (no migration)
        _items.clear();
        _items.addAll(cartItems);
        _appliedOffers.clear();
        _appliedOffers.addAll(offers);
      }

      _hasLoadedFromFirebase = true;
      if (kDebugMode) {
        print(
          'Cart loaded from Firebase for restaurant: ${_items.length} items, ${_appliedOffers.length} offers',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cart from Firebase: $e');
      }
    } finally {
      _isCurrentlyLoading = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  void addToCart(MenuItem menuItem, {int quantity = 1}) async {
    final existingIndex = _items.indexWhere(
      (item) => item.menuItem.id == menuItem.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
      // Update Firebase only if restaurant owner is logged in
      if (_firebaseCartService.isOwnerLoggedIn) {
        _firebaseCartService.updateItemQuantityInFirebase(
          menuItem.id,
          _items[existingIndex].quantity,
        );
      }
    } else {
      final newItem = MenuCartItem(menuItem: menuItem, quantity: quantity);
      _items.add(newItem);
      // Add to Firebase only if restaurant owner is logged in
      if (_firebaseCartService.isOwnerLoggedIn) {
        _firebaseCartService.addItemToFirebaseCart(newItem);
      }
    }
    notifyListeners();
  }

  void removeFromCart(String menuItemId) async {
    _items.removeWhere((item) => item.menuItem.id == menuItemId);
    // Remove from Firebase only if restaurant owner is logged in
    if (_firebaseCartService.isOwnerLoggedIn) {
      _firebaseCartService.removeItemFromFirebaseCart(menuItemId);
    }
    notifyListeners();
  }

  void updateQuantity(String menuItemId, int quantity) async {
    final index = _items.indexWhere((item) => item.menuItem.id == menuItemId);
    if (index >= 0) {
      if (quantity <= 0) {
        removeFromCart(menuItemId);
      } else {
        _items[index].quantity = quantity;
        // Update Firebase only if restaurant owner is logged in
        if (_firebaseCartService.isOwnerLoggedIn) {
          _firebaseCartService.updateItemQuantityInFirebase(
            menuItemId,
            quantity,
          );
        }
        notifyListeners();
      }
    }
  }

  void clearCart() async {
    _items.clear();
    _appliedOffers.clear();
    // Clear Firebase cart only if restaurant owner is logged in
    if (_firebaseCartService.isOwnerLoggedIn) {
      _firebaseCartService.clearFirebaseCart();
    }
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
    // Save offers to Firebase only if restaurant owner is logged in
    if (_firebaseCartService.isOwnerLoggedIn) {
      _firebaseCartService.saveOffersToFirebase(_appliedOffers);
    }
    notifyListeners();
  }

  void removeOffer(String offerId) async {
    _appliedOffers.removeWhere((offer) => offer.id == offerId);
    // Save updated offers to Firebase only if restaurant owner is logged in
    if (_firebaseCartService.isOwnerLoggedIn) {
      _firebaseCartService.saveOffersToFirebase(_appliedOffers);
    }
    notifyListeners();
  }

  void clearOffers() async {
    _appliedOffers.clear();
    // Save empty offers to Firebase only if restaurant owner is logged in
    if (_firebaseCartService.isOwnerLoggedIn) {
      _firebaseCartService.saveOffersToFirebase(_appliedOffers);
    }
    notifyListeners();
  }

  /// Sync cart with Firebase (only for logged-in restaurant owners)
  Future<void> syncWithFirebase() async {
    if (!_firebaseCartService.isOwnerLoggedIn) {
      if (kDebugMode) {
        print('Cannot sync - restaurant owner not logged in');
      }
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Save current state to Firebase
      await _firebaseCartService.saveCartToFirebase(_items);
      await _firebaseCartService.saveOffersToFirebase(_appliedOffers);

      if (kDebugMode) {
        print('Cart synced with Firebase for restaurant');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing cart with Firebase: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear cart on logout (can be called manually)
  void clearCartOnLogout() {
    _clearCartOnLogout();
  }

  /// Debug method to check current state
  Future<void> debugCartState() async {
    if (kDebugMode) {
      print('=== CART DEBUG STATE ===');
      print('Is initialized: $_isInitialized');
      print('Is loading: $_isLoading');
      print('Has loaded from Firebase: $_hasLoadedFromFirebase');
      print('Is owner logged in: ${_firebaseCartService.isOwnerLoggedIn}');
      print('Cart items count: ${_items.length}');
      print('Applied offers count: ${_appliedOffers.length}');

      // Check Firebase Auth directly
      final user = FirebaseAuth.instance.currentUser;
      print('Firebase Auth user: ${user?.uid}');
      print('User is anonymous: ${user?.isAnonymous}');

      // Check restaurant ID
      try {
        final restaurantId = await _firebaseCartService.restaurantId;
        print('Restaurant ID: $restaurantId');
      } catch (e) {
        print('Error getting restaurant ID: $e');
      }

      print('========================');
    }
  }

  /// Get login status message for UI
  String get loginStatusMessage {
    if (_firebaseCartService.isOwnerLoggedIn) {
      return 'Cart synced to restaurant cloud ☁️';
    } else {
      return 'Login as restaurant owner to save cart';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
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
