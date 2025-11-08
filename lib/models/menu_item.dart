class MenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final int quantity; // Available stock quantity

  MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    this.quantity = 999, // Default to 999 (unlimited)
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      category: json['category'] as String,
      quantity:
          json['quantity'] as int? ?? 999, // Default to 999 if not present
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'quantity': quantity,
    };
  }

  // Helper to check if item is in stock
  bool get isInStock => quantity > 0;

  // Helper to check if item is low stock (less than 10)
  bool get isLowStock => quantity > 0 && quantity < 10;
}
