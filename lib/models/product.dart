class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String image;
  final double rating;
  final int reviews;
  final String? badge;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.image,
    required this.rating,
    required this.reviews,
    this.badge,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'].toDouble(),
      description: json['description'],
      image: json['image'],
      rating: json['rating'].toDouble(),
      reviews: json['reviews'],
      badge: json['badge'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'image': image,
      'rating': rating,
      'reviews': reviews,
      'badge': badge,
    };
  }
}
