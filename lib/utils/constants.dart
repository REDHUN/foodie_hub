import 'package:flutter/material.dart';
import 'package:foodiehub/models/menu_item.dart';
import 'package:foodiehub/models/product.dart';
import 'package:foodiehub/models/restaurant.dart';
import 'package:foodiehub/models/review.dart';

// Color constants
class AppColors {
  static const primaryColor = Color(0xFFff6b6b);
  static const secondaryColor = Color(0xFF4ecdc4);
  static const darkColor = Color(0xFF2c3e50);
  static const lightColor = Color(0xFFf8f9fa);
  static const textColor = Color(0xFF333333);
  static const borderColor = Color(0xFFe0e0e0);
  static const successColor = Color(0xFF2ecc71);
  static const warningColor = Color(0xFFf39c12);
  static const dangerColor = Color(0xFFe74c3c);
}

// Category constants
class Categories {
  static const all = 'all';
  static const pizza = 'pizza';
  static const burger = 'burger';
  static const sushi = 'sushi';
  static const dessert = 'dessert';
  static const beverage = 'beverage';
}

// Sort options
enum SortOption { featured, priceLow, priceHigh, rating, newest }

class SampleOwnerAccount {
  final String restaurantId;
  final String email;
  final String password;

  const SampleOwnerAccount({
    required this.restaurantId,
    required this.email,
    required this.password,
  });
}

// Sample products data
final List<Product> sampleProducts = [
  Product(
    id: 1,
    name: "Classic Margherita Pizza",
    category: "pizza",
    price: 12.99,
    description:
        "Fresh mozzarella, tomato sauce, and basil on a crispy thin crust",
    image: "https://picsum.photos/seed/pizza1/300/200.jpg",
    rating: 4.5,
    reviews: 23,
    badge: "Bestseller",
  ),
  Product(
    id: 2,
    name: "BBQ Bacon Burger",
    category: "burger",
    price: 10.99,
    description: "Juicy beef patty with crispy bacon, BBQ sauce, and cheese",
    image: "https://picsum.photos/seed/burger1/300/200.jpg",
    rating: 4.7,
    reviews: 31,
    badge: "Popular",
  ),
  Product(
    id: 3,
    name: "Salmon Sushi Roll",
    category: "sushi",
    price: 14.99,
    description: "Fresh salmon, avocado, and cucumber wrapped in seasoned rice",
    image: "https://picsum.photos/seed/sushi1/300/200.jpg",
    rating: 4.8,
    reviews: 19,
    badge: "Chef's Special",
  ),
  Product(
    id: 4,
    name: "Chocolate Lava Cake",
    category: "dessert",
    price: 7.99,
    description:
        "Warm chocolate cake with a molten center, served with vanilla ice cream",
    image: "https://picsum.photos/seed/dessert1/300/200.jpg",
    rating: 4.9,
    reviews: 42,
    badge: "Must Try",
  ),
  Product(
    id: 5,
    name: "Fresh Fruit Smoothie",
    category: "beverage",
    price: 5.99,
    description: "Blend of seasonal fruits with yogurt and honey",
    image: "https://picsum.photos/seed/beverage1/300/200.jpg",
    rating: 4.3,
    reviews: 15,
  ),
  Product(
    id: 6,
    name: "Pepperoni Pizza",
    category: "pizza",
    price: 13.99,
    description: "Classic pepperoni with mozzarella cheese and tomato sauce",
    image: "https://picsum.photos/seed/pizza2/300/200.jpg",
    rating: 4.6,
    reviews: 28,
  ),
  Product(
    id: 7,
    name: "Veggie Burger",
    category: "burger",
    price: 9.99,
    description: "Plant-based patty with lettuce, tomato, and special sauce",
    image: "https://picsum.photos/seed/burger2/300/200.jpg",
    rating: 4.2,
    reviews: 17,
    badge: "Vegetarian",
  ),
  Product(
    id: 8,
    name: "California Roll",
    category: "sushi",
    price: 11.99,
    description: "Crab, avocado, and cucumber with sesame seeds",
    image: "https://picsum.photos/seed/sushi2/300/200.jpg",
    rating: 4.4,
    reviews: 22,
  ),
  Product(
    id: 9,
    name: "Tiramisu",
    category: "dessert",
    price: 6.99,
    description:
        "Classic Italian dessert with coffee-soaked ladyfingers and mascarpone",
    image: "https://picsum.photos/seed/dessert2/300/200.jpg",
    rating: 4.7,
    reviews: 26,
  ),
  Product(
    id: 10,
    name: "Iced Coffee",
    category: "beverage",
    price: 4.99,
    description: "Cold brew coffee with milk and your choice of sweetener",
    image: "https://picsum.photos/seed/beverage2/300/200.jpg",
    rating: 4.1,
    reviews: 13,
  ),
  Product(
    id: 11,
    name: "Hawaiian Pizza",
    category: "pizza",
    price: 12.49,
    description: "Ham, pineapple, and mozzarella cheese on tomato sauce",
    image: "https://picsum.photos/seed/pizza3/300/200.jpg",
    rating: 4.3,
    reviews: 19,
  ),
  Product(
    id: 12,
    name: "Double Cheeseburger",
    category: "burger",
    price: 11.99,
    description:
        "Two beef patties with double cheese, lettuce, and special sauce",
    image: "https://picsum.photos/seed/burger3/300/200.jpg",
    rating: 4.5,
    reviews: 24,
    badge: "Popular",
  ),
];

