# Firebase Cart Persistence - Restaurant Owner Based

## Overview
Your FoodieHub app now has Firebase cart persistence based on restaurant owner authentication! Cart items are automatically saved to Firebase when restaurant owners are logged in and stored under their restaurant ID.

## How It Works

### 🏪 **Restaurant Owner Authentication**
- Uses existing restaurant owner login system
- Each restaurant owner has a unique restaurant ID
- Cart data is stored per restaurant, not per user

### 📱 **Cart Sync Behavior**

#### **Guest Users (No Restaurant Owner Login):**
- ❌ Cart stored locally only
- ❌ No Firebase sync
- 🔴 Gray cloud icon (cart local only)
- 📝 "Login as restaurant owner to save cart" message

#### **Restaurant Owner Logged In:**
- ✅ Cart automatically syncs to Firebase
- ✅ Stored under restaurant ID in Firestore
- 🟢 Green cloud icon (cart synced)
- 📝 "Cart synced to restaurant cloud ☁️" message

## Firebase Data Structure

```
restaurants/
  └── {restaurantId}/
      ├── cart/
      │   └── {menuItemId}/
      │       ├── menuItem: {...}
      │       ├── quantity: number
      │       ├── addedAt: timestamp
      │       └── updatedAt: timestamp
      └── applied_offers/
          └── {offerId}/
              ├── id: string
              ├── title: string
              ├── description: string
              ├── discountAmount: number
              └── appliedAt: timestamp
```

## Key Features

### ✅ **Restaurant-Specific Cart Storage**
- Each restaurant owner's cart is stored separately
- Cart items are associated with the restaurant ID
- Multiple restaurant owners can have different carts

### ✅ **Automatic Sync**
- Cart syncs automatically when restaurant owner logs in
- Real-time updates to Firebase on cart changes
- Local cart migrates to Firebase on login

### ✅ **Visual Indicators**
- **Home Screen**: Cloud icon shows sync status
- **Cart Screen**: Cloud icon in app bar + status message
- **Green Cloud**: Synced to restaurant Firebase
- **Gray Cloud**: Local cart only

## User Interface

### Home Screen Header
- Restaurant owner login button (existing)
- Cart sync status icon (new)
- Cart button with item count

### Cart Screen
- Cloud sync icon in app bar
- Manual sync button (works only when logged in)
- Status message at bottom of cart
- Restaurant owner login prompt when not logged in

## Files Created/Modified

### New Files:
- `lib/services/firebase_cart_service.dart` - Restaurant-based Firebase operations
- `RESTAURANT_CART_FIREBASE.md` - This documentation

### Modified Files:
- `lib/providers/menu_cart_provider.dart` - Restaurant owner authentication integration
- `lib/screens/cart_screen.dart` - Restaurant owner sync status
- `lib/screens/new_home_screen.dart` - Cart sync indicator in header

## Testing Guide

### 1. Test Guest User (No Sync)
1. Open app without logging in as restaurant owner
2. Add items to cart
3. Check home screen - should see gray cloud icon
4. Go to cart - should see "Login as restaurant owner to save cart"
5. Close and reopen app - cart items lost (expected)

### 2. Test Restaurant Owner Login
1. Add items to cart as guest
2. Tap restaurant owner login button in header
3. Login with existing restaurant owner account
4. Cart should migrate to Firebase
5. Cloud icon should turn green
6. Status should show "Cart synced to restaurant cloud ☁️"

### 3. Test Persistence for Restaurant Owner
1. While logged in as restaurant owner, add items to cart
2. Close app completely
3. Reopen app
4. Should still be logged in (green cloud icon)
5. Cart items should be restored from Firebase

### 4. Test Manual Sync
1. While logged in as restaurant owner
2. Tap green cloud icon in cart screen
3. Should see "Cart synced to restaurant cloud! ☁️" message

### 5. Test Logout
1. While logged in with items in cart
2. Logout from restaurant owner account
3. Cloud icon should turn gray
4. Cart items remain locally but won't sync

## Firebase Console Verification

1. Go to Firebase Console → Firestore Database
2. Navigate to `restaurants` collection
3. Find your restaurant document by ID
4. Check for `cart` and `applied_offers` subcollections
5. Only logged-in restaurant owners will have cart data

## Benefits

### For Restaurant Owners:
- Cart persists across app sessions
- No data loss when managing restaurant
- Clear visual feedback about sync status
- Seamless integration with existing login system

### For Development:
- Uses existing authentication system
- No additional user management needed
- Restaurant-specific data organization
- Scalable for multiple restaurant owners

## Technical Implementation

### Authentication Flow:
1. Restaurant owner logs in via existing system
2. `AuthProvider` manages authentication state
3. `FirebaseCartService` checks owner login status
4. Cart syncs automatically when owner is authenticated

### Data Flow:
1. Cart operations check `isOwnerLoggedIn`
2. If logged in: sync to Firebase under restaurant ID
3. If not logged in: store locally only
4. On login: migrate local cart to Firebase

## Security

- Only authenticated restaurant owners can sync carts
- Each restaurant's cart data is isolated
- Uses existing Firebase security rules
- No cross-restaurant data access

## Future Enhancements

### Possible Additions:
- Multiple restaurant management per owner
- Cart analytics per restaurant
- Order history integration
- Staff member cart access
- Restaurant-specific offers and promotions

## Troubleshooting

### Cart Not Syncing?
1. Verify restaurant owner is logged in (green cloud icon)
2. Check internet connection
3. Try manual sync button in cart
4. Check Firebase Console for restaurant data

### Login Issues?
1. Use existing restaurant owner credentials
2. Ensure restaurant is properly registered
3. Check Firebase Authentication in console

### Data Not Appearing?
1. Confirm correct restaurant owner account
2. Check if items were added before login
3. Verify restaurant ID in Firebase Console

Your restaurant-based Firebase cart persistence is now fully functional! 🏪🛒☁️

## Quick Commands

```bash
# Run the app
flutter run

# Check for issues
flutter doctor

# View Firebase data
# Go to Firebase Console → Firestore → restaurants collection
```