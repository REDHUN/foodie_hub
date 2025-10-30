class Restaurant {
  final String id;
  final String name;
  final String image;
  final String cuisine;
  final double rating;
  final String deliveryTime;
  final double deliveryFee;
  final String? discount;

  Restaurant({
    required this.id,
    required this.name,
    required this.image,
    required this.cuisine,
    required this.rating,
    required this.deliveryTime,
    required this.deliveryFee,
    this.discount,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      cuisine: json['cuisine'] as String,
      rating: (json['rating'] as num).toDouble(),
      deliveryTime: json['deliveryTime'] as String,
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      discount: json['discount'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'cuisine': cuisine,
      'rating': rating,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'discount': discount,
    };
  }
}