// Sample reviews data
final Map<int, List<Review>> sampleReviews = {
  1: [
    Review(
      id: 1,
      name: "Sarah Johnson",
      rating: 5,
      date: "2023-10-15",
      text:
          "Absolutely delicious! The crust was perfectly crispy and the cheese was so fresh. Will definitely order again!",
      helpful: 12,
    ),
    Review(
      id: 2,
      name: "Mike Chen",
      rating: 4,
      date: "2023-10-10",
      text:
          "Great pizza overall. The sauce could be a bit more flavorful, but the quality of ingredients is excellent.",
      helpful: 8,
    ),
    Review(
      id: 3,
      name: "Emily Rodriguez",
      rating: 5,
      date: "2023-10-05",
      text:
          "Best margherita pizza I've had in a long time! The basil was so fresh and the mozzarella was perfectly melted.",
      helpful: 15,
    ),
  ],
  2: [
    Review(
      id: 4,
      name: "David Wilson",
      rating: 5,
      date: "2023-10-18",
      text:
          "This burger is amazing! The bacon is crispy and the BBQ sauce has the perfect balance of sweet and tangy.",
      helpful: 10,
    ),
    Review(
      id: 5,
      name: "Jessica Taylor",
      rating: 4,
      date: "2023-10-12",
      text:
          "Really good burger but a bit messy to eat. The flavor is fantastic though!",
      helpful: 6,
    ),
  ],
};

