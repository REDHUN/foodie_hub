# Debug Cart Loading Issue

## Problem
Cart items are not loading when restaurant owner logs out and logs in again.

## Solutions Implemented

### 1. Enhanced Authentication State Handling
- Added debugging logs to track authentication state changes
- Added delay to ensure restaurant data is available before loading cart
- Improved error handling in cart loading process

### 2. Manual Cart Loading Methods
- `loadCartAfterLogin()` - Called after successful login
- `refreshCartFromFirebase()` - Manual refresh from Firebase
- Enhanced `_refreshCart()` in cart screen to load from Firebase

### 3. Multiple Trigger Points
- **Automatic**: Auth state change listener
- **Manual**: After login in owner login screen
- **Pull-to-refresh**: In cart screen
- **Tap-to-refresh**: Cloud icon in home screen header

## Testing Steps

### Test 1: Login and Check Debug Logs
1. Open app and check debug console
2. Login as restaurant owner
3. Look for these debug messages:
   ```
   Auth state changed: [user_id] (anonymous: false)
   Restaurant owner logged in - loading cart from Firebase
   Cart loaded from Firebase for restaurant: X items, Y offers
   ```

### Test 2: Manual Refresh Methods
1. Login as restaurant owner
2. Add items to cart
3. Logout and login again
4. If cart is empty, try these manual refresh options:
   - **Pull down** in cart screen to refresh
   - **Tap cloud icon** in home screen header
   - **Tap sync button** in cart screen app bar

### Test 3: Check Firebase Console
1. Go to Firebase Console → Firestore
2. Navigate to `restaurants/{restaurantId}/cart`
3. Verify cart items are actually saved there
4. Check if restaurant ID matches the logged-in owner

## Debug Information

### Check These Values:
- `FirebaseAuth.instance.currentUser?.uid` - Should match restaurant owner ID
- `RestaurantService.getRestaurantByOwnerId(ownerId)` - Should return restaurant
- Cart collection path: `restaurants/{restaurantId}/cart`

### Common Issues:
1. **Restaurant ID not found** - Restaurant not properly registered
2. **Authentication delay** - Firebase Auth state not updated immediately
3. **Network issues** - Firebase connection problems
4. **Timing issues** - Cart loading before restaurant data is available

## Quick Fixes

### If cart still not loading:
1. **Force refresh**: Tap cloud icon in home screen
2. **Pull to refresh**: In cart screen
3. **Re-login**: Logout and login again
4. **Check network**: Ensure internet connection
5. **Restart app**: Close and reopen app

### Debug Commands:
```bash
# Run with debug output
flutter run --debug

# Check logs
flutter logs

# Clear app data
flutter clean
flutter pub get
flutter run
```

## Code Changes Made

### MenuCartProvider:
- Added `loadCartAfterLogin()` method
- Added `refreshCartFromFirebase()` method
- Enhanced `_handleAuthStateChange()` with debugging
- Added delays to handle timing issues

### OwnerLoginScreen:
- Added cart loading after successful login
- Calls `cartProvider.loadCartAfterLogin()`

### CartScreen:
- Updated `_refreshCart()` to load from Firebase
- Enhanced refresh indicator functionality

### HomeScreen:
- Made cloud icon tappable for manual refresh
- Added success feedback for manual refresh

The cart should now load properly after login. If issues persist, use the manual refresh options or check the debug logs for specific error messages.