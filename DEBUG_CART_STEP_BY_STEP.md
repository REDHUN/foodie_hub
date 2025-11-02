# Debug Cart Loading - Step by Step

## Problem
Cart items not showing after app restart even when user is logged in.

## Debug Steps

### Step 1: Check Debug Console
1. Open app with debug console visible
2. Look for these messages during app startup:
   ```
   User found logged in during initialization - loading cart
   Cart loaded from Firebase for restaurant: X items, Y offers
   ```
3. If you don't see these messages, the initialization is not working

### Step 2: Manual Debug Test
1. **Long press the cloud icon** in home screen header
2. This will:
   - Show debug state in console
   - Force load cart from Firebase
   - Show result in snackbar
3. Check console for detailed debug information

### Step 3: Test Firebase Connection
Add this temporary code to test Firebase directly:

```dart
// In any screen, add a test button
ElevatedButton(
  onPressed: () async {
    final cartProvider = context.read<MenuCartProvider>();
    await cartProvider.testFirebaseConnection();
  },
  child: Text('Test Firebase'),
)
```

### Step 4: Check Firebase Console
1. Go to Firebase Console → Firestore Database
2. Navigate to `restaurants` collection
3. Find your restaurant document
4. Check if `cart` subcollection exists with items
5. Verify the data structure matches expected format

### Step 5: Manual Cart Loading
If automatic loading fails, try manual methods:

1. **Tap cloud icon** (short tap) - Manual refresh
2. **Long press cloud icon** - Force load with debug
3. **Pull down in cart screen** - Refresh from Firebase
4. **Restart app** - Sometimes takes 2-3 attempts

## Expected Debug Output

### Successful Initialization:
```
User found logged in during initialization - loading cart
Firebase Auth User: [user_id]
Restaurant found: [restaurant_name] (ID: [restaurant_id])
Cart documents in Firebase: 3
Cart loaded from Firebase for restaurant: 3 items, 0 offers
```

### Failed Initialization:
```
No logged in user found during initialization
Firebase Auth User: null
```

## Common Issues & Solutions

### Issue 1: User Not Detected as Logged In
**Symptoms:** Console shows "No logged in user found"
**Solutions:**
- Wait 5-10 seconds after app start
- Try manual force load (long press cloud icon)
- Check if user is actually logged in (go to owner dashboard)

### Issue 2: Restaurant Not Found
**Symptoms:** "Restaurant found: null"
**Solutions:**
- Verify restaurant was properly created during registration
- Check if owner ID matches Firebase Auth user ID
- Re-register restaurant if needed

### Issue 3: Firebase Data Exists But Not Loading
**Symptoms:** Firebase Console shows data but app cart is empty
**Solutions:**
- Check data structure format
- Verify collection path: `restaurants/{restaurantId}/cart`
- Try manual refresh methods

### Issue 4: Network/Permission Issues
**Symptoms:** Firebase connection errors
**Solutions:**
- Check internet connection
- Verify Firebase project configuration
- Check Firestore security rules

## Quick Fix Attempts

### Method 1: Force Initialization
```dart
// Add this to any screen for testing
final cartProvider = context.read<MenuCartProvider>();
await cartProvider.forceLoadCartFromFirebase();
```

### Method 2: Manual Firebase Load
```dart
// Direct Firebase access test
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  final restaurant = await RestaurantService().getRestaurantByOwnerId(user.uid);
  if (restaurant != null) {
    final cartRef = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(restaurant.id)
        .collection('cart');
    final snapshot = await cartRef.get();
    print('Cart items in Firebase: ${snapshot.docs.length}');
  }
}
```

### Method 3: Reset and Retry
1. Logout from restaurant owner account
2. Close app completely
3. Reopen app
4. Login again
5. Add test items to cart
6. Close and reopen app to test

## Debug Checklist

- [ ] Console shows initialization messages
- [ ] Firebase Auth user is detected
- [ ] Restaurant ID is found
- [ ] Firebase Console shows cart data
- [ ] Manual force load works
- [ ] Network connection is stable
- [ ] App has proper Firebase permissions

## Next Steps

If none of the above works:
1. **Check Firebase project configuration**
2. **Verify Firestore security rules**
3. **Test with different restaurant owner account**
4. **Clear app data and start fresh**
5. **Check for Firebase SDK version issues**

Use the debug methods to identify exactly where the process is failing, then we can fix the specific issue.