// Sample restaurants data
final List<Restaurant> sampleRestaurants = [
  Restaurant(
    id: "1",
    name: "Pizza Hut",
    image:
        "https://images.unsplash.com/photo-1727198826083-6693684e4fc1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaXp6YSUyMHJlc3RhdXJhbnQlMjBmb29kfGVufDF8fHx8MTc2MTczNjQ5Mnww&ixlib=rb-4.1.0&q=80&w=1080",
    cuisine: "Pizzas, Italian",
    rating: 4.3,
    deliveryTime: "30-35 mins",
    deliveryFee: 0.6,
    discount: "50% OFF UPTO ₹100",
    ownerId: "owner_1",
  ),
  Restaurant(
    id: "2",
    name: "Burger King",
    image:
        "https://images.unsplash.com/photo-1656439659132-24c68e36b553?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxidXJnZXIlMjBmYXN0JTIwZm9vZHxlbnwxfHx8fDE3NjE3NjE5ODR8MA&ixlib=rb-4.1.0&q=80&w=1080",
    cuisine: "Burgers, American",
    rating: 4.1,
    deliveryTime: "25-30 mins",
    deliveryFee: 0.5,
    discount: "₹125 OFF ABOVE ₹199",
    ownerId: "owner_2",
  ),
  Restaurant(
    id: "3",
    name: "Sushi Station",
    image:
        "https://images.unsplash.com/photo-1700324822763-956100f79b0d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzdXNoaSUyMGphcGFuZXNlJTIwZm9vZHxlbnwxfHx8fDE3NjE3MjE5MDB8MA&ixlib=rb-4.1.0&q=80&w=1080",
    cuisine: "Japanese, Sushi, Asian",
    rating: 4.5,
    deliveryTime: "35-40 mins",
    deliveryFee: 0.8,
    discount: "40% OFF UPTO ₹80",
    ownerId: "owner_3",
  ),
  Restaurant(
    id: "4",
    name: "La Pinoz Pizza",
    image:
        "https://images.unsplash.com/photo-1749169337822-d875fd6f4c9d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwYXN0YSUyMGl0YWxpYW4lMjBmb29kfGVufDF8fHx8MTc2MTY5MTkzMnww&ixlib=rb-4.1.0&q=80&w=1080",
    cuisine: "Pizzas, Pastas, Italian",
    rating: 4.2,
    deliveryTime: "28-33 mins",
    deliveryFee: 0.6,
    discount: "60% OFF UPTO ₹120",
    ownerId: "owner_4",
  ),
  Restaurant(
    id: "5",
    name: "The Bowl Company",
    image:
        "https://images.unsplash.com/photo-1651352650142-385087834d9d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzYWxhZCUyMGhlYWx0aHklMjBmb29kfGVufDF8fHx8MTc2MTY4NDY5MHww&ixlib=rb-4.1.0&q=80&w=1080",
    cuisine: "Healthy Food, Salads, Bowls",
    rating: 4.4,
    deliveryTime: "20-25 mins",
    deliveryFee: 0.5,
    discount: "50% OFF UPTO ₹100",
    ownerId: "owner_5",
  ),
  Restaurant(
    id: "6",
    name: "Noodle House",
    image:
        "https://images.unsplash.com/photo-1637806931098-af30b519be53?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx0aGFpJTIwZm9vZCUyMG5vb2RsZXN8ZW58MXx8fHwxNzYxNjc2NzUzfDA&ixlib=rb-4.1.0&q=80&w=1080",
    cuisine: "Thai, Chinese, Asian",
    rating: 4.3,
    deliveryTime: "30-35 mins",
    deliveryFee: 0.7,
    ownerId: "owner_6",
  ),
  Restaurant(
    id: "7",
    name: "Taco Bell",
    image:
        "https://images.unsplash.com/photo-1615818449536-f26c1e1fe0f0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtZXhpY2FuJTIwdGFjb3MlMjBmb29kfGVufDF8fHx8MTc2MTcyNzk2OHww&ixlib=rb-4.1.0&q=80&w=1080",
    cuisine: "Mexican, Fast Food",
    rating: 4.2,
    deliveryTime: "25-30 mins",
    deliveryFee: 0.5,
    discount: "₹100 OFF ABOVE ₹299",
    ownerId: "owner_7",
  ),
  Restaurant(
    id: "8",
    name: "Baskin Robbins",
    image:
        "https://images.unsplash.com/photo-1655633584060-c875b9821061?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxkZXNzZXJ0JTIwY2FrZSUyMHN3ZWV0fGVufDF8fHx8MTc2MTc1NDIwNXww&ixlib=rb-4.1.0&q=80&w=1080",
    cuisine: "Ice Cream, Desserts",
    rating: 4.6,
    deliveryTime: "15-20 mins",
    deliveryFee: 0.4,
    ownerId: "owner_8",
  ),
  Restaurant(
    id: "9",
    name: "Biryani Blues",
    image:
        "https://images.unsplash.com/photo-1714611626323-5ba6204453be?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxpbmRpYW4lMjBmb29kJTIwYmlyeWFuaXxlbnwxfHx8fDE3NjE3Mjg2NTZ8MA&ixlib=rb-4.1.0&q=80&w=1080",
    cuisine: "Biryani, North Indian, Mughlai",
    rating: 4.4,
    deliveryTime: "30-35 mins",
    deliveryFee: 0.6,
    discount: "50% OFF UPTO ₹100",
    ownerId: "owner_9",
  ),
  Restaurant(
    id: "10",
    name: "Dosa Plaza",
    image:
        "https://images.unsplash.com/photo-1743517894265-c86ab035adef?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxkb3NhJTIwc291dGglMjBpbmRpYW58ZW58MXx8fHwxNzYxNzQ1NDAxfDA&ixlib=rb-4.1.0&q=80&w=1080",
    cuisine: "South Indian, Dosa, Indian",
    rating: 4.3,
    deliveryTime: "25-30 mins",
    deliveryFee: 0.5,
    ownerId: "owner_10",
  ),
  Restaurant(
    id: "11",
    name: "Curry House",
    image:
        "https://images.unsplash.com/photo-1595959524165-0d395008e55b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxub3J0aCUyMGluZGlhbiUyMGN1cnJ5fGVufDF8fHx8MTc2MTc4NTMxOXww&ixlib=rb-4.1.0&q=80&w=1080",
    cuisine: "North Indian, Curry, Tandoor",
    rating: 4.5,
    deliveryTime: "32-37 mins",
    deliveryFee: 0.6,
    discount: "40% OFF UPTO ₹80",
    ownerId: "owner_11",
  ),
];

