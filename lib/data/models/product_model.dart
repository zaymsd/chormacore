import 'dart:convert';

/// Product data model
class ProductModel {
  final String id;
  final String sellerId;
  final String categoryId;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final List<String> images;
  final double rating;
  final int ratingCount;
  final int soldCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Seller info (populated from join)
  final String? sellerName;
  // Category info (populated from join)
  final String? categoryName;

  const ProductModel({
    required this.id,
    required this.sellerId,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.images = const [],
    this.rating = 0,
    this.ratingCount = 0,
    this.soldCount = 0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.sellerName,
    this.categoryName,
  });

  /// Check if product is in stock
  bool get isInStock => stock > 0;

  /// Check if product is out of stock
  bool get isOutOfStock => stock <= 0;

  /// Get first image or null
  String? get firstImage => images.isNotEmpty ? images.first : null;

  /// Create from database map
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    List<String> parseImages(dynamic imagesData) {
      if (imagesData == null) return [];
      if (imagesData is String) {
        try {
          final decoded = json.decode(imagesData);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (e) {
          return imagesData.isNotEmpty ? [imagesData] : [];
        }
      }
      if (imagesData is List) {
        return imagesData.map((e) => e.toString()).toList();
      }
      return [];
    }

    return ProductModel(
      id: map['id'] as String,
      sellerId: map['seller_id'] as String,
      categoryId: map['category_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      images: parseImages(map['images']),
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: map['rating_count'] as int? ?? 0,
      soldCount: map['sold_count'] as int? ?? 0,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      sellerName: map['seller_name'] as String?,
      categoryName: map['category_name'] as String?,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seller_id': sellerId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'images': json.encode(images),
      'rating': rating,
      'rating_count': ratingCount,
      'sold_count': soldCount,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copy with new values
  ProductModel copyWith({
    String? id,
    String? sellerId,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    int? stock,
    List<String>? images,
    double? rating,
    int? ratingCount,
    int? soldCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sellerName,
    String? categoryName,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      soldCount: soldCount ?? this.soldCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sellerName: sellerName ?? this.sellerName,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, stock: $stock)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
