class Review {
  final int id;
  final String name;
  final int rating;
  final String date;
  final String text;
  final int helpful;

  Review({
    required this.id,
    required this.name,
    required this.rating,
    required this.date,
    required this.text,
    required this.helpful,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      name: json['name'],
      rating: json['rating'],
      date: json['date'],
      text: json['text'],
      helpful: json['helpful'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'date': date,
      'text': text,
      'helpful': helpful,
    };
  }
}
