# FoodieHub 🍔

A beautiful and modern food delivery Flutter app converted from an HTML prototype.

## Features ✨

### Core Functionality
- **Product Catalog**: Browse through 12 delicious food items across 5 categories
- **Smart Search**: Search products by name, description, or category
- **Category Filtering**: Filter by Pizza, Burger, Sushi, Dessert, or Beverage
- **Sort Options**: Sort by Featured, Price (Low to High/High to Low), Rating, or Newest

### Product Features
- **Product Details**: View detailed information with large images
- **Star Ratings**: Visual rating system with 5-star display
- **Product Badges**: Special badges like "Bestseller", "Popular", "Chef's Special"
- **Reviews & Ratings**: Read and write customer reviews

### Shopping Cart
- **Add to Cart**: Add items with quantity selector
- **Cart Management**: View, update quantities, or remove items
- **Real-time Totals**: See cart count and total price dynamically
- **Drawer Cart**: Beautiful bottom sheet cart interface

### UI/UX Features
- **Modern Design**: Clean and intuitive Material Design 3 interface
- **Responsive Layout**: Works on all screen sizes
- **Hero Section**: Eye-catching promotional banner
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

3. Run the app:
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

## Future Enhancements 🔮

- Backend API integration
- User authentication
- Payment gateway
- Order tracking
- Push notifications
- Favorite/Wishlist functionality
- Order history
- Address management
- Multi-language support

## License 📄

This project is open source and available for learning purposes.

## Acknowledgments 🙏

Converted from an HTML/CSS/JavaScript prototype to a fully functional Flutter mobile application with Material Design 3.

---

Made with ❤️ using Flutter
