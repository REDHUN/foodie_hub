import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:foodiehub/models/menu_cart_item.dart';
import 'package:foodiehub/providers/menu_cart_provider.dart';
import 'package:foodiehub/services/restaurant_service.dart';

class FirebaseCartService {
  static final FirebaseCartService _instance = FirebaseCartService._internal();
  factory FirebaseCartService() => _instance;
  FirebaseCartService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RestaurantService _restaurantService = RestaurantService();

  /// Get the current authenticated restaurant owner ID
  String? get _ownerId {
    final user = _auth.currentUser;
    if (user != null && !user.isAnonymous) {
      return user.uid;
    }
    return null;
  }

  /// Check if restaurant owner is logged in
  bool get isOwnerLoggedIn {
    final user = _auth.currentUser;
    return user != null && !user.isAnonymous;
  }

  /// Get restaurant ID for the current logged-in owner
  Future<String?> get restaurantId async {
    return _restaurantId;
  }

  /// Get restaurant ID for the current logged-in owner (private)
  Future<String?> get _restaurantId async {
    final ownerId = _ownerId;
    if (ownerId == null) return null;

    try {
      final restaurant = await _restaurantService.getRestaurantByOwnerId(
        ownerId,
      );
      return restaurant?.id;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting restaurant ID: $e');
      }
      return null;
    }
  }

  /// Get the cart collection reference for the current restaurant
  Future<CollectionReference?> get _cartCollection async {
    final restaurantId = await _restaurantId;
    if (restaurantId == null) return null;
    return _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('cart');
  }

  /// Save cart items to Firebase (only for logged-in restaurant owners)
  Future<void> saveCartToFirebase(List<MenuCartItem> cartItems) async {
    if (!isOwnerLoggedIn) {
      if (kDebugMode) {
        print('Cart not saved - restaurant owner not logged in');
      }
      return;
    }

    try {
      final cartCollection = await _cartCollection;
      if (cartCollection == null) return;

      // Use batch write for better performance
      final batch = _firestore.batch();

      // Clear existing cart items
      final existingItems = await cartCollection.get();
      for (final doc in existingItems.docs) {
        batch.delete(doc.reference);
      }

      // Add new cart items
      for (final item in cartItems) {
        final docRef = cartCollection.doc(item.menuItem.id);
        batch.set(docRef, {
          'menuItem': item.menuItem.toJson(),
          'quantity': item.quantity,
          'addedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      if (kDebugMode) {
        print(
          'Cart saved to Firebase for restaurant: ${cartItems.length} items',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving cart to Firebase: $e');
      }
      // Don't throw error to avoid disrupting user experience
    }
  }

  /// Load cart items from Firebase (only for logged-in restaurant owners)
  Future<List<MenuCartItem>> loadCartFromFirebase() async {
    if (!isOwnerLoggedIn) {
      if (kDebugMode) {
        print('Cart not loaded - restaurant owner not logged in');
      }
      return [];
    }

    try {
      final cartCollection = await _cartCollection;
      if (cartCollection == null) return [];

      final snapshot = await cartCollection
          .orderBy('addedAt', descending: false)
          .get();

      final cartItems = <MenuCartItem>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final cartItem = MenuCartItem.fromJson(data);
          cartItems.add(cartItem);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing cart item ${doc.id}: $e');
          }
          // Skip invalid items
        }
      }

      if (kDebugMode) {
        print(
          'Cart loaded from Firebase for restaurant: ${cartItems.length} items',
        );
      }
      return cartItems;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cart from Firebase: $e');
      }
      return [];
    }
  }

  /// Add single item to Firebase cart (only for logged-in restaurant owners)
  Future<void> addItemToFirebaseCart(MenuCartItem cartItem) async {
    if (!isOwnerLoggedIn) return;

    try {
      final cartCollection = await _cartCollection;
      if (cartCollection == null) return;

      await cartCollection.doc(cartItem.menuItem.id).set({
        'menuItem': cartItem.menuItem.toJson(),
        'quantity': cartItem.quantity,
        'addedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error adding item to Firebase cart: $e');
      }
    }
  }

  /// Update item quantity in Firebase cart (only for logged-in restaurant owners)
  Future<void> updateItemQuantityInFirebase(
    String menuItemId,
    int quantity,
  ) async {
    if (!isOwnerLoggedIn) return;

    try {
      final cartCollection = await _cartCollection;
      if (cartCollection == null) return;

      if (quantity <= 0) {
        await cartCollection.doc(menuItemId).delete();
      } else {
        await cartCollection.doc(menuItemId).update({
          'quantity': quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating item quantity in Firebase: $e');
      }
    }
  }

  /// Remove item from Firebase cart (only for logged-in restaurant owners)
  Future<void> removeItemFromFirebaseCart(String menuItemId) async {
    if (!isOwnerLoggedIn) return;

    try {
      final cartCollection = await _cartCollection;
      if (cartCollection == null) return;

      await cartCollection.doc(menuItemId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error removing item from Firebase cart: $e');
      }
    }
  }

  /// Clear entire Firebase cart (only for logged-in restaurant owners)
  Future<void> clearFirebaseCart() async {
    if (!isOwnerLoggedIn) return;

    try {
      final cartCollection = await _cartCollection;
      if (cartCollection == null) return;

      final batch = _firestore.batch();
      final snapshot = await cartCollection.get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      if (kDebugMode) {
        print('Firebase cart cleared for restaurant');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing Firebase cart: $e');
      }
    }
  }

  /// Save applied offers to Firebase (only for logged-in restaurant owners)
  Future<void> saveOffersToFirebase(List<AppliedOffer> offers) async {
    if (!isOwnerLoggedIn) return;

    try {
      final restaurantId = await _restaurantId;
      if (restaurantId == null) return;

      final offersRef = _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('applied_offers');

      // Clear existing offers
      final batch = _firestore.batch();
      final existingOffers = await offersRef.get();
      for (final doc in existingOffers.docs) {
        batch.delete(doc.reference);
      }

      // Add new offers
      for (final offer in offers) {
        final docRef = offersRef.doc(offer.id);
        batch.set(docRef, {
          'id': offer.id,
          'title': offer.title,
          'description': offer.description,
          'discountAmount': offer.discountAmount,
          'appliedAt': Timestamp.fromDate(offer.appliedAt),
        });
      }

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Error saving offers to Firebase: $e');
      }
    }
  }

  /// Load applied offers from Firebase (only for logged-in restaurant owners)
  Future<List<AppliedOffer>> loadOffersFromFirebase() async {
    if (!isOwnerLoggedIn) return [];

    try {
      final restaurantId = await _restaurantId;
      if (restaurantId == null) return [];

      final snapshot = await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('applied_offers')
          .get();

      final offers = <AppliedOffer>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          final offer = AppliedOffer(
            id: data['id'],
            title: data['title'],
            description: data['description'],
            discountAmount: data['discountAmount'].toDouble(),
            appliedAt: (data['appliedAt'] as Timestamp).toDate(),
          );
          offers.add(offer);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing offer ${doc.id}: $e');
          }
        }
      }

      return offers;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading offers from Firebase: $e');
      }
      return [];
    }
  }

  /// Migrate local cart to Firebase when restaurant owner logs in
  Future<void> migrateLocalCartToFirebase(
    List<MenuCartItem> localCartItems,
    List<AppliedOffer> localOffers,
  ) async {
    if (!isOwnerLoggedIn) return;

    try {
      // Load existing cart from Firebase
      final existingCartItems = await loadCartFromFirebase();
      final existingOffers = await loadOffersFromFirebase();

      // Merge local cart with existing Firebase cart
      final mergedCart = <String, MenuCartItem>{};

      // Add existing Firebase items first
      for (final item in existingCartItems) {
        mergedCart[item.menuItem.id] = MenuCartItem(
          menuItem: item.menuItem,
          quantity: item.quantity,
        );
      }

      // Add/update with local items (but don't duplicate)
      for (final item in localCartItems) {
        if (mergedCart.containsKey(item.menuItem.id)) {
          // Only add quantity if it's reasonable (prevent excessive duplication)
          final existingQty = mergedCart[item.menuItem.id]!.quantity;
          final newQty = item.quantity;

          // Cap the total quantity to prevent runaway duplication
          final maxReasonableQty = 10; // Reasonable max for any single item
          final combinedQty = existingQty + newQty;

          if (combinedQty <= maxReasonableQty) {
            mergedCart[item.menuItem.id]!.quantity = combinedQty;
          } else {
            // Use the higher of the two quantities instead of adding
            mergedCart[item.menuItem.id]!.quantity = existingQty > newQty
                ? existingQty
                : newQty;
          }

          if (kDebugMode) {
            print(
              'Merged item ${item.menuItem.name}: existing=$existingQty, local=$newQty, final=${mergedCart[item.menuItem.id]!.quantity}',
            );
          }
        } else {
          mergedCart[item.menuItem.id] = MenuCartItem(
            menuItem: item.menuItem,
            quantity: item.quantity,
          );
        }
      }

      // Save merged cart to Firebase
      await saveCartToFirebase(mergedCart.values.toList());

      // Merge offers (avoid duplicates by ID)
      final mergedOffers = <String, AppliedOffer>{};
      for (final offer in existingOffers) {
        mergedOffers[offer.id] = offer;
      }
      for (final offer in localOffers) {
        if (!mergedOffers.containsKey(offer.id)) {
          mergedOffers[offer.id] = offer;
        }
      }

      // Save merged offers to Firebase
      await saveOffersToFirebase(mergedOffers.values.toList());

      if (kDebugMode) {
        print(
          'Local cart migrated to Firebase for restaurant: ${mergedCart.length} items, ${mergedOffers.length} offers',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error migrating local cart to Firebase: $e');
      }
    }
  }

  /// Get restaurant name for display
  Future<String> getRestaurantName() async {
    try {
      final ownerId = _ownerId;
      if (ownerId == null) return 'Guest';

      final restaurant = await _restaurantService.getRestaurantByOwnerId(
        ownerId,
      );
      return restaurant?.name ?? 'Restaurant Owner';
    } catch (e) {
      return 'Restaurant Owner';
    }
  }

  /// Listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
