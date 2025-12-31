import 'product_model.dart';

/// Wishlist item data model
class WishlistModel {
  final String id;
  final String userId;
  final String productId;
  final DateTime createdAt;

  // Product info (populated from join)
  final ProductModel? product;

  const WishlistModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.createdAt,
    this.product,
  });

  /// Create from database map
  factory WishlistModel.fromMap(Map<String, dynamic> map, {ProductModel? product}) {
    return WishlistModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      productId: map['product_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      product: product,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with new values
  WishlistModel copyWith({
    String? id,
    String? userId,
    String? productId,
    DateTime? createdAt,
    ProductModel? product,
  }) {
    return WishlistModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      createdAt: createdAt ?? this.createdAt,
      product: product ?? this.product,
    );
  }

  @override
  String toString() {
    return 'WishlistModel(id: $id, productId: $productId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WishlistModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
