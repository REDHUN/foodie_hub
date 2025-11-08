import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class Restaurant {
  final String id;
  final String name;
  final String image;
  final String cuisine;
  final double rating;
  final String deliveryTime;
  final double deliveryFee;
  final String? discount;
  final String? ownerId;
  final String? location;
  final GeoPoint? geopoint; // Geolocation coordinates
  final double? distance; // Distance from user in meters

  Restaurant({
    required this.id,
    required this.name,
    required this.image,
    required this.cuisine,
    required this.rating,
    required this.deliveryTime,
    required this.deliveryFee,
    this.discount,
    this.ownerId,
    this.location,
    this.geopoint,
    this.distance,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    GeoPoint? geopoint;
    if (json['position'] != null && json['position']['geopoint'] != null) {
      geopoint = json['position']['geopoint'] as GeoPoint;
    }

    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      cuisine: json['cuisine'] as String,
      rating: (json['rating'] as num).toDouble(),
      deliveryTime: json['deliveryTime'] as String,
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      discount: json['discount'] as String?,
      ownerId: json['ownerId'] as String?,
      location: json['location'] as String?,
      geopoint: geopoint,
      distance: json['distance'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'name': name,
      'image': image,
      'cuisine': cuisine,
      'rating': rating,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'ownerId': ownerId,
      'location': location,
    };

    if (geopoint != null) {
      // Generate geohash using GeoFlutterFire
      final geoFirePoint = GeoFirePoint(geopoint!);
      json['position'] = {
        'geopoint': geopoint,
        'geohash': geoFirePoint.geohash,
      };
    }

    return json;
  }

  Restaurant copyWith({
    String? id,
    String? name,
    String? image,
    String? cuisine,
    double? rating,
    String? deliveryTime,
    double? deliveryFee,
    String? discount,
    String? ownerId,
    String? location,
    GeoPoint? geopoint,
    double? distance,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      cuisine: cuisine ?? this.cuisine,
      rating: rating ?? this.rating,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      ownerId: ownerId ?? this.ownerId,
      location: location ?? this.location,
      geopoint: geopoint ?? this.geopoint,
      distance: distance ?? this.distance,
    );
  }

  /// Get formatted distance string
  String getDistanceString() {
    if (distance == null) return '';
    final km = distance! / 1000;
    if (km < 1) {
      return '${distance!.toStringAsFixed(0)} m away';
    }
    return '${km.toStringAsFixed(2)} km away';
  }
}
