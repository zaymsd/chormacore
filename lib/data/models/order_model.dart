import '../../core/constants/app_constants.dart';

/// Order item model for order details
class OrderItemModel {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;
  final double subtotal;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] as String,
      orderId: map['order_id'] as String,
      productId: map['product_id'] as String,
      productName: map['product_name'] as String,
      productImage: map['product_image'] as String?,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }
}

/// Order data model
class OrderModel {
  final String id;
  final String userId;
  final String sellerId;
  final double total;
  final String status;
  final String address;
  final String paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Related data
  final List<OrderItemModel> items;
  final String? buyerName;
  final String? sellerName;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.sellerId,
    required this.total,
    required this.status,
    required this.address,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.items = const [],
    this.buyerName,
    this.sellerName,
  });

  /// Check order status
  bool get isPending => status == AppConstants.orderStatusPending;
  bool get isProcessing => status == AppConstants.orderStatusProcessing;
  bool get isShipped => status == AppConstants.orderStatusShipped;
  bool get isDelivered => status == AppConstants.orderStatusDelivered;
  bool get isCancelled => status == AppConstants.orderStatusCancelled;

  /// Get status display text
  String get statusText {
    switch (status) {
      case AppConstants.orderStatusPending:
        return 'Menunggu Konfirmasi';
      case AppConstants.orderStatusProcessing:
        return 'Diproses';
      case AppConstants.orderStatusShipped:
        return 'Dikirim';
      case AppConstants.orderStatusDelivered:
        return 'Selesai';
      case AppConstants.orderStatusCancelled:
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  /// Get payment method display text
  String get paymentMethodText {
    switch (paymentMethod) {
      case AppConstants.paymentCOD:
        return 'Bayar di Tempat (COD)';
      case AppConstants.paymentTransfer:
        return 'Transfer Bank';
      case AppConstants.paymentEwallet:
        return 'E-Wallet';
      default:
        return paymentMethod;
    }
  }

  /// Create from database map
  factory OrderModel.fromMap(Map<String, dynamic> map, {List<OrderItemModel>? items}) {
    return OrderModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      sellerId: map['seller_id'] as String,
      total: (map['total'] as num).toDouble(),
      status: map['status'] as String,
      address: map['address'] as String,
      paymentMethod: map['payment_method'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      items: items ?? [],
      buyerName: map['buyer_name'] as String?,
      sellerName: map['seller_name'] as String?,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'seller_id': sellerId,
      'total': total,
      'status': status,
      'address': address,
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copy with new values
  OrderModel copyWith({
    String? id,
    String? userId,
    String? sellerId,
    double? total,
    String? status,
    String? address,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItemModel>? items,
    String? buyerName,
    String? sellerName,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sellerId: sellerId ?? this.sellerId,
      total: total ?? this.total,
      status: status ?? this.status,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      buyerName: buyerName ?? this.buyerName,
      sellerName: sellerName ?? this.sellerName,
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, status: $status, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
