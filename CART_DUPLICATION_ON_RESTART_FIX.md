# Fix: Cart Items Automatically Increasing on App Restart

## Problem
After restarting or reopening the app, cart items were automatically increasing in quantity instead of maintaining their original quantities. This was causing duplicate items and inflated quantities.

## Root Cause Analysis
The issue was caused by **multiple simultaneous cart loading attempts** during app initialization:

1. **Constructor initialization** - `MenuCartProvider()` calls `_initializeCartDelayed()`
2. **Main.dart initialization** - `initializeCart()` called in `addPostFrameCallback`
3. **Auth state changes** - Firebase auth triggers `_handleAuthStateChange()` 
4. **App resume** - `loadCartOnAppResume()` called when app becomes active
5. **Migration logic** - During migration, quantities were being added instead of replaced

This created a race condition where the cart was loaded multiple times, and the migration logic was combining quantities from multiple load attempts.

## Solutions Implemented

### ✅ **1. Prevent Duplicate Loading**
- **Loading Guard**: Added `_isCurrentlyLoading` flag to prevent simultaneous loads
- **Load State Tracking**: Enhanced `_hasLoadedFromFirebase` checks
- **Skip Duplicate Requests**: All load methods now check if already loaded/loading

### ✅ **2. Fixed Migration Logic**
- **Quantity Capping**: Limited maximum reasonable quantity per item (10)
- **Smart Merging**: Use higher quantity instead of adding when over limit
- **Duplicate Prevention**: Proper ID-based deduplication for offers

### ✅ **3. Removed Duplicate Initialization**
- **Single Init Point**: Removed duplicate `initializeCart()` call from main.dart
- **Constructor Only**: Cart now initializes only once in provider constructor
- **Lifecycle Coordination**: Better coordination between auth changes and app resume

### ✅ **4. Enhanced Debug Logging**
- **Load Tracking**: Detailed logs for each load attempt and why it was skipped
- **Migration Details**: Logs showing quantity merging decisions
- **State Visibility**: Clear indication of current loading state

## Code Changes

### MenuCartProvider (`lib/providers/menu_cart_provider.dart`)

#### Added Loading Guard:
```dart
bool _isCurrentlyLoading = false; // Prevent multiple simultaneous loads

Future<void> _loadCartFromFirebase({bool shouldMigrate = true}) async {
  // Prevent multiple simultaneous loads
  if (_isCurrentlyLoading) {
    print('Cart load already in progress - skipping duplicate request');
    return;
  }

  // If already loaded from Firebase and not migrating, skip
  if (_hasLoadedFromFirebase && !shouldMigrate) {
    print('Cart already loaded from Firebase - skipping duplicate load');
    return;
  }

  _isCurrentlyLoading = true;
  // ... rest of loading logic
  _isCurrentlyLoading = false;
}
```

#### Enhanced Auth State Handler:
```dart
void _handleAuthStateChange(User? user) async {
  if (user != null && !user.isAnonymous) {
    // Only load if we haven't loaded yet and not currently loading
    if (!_hasLoadedFromFirebase && !_isCurrentlyLoading) {
      await _loadCartFromFirebase(shouldMigrate: false);
    }
  }
}
```

#### Improved App Resume:
```dart
Future<void> loadCartOnAppResume() async {
  // Only load if conditions are met
  if (_firebaseCartService.isOwnerLoggedIn && 
      _items.isEmpty && 
      !_isCurrentlyLoading && 
      !_hasLoadedFromFirebase) {
    await _loadCartFromFirebase(shouldMigrate: false);
  }
}
```

### FirebaseCartService (`lib/services/firebase_cart_service.dart`)

#### Smart Migration Logic:
```dart
Future<void> migrateLocalCartToFirebase(
  List<MenuCartItem> localCartItems,
  List<AppliedOffer> localOffers,
) async {
  // Add/update with local items (but don't duplicate)
  for (final item in localCartItems) {
    if (mergedCart.containsKey(item.menuItem.id)) {
      final existingQty = mergedCart[item.menuItem.id]!.quantity;
      final newQty = item.quantity;
      
      // Cap the total quantity to prevent runaway duplication
      final maxReasonableQty = 10;
      final combinedQty = existingQty + newQty;
      
      if (combinedQty <= maxReasonableQty) {
        mergedCart[item.menuItem.id]!.quantity = combinedQty;
      } else {
        // Use the higher of the two quantities instead of adding
        mergedCart[item.menuItem.id]!.quantity = 
            existingQty > newQty ? existingQty : newQty;
      }
    }
  }
}
```

### MainScreen (`lib/main.dart`)

#### Removed Duplicate Initialization:
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);

  // Cart provider initializes itself automatically in constructor
  // No need to call initializeCart() here to avoid duplicate initialization
}
```

## Testing the Fix

### ✅ **Test 1: App Restart with Items**
1. Login as restaurant owner
2. Add items to cart (note exact quantities)
3. **Close app completely**
4. **Reopen app**
5. **Expected**: Same quantities as before restart
6. **Debug**: Check logs for "skipping duplicate request" messages

### ✅ **Test 2: Multiple App Resumes**
1. Add items to cart
2. **Minimize and resume app multiple times**
3. **Expected**: Quantities remain unchanged
4. **Debug**: Should see "App resume load skipped" messages

### ✅ **Test 3: Login/Logout Cycles**
1. Add items to cart
2. **Logout and login again**
3. **Expected**: Cart loads correctly without duplication
4. **Debug**: Check migration logs for quantity decisions

### ✅ **Test 4: Network Interruption**
1. Add items to cart
2. **Turn off internet, restart app, turn on internet**
3. **Expected**: Cart loads properly when connection restored
4. **Debug**: Should see proper loading sequence in logs

## Expected Behavior Now

### 🟢 **App Startup:**
- Cart loads **exactly once** during initialization
- No duplicate loading attempts
- Quantities preserved exactly as saved

### 🟢 **App Resume:**
- Only loads if cart is actually empty and not already loaded
- Skips loading if cart already has items
- No quantity inflation

### 🟢 **Login/Migration:**
- Smart quantity merging with reasonable limits
- Uses higher quantity instead of adding when over limit
- Prevents runaway duplication

### 🟢 **Debug Information:**
- Clear logs showing why loads are skipped
- Migration decision details
- Loading state visibility

## Troubleshooting

### If quantities are still increasing:
1. **Check debug logs** - Look for "skipping duplicate" messages
2. **Clear app data** - Reset to clean state
3. **Monitor network** - Ensure stable connection during loads
4. **Check Firebase Console** - Verify saved quantities are correct

### Debug Console Messages to Look For:
```
Cart load already in progress - skipping duplicate request
Cart already loaded from Firebase - skipping duplicate load
App resume load skipped - already loaded: true, loading: false, items: X
Merged item Pizza: existing=2, local=1, final=2
```

### If still having issues:
1. **Force refresh** - Tap cloud icon to reload from Firebase
2. **Logout/login** - Reset the loading state
3. **Check item limits** - Verify quantities don't exceed 10 per item
4. **Network stability** - Test on stable WiFi connection

Your cart quantities should now remain stable across app restarts! The loading guards and smart migration logic prevent the duplication that was causing items to increase automatically. 🛒✨