const List<SampleOwnerAccount> sampleOwnerAccounts = [
  SampleOwnerAccount(
    restaurantId: "1",
    email: "owner1@foodiehub.com",
    password: "password123",
  ),
  SampleOwnerAccount(
    restaurantId: "2",
    email: "owner2@foodiehub.com",
    password: "password123",
  ),
  SampleOwnerAccount(
    restaurantId: "3",
    email: "owner3@foodiehub.com",
    password: "password123",
  ),
  SampleOwnerAccount(
    restaurantId: "4",
    email: "owner4@foodiehub.com",
    password: "password123",
  ),
  SampleOwnerAccount(
    restaurantId: "5",
    email: "owner5@foodiehub.com",
    password: "password123",
  ),
  SampleOwnerAccount(
    restaurantId: "6",
    email: "owner6@foodiehub.com",
    password: "password123",
  ),
  SampleOwnerAccount(
    restaurantId: "7",
    email: "owner7@foodiehub.com",
    password: "password123",
  ),
  SampleOwnerAccount(
    restaurantId: "8",
    email: "owner8@foodiehub.com",
    password: "password123",
  ),
  SampleOwnerAccount(
    restaurantId: "9",
    email: "owner9@foodiehub.com",
    password: "password123",
  ),
  SampleOwnerAccount(
    restaurantId: "10",
    email: "owner10@foodiehub.com",
    password: "password123",
  ),
  SampleOwnerAccount(
    restaurantId: "11",
    email: "owner11@foodiehub.com",
    password: "password123",
  ),
];

