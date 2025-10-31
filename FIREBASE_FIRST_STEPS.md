# 🚀 Firebase Quick Setup - DO THIS FIRST!

## Current Error

You're seeing this error because Firestore isn't enabled yet:

```
The database (default) does not exist for project foodiehub-e8805
```

## ✅ Quick Fix (5 minutes)

### Step 1: Enable Firestore (REQUIRED)

1. **Open this link**: https://console.firebase.google.com/project/foodiehub-e8805/firestore

2. **Click** "Create Database" or "Get Started"

3. **Select**: "Start in test mode" (for development)

4. **Choose a location**: Pick the closest to you (recommended: `asia-south1` for India, `us-central1` for USA)

5. **Click** "Enable"

6. **Wait** for the database to be created (30-60 seconds)

### Step 2: Enable Firestore in Your Firebase Project

If the link doesn't work or you don't see "Create Database":

1. Go to: https://console.firebase.google.com/project/foodiehub-e8805/overview
2. Click on **"Firestore Database"** in the left sidebar
3. Follow the prompts to create the database

### Step 3: Set Security Rules (IMPORTANT!)

Firestore has default security rules that block access. You need to update them:

1. Go to: https://console.firebase.google.com/project/foodiehub-e8805/firestore/rules
2. Replace the existing rules with these:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 12, 31);
    }
  }
}
```

3. Click **"Publish"**

**Note**: These rules allow full access until 2025. For production, use more restrictive rules. See `FIREBASE_SETUP.md` for production-ready rules.

### Step 4: Run Your App Again

After Firestore is enabled and rules are set:

1. Restart your Flutter app
2. The permission errors should be gone
3. You'll see the app working with sample data from `constants.dart`

### Step 5: Add Sample Data to Firebase (Optional)

Once Firestore is enabled, you can migrate sample data:

1. Add the Firebase Setup screen to your app (see instructions below)
2. Or use the migration script programmatically

## Adding Firebase Setup Screen

To add the Firebase Setup screen to your app for easier data management:

**Option 1: Add to App Bar**

In `lib/main.dart` or your home screen, add a settings button:

```dart
AppBar(
  title: Text('FoodieHub'),
  actions: [
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
    ),
  ],
)
```

**Option 2: Add as Main Screen (for testing)**

Temporarily change your home in `lib/main.dart`:

```dart
// In MaterialApp, change home:
home: FirebaseSetupScreen(), // Temporarily for testing
```

After migrating data, change it back to:

```dart
home: const MainScreen(),
```

## What This Does

✅ Creates a Firestore database in your Firebase project  
✅ Allows the app to connect to Firebase  
✅ Lets you store and retrieve data  
✅ Enables real-time data syncing  

## Troubleshooting

**Q: The link doesn't work**  
A: Make sure you're logged into the correct Google account that has access to the Firebase project

**Q: I don't see "Create Database"**  
A: Go to Firebase Console → Your Project → Firestore Database → Click "Get Started"

**Q: Still seeing errors**  
A: Wait 1-2 minutes after creating the database, then restart your app

**Q: Seeing "PERMISSION_DENIED" error?**  
A: You need to update Firestore security rules (Step 3 above). Go to: https://console.firebase.google.com/project/foodiehub-e8805/firestore/rules

**Q: Want to use different Firebase project?**  
A: Update the configuration in `lib/firebase_options.dart` or run `flutterfire configure`

## Need Help?

- Full guide: See `FIREBASE_SETUP.md`
- Firebase Console: https://console.firebase.google.com/project/foodiehub-e8805
- Firestore documentation: https://firebase.google.com/docs/firestore

---

**Once Firestore is enabled, your app will work! 🎉**

