import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final double originalPrice;
  final String image;
  final String category;
  final double rating;
  final int reviewCount;
  final String description;
  final List<String> sizes;
  final List<String> colors;
  final bool isNew;
  final bool isSale;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice = 0,
    required this.image,
    required this.category,
    required this.rating,
    this.reviewCount = 0,
    this.description = '',
    this.sizes = const ['XS', 'S', 'M', 'L', 'XL'],
    this.colors = const ['White', 'Black', 'Gray'],
    this.isNew = false,
    this.isSale = false,
    this.createdAt,
  });

  double get discount => originalPrice > 0
      ? ((originalPrice - price) / originalPrice * 100).roundToDouble()
      : 0;

  // Build from Firestore document
  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      originalPrice: (map['originalPrice'] ?? 0).toDouble(),
      image: map['image'] ?? '',
      category: map['category'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      description: map['description'] ?? '',
      sizes: List<String>.from(map['sizes'] ?? ['XS', 'S', 'M', 'L', 'XL']),
      colors: List<String>.from(map['colors'] ?? ['White', 'Black', 'Gray']),
      isNew: map['isNew'] ?? false,
      isSale: map['isSale'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'image': image,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'description': description,
      'sizes': sizes,
      'colors': colors,
      'isNew': isNew,
      'isSale': isSale,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? originalPrice,
    String? image,
    String? category,
    double? rating,
    int? reviewCount,
    String? description,
    List<String>? sizes,
    List<String>? colors,
    bool? isNew,
    bool? isSale,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      image: image ?? this.image,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      description: description ?? this.description,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      isNew: isNew ?? this.isNew,
      isSale: isSale ?? this.isSale,
    );
  }
}
