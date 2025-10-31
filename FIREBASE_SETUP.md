# Firebase Setup Guide

This guide will help you set up and use Firebase with the FoodieHub Flutter app.

## Prerequisites

- A Firebase account (sign up at https://firebase.google.com/)
- Flutter CLI installed and working
- Android/iOS development environment set up

## ⚠️ IMPORTANT: First-Time Setup

### Step 1: Enable Firestore Database

Before using the app, you **MUST** enable Firestore in the Firebase Console:

1. Go to: https://console.firebase.google.com/project/foodiehub-e8805/firestore
2. Click **"Create Database"** or **"Get Started"**
3. Choose **"Start in test mode"** (for development)
4. Select a location (choose the closest to your users, e.g., `asia-south1` for India)
5. Click **"Enable"**

**Why this is required**: The app needs a Firestore database to store and retrieve data. Without it, you'll see connection errors.

### Step 2: Enable Email/Password Authentication

Restaurant owners sign in with email and password. Enable this provider in Firebase:

1. Go to: https://console.firebase.google.com/project/foodiehub-e8805/authentication/users
2. Open the **Sign-in method** tab
3. Enable **Email/Password** and click **Save**
4. (Optional) Disable anonymous access if you don't need it

### Step 3: Migrate Sample Data

After enabling Firestore, use the Firebase Setup screen in the app to migrate sample data.

## Firebase Configuration

The app is already configured with Firebase! Here's what has been set up:

### ✅ Completed Configuration

1. **Firebase Project**: `foodiehub-e8805`
2. **Dependencies**: All required Firebase packages are installed
3. **Firebase Options**: Platform-specific configuration files are in place
4. **Services**: Restaurant and Menu Item services created
5. **Providers**: Restaurant and Menu Item providers implemented
6. **UI**: NewHomeScreen updated to use Firebase data

### Firebase Packages Installed

- `firebase_core: ^3.6.0`
- `firebase_auth: ^5.3.1`
- `cloud_firestore: ^5.4.3`
- `firebase_storage: ^12.3.4`

## Firestore Database Structure

### Collections

#### 1. `restaurants`
Stores restaurant information.

```json
{
  "id": "string",
  "name": "string",
  "image": "string (URL)",
  "cuisine": "string",
  "rating": "number",
  "deliveryTime": "string",
  "deliveryFee": "number",
  "discount": "string (optional)",
  "ownerId": "string (Firebase Auth UID)"
}
```

##### `menuItems` subcollection
Each restaurant document contains a `menuItems` subcollection.

- Path: `restaurants/{restaurantId}/menuItems/{menuItemId}`
- Stores menu items belonging to the specific restaurant
- `restaurantId` field must match the parent document ID

```json
{
  "id": "string",
  "restaurantId": "string", // kept for reference
  "name": "string",
  "description": "string",
  "price": "number",
  "image": "string (URL)",
  "category": "string"
}
```

## How to Use

### Option 1: Use the Firebase Setup Screen (Recommended)

1. Navigate to `lib/screens/firebase_setup_screen.dart`
2. Add a navigation button in your app to access this screen
3. Click "Migrate Sample Data" to populate Firebase with sample data
4. The app will automatically use Firebase data once it's available

### Option 2: Manual Migration

You can also manually run the migration script:

```dart
import 'package:foodiehub/utils/firebase_migration.dart';

final migration = FirebaseMigration();
await migration.migrateSampleData();
```

### Accessing Firebase Setup Screen

To add the Firebase Setup screen to your app, you can add it to your main screen or navigation:

```dart
// In your app bar or navigation
IconButton(
  icon: Icon(Icons.settings),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FirebaseSetupScreen(),
      ),
    );
  },
)
```

## Firebase Features

### Real-time Data Syncing

The app uses Firebase Firestore for real-time data synchronization:

- Restaurant data syncs automatically
- Menu items update in real-time
- Changes reflect immediately across all devices

### Offline Support

Firestore provides offline support out of the box:

- App works offline and syncs when connection is restored
- Local caching ensures smooth performance

### Data Management

Use the Firebase console to:

- View and edit data: https://console.firebase.google.com/project/foodiehub-e8805/firestore
- Add new restaurants and menu items
- Update existing data
- Monitor usage and performance

## Restaurant Owner Portal

Restaurant owners authenticate with Firebase Auth and manage their menus from the in-app dashboard.

### Sign-up Flow (Recommended)
- On the home screen, tap the **Owner Login** avatar → **Sign up**
- Enter email, password, and restaurant details
- The app creates a Firebase Auth user and a Firestore restaurant document with `ownerId`
- After sign-up, the owner is redirected to the dashboard to manage menu items

### Linking Existing Restaurants
- Edit the restaurant document in Firestore and set `ownerId` to the owner's Firebase Auth UID
- Owners can now log in with the email/password associated with that UID
- Ensure security rules (above) are published so only the owner can modify their data

### Sample Data Owners
- Sample migration seeds Firebase Auth with owner accounts and links them to restaurants:

| Restaurant        | Email                     | Password     |
|-------------------|---------------------------|--------------|
| Pizza Hut         | owner1@foodiehub.com      | password123  |
| Burger King       | owner2@foodiehub.com      | password123  |
| Sushi Station     | owner3@foodiehub.com      | password123  |
| La Pinoz Pizza    | owner4@foodiehub.com      | password123  |
| The Bowl Company  | owner5@foodiehub.com      | password123  |
| Noodle House      | owner6@foodiehub.com      | password123  |
| Taco Bell         | owner7@foodiehub.com      | password123  |
| Baskin Robbins    | owner8@foodiehub.com      | password123  |
| Biryani Blues     | owner9@foodiehub.com      | password123  |
| Dosa Plaza        | owner10@foodiehub.com     | password123  |
| Curry House       | owner11@foodiehub.com     | password123  |

- Update these credentials for production, and use strong passwords
- Running the migration signs out any current Firebase Auth session in the app

## Testing Firebase Integration

1. Run the app: `flutter run`
2. The app will load with sample data from constants.dart (fallback)
3. Navigate to Firebase Setup screen
4. Click "Migrate Sample Data"
5. App will now use Firebase data
6. Changes made in Firebase console will reflect in the app

## Adding New Data

### Via App

Use the Firebase Setup screen to migrate data or manually add items through the UI.

### Via Firebase Console

1. Go to https://console.firebase.google.com/project/foodiehub-e8805/firestore
2. Select the `restaurants` collection and either create or open a restaurant document
3. Inside the restaurant document, click “Add collection” → `menuItems`
4. Add menu item documents following the structure above
5. Save

### Via Code

```dart
// Add a restaurant
final restaurant = Restaurant(
  id: "new-id",
  name: "New Restaurant",
  // ... other fields
);

await Provider.of<RestaurantProvider>(context, listen: false)
    .addRestaurant(restaurant);
```

## Troubleshooting

### "The database (default) does not exist" Error

**This is the most common error!** It means Firestore is not enabled yet.

**Solution**:
1. Go to: https://console.firebase.google.com/project/foodiehub-e8805/firestore
2. Click **"Create Database"** or **"Get Started"**
3. Choose **"Start in test mode"**
4. Select a database location
5. Click **"Enable"**
6. Restart your app

### Data Not Showing

1. Check Firebase console to ensure data exists
2. Verify Firebase initialization in `main.dart`
3. Check network connectivity
4. Look for errors in console logs

### Migration Fails

1. Check internet connection
2. Verify Firebase project permissions
3. Ensure Firestore is enabled in Firebase console
4. Check console logs for specific errors

### App Not Loading Data

1. App falls back to sample data from constants.dart if Firebase is empty
2. Run migration to populate Firebase
3. Check Firebase console for data

## Next Steps

1. **Add Authentication**: Implement user authentication with Firebase Auth
2. **Add Storage**: Upload and store images in Firebase Storage
3. **Add Cart Persistence**: Save user cart in Firestore
4. **Add Orders**: Create an orders collection to track user orders
5. **Add Reviews**: Store user reviews in Firestore
6. **Add Analytics**: Track user behavior with Firebase Analytics

## Security Rules

Update Firestore security rules in Firebase console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function ownerIdForRestaurant(String restaurantId) {
      return get(/databases/$(database)/documents/restaurants/$(restaurantId)).data.ownerId;
    }

    match /restaurants/{restaurantId} {
      allow read: if true;

      allow create: if request.auth != null
        && request.resource.data.ownerId == request.auth.uid;

      allow update: if request.auth != null
        && resource.data.ownerId == request.auth.uid
        && request.resource.data.ownerId == resource.data.ownerId;

      allow delete: if request.auth != null
        && resource.data.ownerId == request.auth.uid;

      match /menuItems/{menuItemId} {
        allow read: if true;

        allow create: if request.auth != null
          && ownerIdForRestaurant(restaurantId) == request.auth.uid
          && request.resource.data.restaurantId == restaurantId;

        allow update: if request.auth != null
          && ownerIdForRestaurant(restaurantId) == request.auth.uid
          && resource.data.restaurantId == restaurantId;

        allow delete: if request.auth != null
          && ownerIdForRestaurant(restaurantId) == request.auth.uid;
      }
    }
  }
}
```

## Support

For Firebase-specific issues, refer to:
- Firebase Documentation: https://firebase.google.com/docs
- FlutterFire: https://firebase.flutter.dev/
- Firestore Docs: https://firebase.google.com/docs/firestore

## Files Reference

### Services
- `lib/services/restaurant_service.dart` - Restaurant CRUD operations
- `lib/services/menu_item_service.dart` - Menu Item CRUD operations

### Providers
- `lib/providers/restaurant_provider.dart` - Restaurant state management
- `lib/providers/menu_item_provider.dart` - Menu Item state management

### Migration
- `lib/utils/firebase_migration.dart` - Data migration script
- `lib/screens/firebase_setup_screen.dart` - UI for managing Firebase data

### Configuration
- `lib/firebase_options.dart` - Firebase configuration (auto-generated)
- `lib/main.dart` - Firebase initialization

