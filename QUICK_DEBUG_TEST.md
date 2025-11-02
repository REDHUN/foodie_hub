# Quick Debug Test for Cart Loading

## The Issue
Cart items not showing after app restart when restaurant owner is logged in.

## Quick Debug Steps

### 1. **Check Console Logs**
When you open the app, look for these messages in debug console:
- ✅ `User found logged in during initialization - loading cart`
- ✅ `Cart loaded from Firebase for restaurant: X items, Y offers`
- ❌ `No logged in user found during initialization`

### 2. **Long Press Cloud Icon Test**
1. In home screen, **long press the cloud icon** (next to cart)
2. This will:
   - Force load cart from Firebase
   - Show debug info in console
   - Display result in snackbar
3. Check console for detailed debug output

### 3. **Check What Console Shows**
Look for this debug output:
```
=== CART DEBUG STATE ===
Is initialized: true
Is loading: false
Is owner logged in: true/false
Cart items count: X
Firebase Auth user: [user_id or null]
User is anonymous: false/true
Restaurant ID: [restaurant_id or null]
========================
```

### 4. **Manual Refresh Options**
If automatic loading fails, try:
- **Short tap cloud icon** - Manual refresh
- **Pull down in cart screen** - Refresh from Firebase
- **Go to cart and pull down** - Force refresh

## What to Tell Me

Based on the debug output, tell me:

1. **What does the console show when app starts?**
   - Does it find logged in user?
   - Does it attempt to load cart?

2. **What does long press cloud icon show?**
   - Is owner logged in: true/false?
   - Firebase Auth user: [user_id] or null?
   - Restaurant ID: [restaurant_id] or null?
   - Cart items count: X?

3. **Does manual refresh work?**
   - Short tap cloud icon - does it load items?
   - Pull to refresh in cart - does it work?

## Expected Results

### ✅ **Working Scenario:**
```
Console on app start:
- User found logged in during initialization - loading cart
- Cart loaded from Firebase for restaurant: 3 items, 0 offers

Long press debug:
- Is owner logged in: true
- Firebase Auth user: abc123xyz
- Restaurant ID: rest_1234567890
- Cart items count: 3
```

### ❌ **Broken Scenario:**
```
Console on app start:
- No logged in user found during initialization

Long press debug:
- Is owner logged in: false
- Firebase Auth user: null
- Restaurant ID: null
- Cart items count: 0
```

## Quick Fixes to Try

### If user not detected as logged in:
1. **Wait 10 seconds** after app start, then try long press
2. **Go to owner dashboard** - verify you're actually logged in
3. **Logout and login again** - refresh auth state

### If user logged in but no restaurant ID:
1. **Check if restaurant was created properly**
2. **Try re-registering restaurant**
3. **Check Firebase Console** for restaurant data

### If restaurant ID found but no cart items:
1. **Check Firebase Console** - verify cart data exists
2. **Try adding new items** to cart and test again
3. **Manual refresh** using cloud icon tap

## Next Steps

Run the debug test and share the console output with me. This will help identify exactly where the issue is occurring so we can fix it properly.

The key is to see:
1. Is Firebase Auth working?
2. Is restaurant ID being found?
3. Is Firebase cart data actually there?
4. Is the loading process being triggered?