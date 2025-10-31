# FoodieHub 🍔

A beautiful and modern food delivery Flutter app converted from an HTML prototype.

## Features ✨

### Core Functionality
- **Restaurant Catalog**: Browse through 11 restaurants with diverse cuisines
- **Menu Items**: View detailed menu items for each restaurant
- **Smart Search**: Search restaurants and menu items
- **Category Filtering**: Filter by cuisine type
- **Sort Options**: Sort by rating, delivery time, and more

### Restaurant Features
- **Top-rated Restaurants**: Discover the best restaurants near you
- **Restaurant Details**: View complete information with images
- **Menu Display**: Browse organized menu items by category
- **Star Ratings**: Visual rating system with 5-star display
- **Delivery Info**: See delivery time and fees

### Shopping Cart
- **Add to Cart**: Add menu items with quantity selector
- **Cart Management**: View, update quantities, or remove items
- **Real-time Totals**: See cart count and total price dynamically
- **Cart Screen**: Dedicated cart screen with checkout functionality

### Firebase Integration 🔥
- **Cloud Firestore**: Real-time data storage and synchronization
- **Offline Support**: App works offline and syncs when connected
- **Data Management**: Easy data migration and management
- **Scalable**: Ready for production use

### UI/UX Features
- **Modern Design**: Clean and intuitive Material Design 3 interface
- **Responsive Layout**: Works on all screen sizes
- **Beautiful Images**: Network image caching for smooth performance
- **Smooth Animations**: Fluid transitions and interactions
- **Color Scheme**: Vibrant and appetizing color palette

## Project Structure 📁

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── product.dart                   # Product data model
│   ├── review.dart                    # Review data model
│   └── cart_item.dart                 # Cart item model
├── providers/
│   └── cart_provider.dart             # Cart state management
├── screens/
│   ├── home_screen.dart               # Main product listing screen
│   └── product_detail_screen.dart     # Product details page
├── widgets/
│   ├── product_card.dart              # Product card widget
│   ├── star_rating.dart               # Star rating display
│   ├── cart_item_widget.dart          # Cart item widget
│   └── search_bar.dart                # Search bar widget
└── utils/
    └── constants.dart                 # App constants and sample data
```

## Getting Started 🚀

### Prerequisites
- Flutter SDK (3.32.5 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extension
- Firebase account (free tier works)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd foodiehub
```

2. Install dependencies:
```bash
flutter pub get
```

3. **Firebase Setup** (Required for full functionality):
   - See `FIREBASE_FIRST_STEPS.md` for quick setup
   - See `FIREBASE_SETUP.md` for detailed guide
   - App works with sample data if Firebase is not configured

4. Run the app:
```bash
flutter run
```

### Run on Specific Platform
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

## Dependencies 📦

- **provider**: ^6.1.1 - State management
- **cached_network_image**: ^3.3.1 - Network image caching
- **firebase_core**: ^3.6.0 - Firebase initialization
- **firebase_auth**: ^5.3.1 - User authentication
- **cloud_firestore**: ^5.4.3 - Cloud database
- **firebase_storage**: ^12.3.4 - File storage

## Color Palette 🎨

- **Primary**: #ff6b6b (Coral Red)
- **Secondary**: #4ecdc4 (Turquoise)
- **Dark**: #2c3e50 (Dark Blue-Gray)
- **Light**: #f8f9fa (Light Gray)
- **Success**: #2ecc71 (Green)
- **Warning**: #f39c12 (Orange)
- **Danger**: #e74c3c (Red)

## Features in Detail 📱

### Home Screen
- Hero banner with promotional message
- Search bar at the top
- Category chips for filtering
- Product grid with cards showing:
  - Product images
  - Names and descriptions
  - Star ratings
  - Prices
  - Add to cart buttons
- Sort dropdown menu

### Product Detail Screen
- Full-screen image with badge
- Product information
- Star rating display
- Quantity selector
- Add to Cart / Buy Now buttons
- Reviews section with:
  - Average rating
  - Individual reviews
  - Ability to write reviews
  - Helpful votes

### Cart
- Bottom sheet drawer
- List of cart items
- Increase/decrease quantities
- Remove items
- Total calculation
- Checkout button

## Sample Data 📊

The app includes 12 sample products:
- 3 Pizzas (Margherita, Pepperoni, Hawaiian)
- 3 Burgers (BBQ Bacon, Veggie, Double Cheese)
- 2 Sushi rolls (Salmon, California)
- 2 Desserts (Lava Cake, Tiramisu)
- 2 Beverages (Smoothie, Iced Coffee)

## Architecture 🏗️

- **State Management**: Provider pattern for cart management
- **Models**: Clean data models for products, reviews, and cart items
- **Widgets**: Reusable components for UI consistency
- **Screens**: Organized screen-based navigation

## Firebase Integration 🔥

The app is fully integrated with Firebase for production-ready features:

### Collections
- **restaurants**: Restaurant information with images, ratings, and delivery details
- **menuItems**: Menu items for each restaurant with categories and pricing

### Features
- Real-time data synchronization
- Offline support
- Easy data migration from sample data
- Scalable architecture ready for growth

### Setup Guides
- **Quick Start**: See `FIREBASE_FIRST_STEPS.md`
- **Complete Guide**: See `FIREBASE_SETUP.md`

## Future Enhancements 🔮

- User authentication with Firebase Auth ✅ (Integrated)
- Push notifications
- Favorite/Wishlist functionality
- Order history and tracking
- Address management
- Payment gateway integration
- Multi-language support
- Advanced analytics

## License 📄

This project is open source and available for learning purposes.

## Acknowledgments 🙏

Converted from an HTML/CSS/JavaScript prototype to a fully functional Flutter mobile application with Material Design 3.

---

Made with ❤️ using Flutter