// Sample menu items
final List<MenuItem> sampleMenuItems = [
  // Pizza Hut items
  MenuItem(
    id: "m1",
    restaurantId: "1",
    name: "Margherita Pizza",
    description: "Classic tomato, mozzarella, and basil",
    price: 249,
    image:
        "https://images.unsplash.com/photo-1727198826083-6693684e4fc1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaXp6YSUyMHJlc3RhdXJhbnQlMjBmb29kfGVufDF8fHx8MTc2MTczNjQ5Mnww&ixlib=rb-4.1.0&q=80&w=1080",
    category: "Pizza",
  ),
  MenuItem(
    id: "m2",
    restaurantId: "1",
    name: "Pepperoni Pizza",
    description: "Loaded with pepperoni and cheese",
    price: 349,
    image:
        "https://images.unsplash.com/photo-1727198826083-6693684e4fc1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaXp6YSUyMHJlc3RhdXJhbnQlMjBmb29kfGVufDF8fHx8MTc2MTczNjQ5Mnww&ixlib=rb-4.1.0&q=80&w=1080",
    category: "Pizza",
  ),
  MenuItem(
    id: "m3",
    restaurantId: "1",
    name: "Veggie Supreme",
    description: "Mushrooms, peppers, onions, olives",
    price: 299,
    image:
        "https://images.unsplash.com/photo-1727198826083-6693684e4fc1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaXp6YSUyMHJlc3RhdXJhbnQlMjBmb29kfGVufDF8fHx8MTc2MTczNjQ5Mnww&ixlib=rb-4.1.0&q=80&w=1080",
    category: "Pizza",
  ),
  MenuItem(
    id: "m13",
    restaurantId: "1",
    name: "Garlic Bread",
    description: "Crispy bread with garlic butter",
    price: 99,
    image:
        "https://images.unsplash.com/photo-1727198826083-6693684e4fc1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaXp6YSUyMHJlc3RhdXJhbnQlMjBmb29kfGVufDF8fHx8MTc2MTczNjQ5Mnww&ixlib=rb-4.1.0&q=80&w=1080",
    category: "Sides",
  ),
  // Burger King items
  MenuItem(
    id: "m4",
    restaurantId: "2",
    name: "Whopper",
    description: "Flame-grilled beef patty with fresh vegetables",
    price: 189,
    image:
        "https://images.unsplash.com/photo-1656439659132-24c68e36b553?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxidXJnZXIlMjBmYXN0JTIwZm9vZHxlbnwxfHx8fDE3NjE3NjE5ODR8MA&ixlib=rb-4.1.0&q=80&w=1080",
    category: "Burgers",
  ),
  MenuItem(
    id: "m5",
    restaurantId: "2",
    name: "Chicken Royale",
    description: "Crispy chicken with mayo and lettuce",
    price: 169,
    image:
        "https://images.unsplash.com/photo-1656439659132-24c68e36b553?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxidXJnZXIlMjBmYXN0JTIwZm9vZHxlbnwxfHx8fDE3NjE3NjE5ODR8MA&ixlib=rb-4.1.0&q=80&w=1080",
    category: "Burgers",
  ),
  MenuItem(
    id: "m6",
    restaurantId: "2",
    name: "Peri Peri Fries",
    description: "Crispy fries with spicy peri peri seasoning",
    price: 99,
    image:
        "https://images.unsplash.com/photo-1656439659132-24c68e36b553?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxidXJnZXIlMjBmYXN0JTIwZm9vZHxlbnwxfHx8fDE3NjE3NjE5ODR8MA&ixlib=rb-4.1.0&q=80&w=1080",
    category: "Sides",
  ),
  // Sushi Station items
  MenuItem(
    id: "m7",
    restaurantId: "3",
    name: "California Roll",
    description: "Crab, avocado, and cucumber",
    price: 299,
    image:
        "https://images.unsplash.com/photo-1700324822763-956100f79b0d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzdXNoaSUyMGphcGFuZXNlJTIwZm9vZHxlbnwxfHx8fDE3NjE3MjE5MDB8MA&ixlib=rb-4.1.0&q=80&w=1080",
    category: "Sushi Rolls",
  ),
  MenuItem(
    id: "m8",
    restaurantId: "3",
    name: "Salmon Nigiri",
    description: "Fresh salmon over sushi rice (6 pcs)",
    price: 399,
    image:
        "https://images.unsplash.com/photo-1700324822763-956100f79b0d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzdXNoaSUyMGphcGFuZXNlJTIwZm9vZHxlbnwxfHx8fDE3NjE3MjE5MDB8MA&ixlib=rb-4.1.0&q=80&w=1080",
    category: "Nigiri",
  ),
  MenuItem(
    id: "m9",
    restaurantId: "3",
    name: "Dragon Roll",
    description: "Eel, cucumber, avocado topping",
    price: 449,
    image:
        "https://images.unsplash.com/photo-1700324822763-956100f79b0d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzdXNoaSUyMGphcGFuZXNlJTIwZm9vZHxlbnwxfHx8fDE3NjE3MjE5MDB8MA&ixlib=rb-4.1.0&q=80&w=1080",
    category: "Sushi Rolls",
  ),
];
