import 'dart:convert';

/// Review data model
class ReviewModel {
  final String id;
  final String userId;
  final String productId;
  final String? orderId;
  final int rating;
  final String? comment;
  final List<String> images;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // User info (populated from join)
  final String? userName;
  final String? userAvatar;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.productId,
    this.orderId,
    required this.rating,
    this.comment,
    this.images = const [],
    required this.createdAt,
    this.updatedAt,
    this.userName,
    this.userAvatar,
  });

  /// Create from database map
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    List<String> parseImages(dynamic imagesData) {
      if (imagesData == null) return [];
      if (imagesData is String) {
        try {
          final decoded = json.decode(imagesData);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (e) {
          return [];
        }
      }
      if (imagesData is List) {
        return imagesData.map((e) => e.toString()).toList();
      }
      return [];
    }

    return ReviewModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      productId: map['product_id'] as String,
      orderId: map['order_id'] as String?,
      rating: map['rating'] as int,
      comment: map['comment'] as String?,
      images: parseImages(map['images']),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      userName: map['user_name'] as String?,
      userAvatar: map['user_avatar'] as String?,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'order_id': orderId,
      'rating': rating,
      'comment': comment,
      'images': json.encode(images),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copy with new values
  ReviewModel copyWith({
    String? id,
    String? userId,
    String? productId,
    String? orderId,
    int? rating,
    String? comment,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userAvatar,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      orderId: orderId ?? this.orderId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
    );
  }

  @override
  String toString() {
    return 'ReviewModel(id: $id, rating: $rating, productId: $productId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
