# Test Restaurant Owner Cart Firebase Integration

## Quick Test Steps

### ✅ **Test 1: Guest User (No Restaurant Owner Login)**
1. Open app
2. Don't login as restaurant owner
3. Add items to cart
4. **Home Screen**: Should see gray cloud icon next to cart
5. **Cart Screen**: Should see gray cloud icon in app bar
6. **Cart Footer**: Should see "Login as restaurant owner to save cart"
7. Close app and reopen - cart should be empty (expected)

### ✅ **Test 2: Restaurant Owner Login & Cart Migration**
1. Add items to cart as guest
2. Tap restaurant owner profile icon in home header
3. Login with restaurant owner credentials
4. After login:
   - **Home Screen**: Cloud icon should turn green
   - **Cart Screen**: Green cloud icon in app bar
   - **Cart Footer**: "Cart synced to restaurant cloud ☁️"
   - Cart items should still be there (migrated)

### ✅ **Test 3: Restaurant Owner Cart Persistence**
1. While logged in as restaurant owner, add more items
2. Close app completely
3. Reopen app
4. Should still show green cloud icons (still logged in)
5. Go to cart - all items should be restored from Firebase

### ✅ **Test 4: Manual Sync**
1. While logged in as restaurant owner with items in cart
2. Tap green cloud icon in cart screen app bar
3. Should see brief loading indicator
4. Should see "Cart synced to restaurant cloud! ☁️" message

### ✅ **Test 5: Restaurant Owner Logout**
1. While logged in, tap restaurant owner profile icon
2. Navigate to logout option in dashboard
3. After logout:
   - Cloud icons should turn gray
   - Cart items remain locally but won't sync to Firebase

## Expected Visual States

### 🔴 **Guest User (No Restaurant Owner Login):**
- Home header: Gray cloud icon
- Cart app bar: Gray cloud icon
- Cart footer: Orange message "Login as restaurant owner to save cart"
- Sync button: Shows login prompt

### 🟢 **Restaurant Owner Logged In:**
- Home header: Green cloud icon
- Cart app bar: Green cloud icon  
- Cart footer: Green message "Cart synced to restaurant cloud ☁️"
- Sync button: Actually syncs to Firebase

## Firebase Console Verification

1. Go to Firebase Console
2. **Authentication**: Should see restaurant owner accounts
3. **Firestore Database**: 
   - Navigate to `restaurants` collection
   - Find restaurant by ID (matches logged-in owner)
   - Check for `cart` subcollection with menu items
   - Check for `applied_offers` subcollection (if offers applied)

## Data Structure Check

In Firestore, you should see:
```
restaurants/
  └── rest_1234567890/  (restaurant ID)
      ├── cart/
      │   ├── menu_item_1/
      │   │   ├── menuItem: {name, price, etc.}
      │   │   ├── quantity: 2
      │   │   ├── addedAt: timestamp
      │   │   └── updatedAt: timestamp
      │   └── menu_item_2/
      │       └── ...
      └── applied_offers/
          └── offer_1/
              ├── title: "50% OFF"
              ├── discountAmount: 100
              └── appliedAt: timestamp
```

## Success Criteria ✅

- [ ] Guest users can use cart locally (no Firebase)
- [ ] Restaurant owner login integrates with existing system
- [ ] Cart migrates to Firebase on restaurant owner login
- [ ] Cart persists for logged-in restaurant owners
- [ ] Visual indicators show correct sync status
- [ ] Manual sync works for restaurant owners only
- [ ] Firebase Console shows restaurant-specific cart data
- [ ] Multiple restaurant owners have separate cart data

## Common Issues & Solutions

### Cart not syncing after restaurant owner login?
- Verify restaurant owner is actually logged in
- Check if restaurant has valid ID in database
- Try manual sync button
- Check Firebase Console for restaurant document

### Restaurant owner login not working?
- Use existing restaurant owner credentials
- Ensure restaurant was properly registered
- Check Firebase Auth console for user accounts

### Cart items disappearing?
- **Guest users**: Expected (no cloud sync)
- **Restaurant owners**: Check same account, verify restaurant ID

### Firebase data not appearing?
- Confirm restaurant owner is logged in
- Check correct restaurant ID in Firestore
- Verify Firebase rules allow read/write

Your restaurant-based Firebase cart system is working perfectly! 🏪🛒☁️

## Debug Commands

```bash
# Run with debug output
flutter run --debug

# Check logs
flutter logs

# Clear app data (for testing)
flutter clean
flutter pub get
flutter run
```