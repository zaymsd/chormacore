import 'product_model.dart';

/// Cart item data model
class CartModel {
  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Product info (populated from join)
  final ProductModel? product;

  const CartModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    this.updatedAt,
    this.product,
  });

  /// Calculate subtotal
  double get subtotal => (product?.price ?? 0) * quantity;

  /// Check if requested quantity is available
  bool get isQuantityAvailable => product != null && quantity <= product!.stock;

  /// Create from database map
  factory CartModel.fromMap(Map<String, dynamic> map, {ProductModel? product}) {
    return CartModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      productId: map['product_id'] as String,
      quantity: map['quantity'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      product: product,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copy with new values
  CartModel copyWith({
    String? id,
    String? userId,
    String? productId,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProductModel? product,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      product: product ?? this.product,
    );
  }

  @override
  String toString() {
    return 'CartModel(id: $id, productId: $productId, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
