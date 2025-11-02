# Generate FoodieHub App Icon

## Quick Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Create Your App Icon Image

**Option A: Use AI Image Generator (Recommended)**
Use ChatGPT, DALL-E, or Midjourney with this prompt:
```
Create a modern food delivery app icon, 1024x1024 pixels, circular design with red background color #ff6b6b, white fork and spoon crossed in center, small pizza slice and burger at bottom, "FoodieHub" text, clean minimalist style, app store quality
```

**Option B: Use Canva (Free)**
1. Go to canva.com
2. Search "app icon" templates
3. Use these colors:
   - Background: #ff6b6b (red)
   - Accent: #4ecdc4 (teal)
   - Text: white
4. Add fork/spoon icons and food elements
5. Download as PNG, 1024x1024

**Option C: Use the Flutter Preview**
1. Add this to your main.dart temporarily:
```dart
import 'package:foodiehub/utils/app_icon_generator.dart';

// In your app, add a route to:
AppIconPreviewScreen()
```
2. Take a screenshot and use it as reference

### 3. Replace the Placeholder
- Save your icon as: `assets/images/app_icon_1024.png`
- Make sure it's exactly 1024x1024 pixels
- PNG format with transparent or solid background

### 4. Generate Icons for All Platforms
```bash
flutter pub run flutter_launcher_icons
```

### 5. Test Your Icon
```bash
flutter clean
flutter pub get
flutter run
```

## Troubleshooting

**If icons don't update:**
```bash
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons
flutter run
```

**For Android specifically:**
```bash
cd android
./gradlew clean
cd ..
flutter run
```

**For iOS specifically:**
```bash
cd ios
rm -rf build/
cd ..
flutter run
```

## Icon Requirements by Platform

### Android
- Adaptive icon support
- Multiple densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- Foreground and background layers

### iOS  
- Multiple sizes (20pt to 1024pt)
- No transparency
- Rounded corners applied automatically

### Web
- Favicon support
- PWA manifest icons
- Multiple sizes

## Design Tips

1. **Keep it simple** - Icons look best with minimal elements
2. **High contrast** - Ensure visibility on different backgrounds  
3. **Scalable design** - Must look good from 16px to 1024px
4. **Brand consistent** - Use your app's color scheme
5. **Test on device** - Always check on actual devices

## Current Configuration

Your `pubspec.yaml` is already configured with:
- flutter_launcher_icons package
- Icon path: `assets/images/app_icon_1024.png`
- All platforms enabled (Android, iOS, Web, Windows, macOS)

Just create the PNG file and run the generator!