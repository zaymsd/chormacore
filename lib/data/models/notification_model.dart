/// Notification types for the app
class NotificationType {
  NotificationType._();

  // Buyer notifications
  static const String orderConfirmed = 'order_confirmed';
  static const String orderShipped = 'order_shipped';
  static const String orderDelivered = 'order_delivered';
  static const String orderCancelled = 'order_cancelled';

  // Seller notifications
  static const String newOrder = 'new_order';
  static const String newReview = 'new_review';
}

/// Notification data model
class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String? relatedId; // Order ID or Review ID
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedId,
    this.isRead = false,
    required this.createdAt,
  });

  /// Get icon based on notification type
  String get iconName {
    switch (type) {
      case NotificationType.orderConfirmed:
        return 'check_circle';
      case NotificationType.orderShipped:
        return 'local_shipping';
      case NotificationType.orderDelivered:
        return 'inventory';
      case NotificationType.orderCancelled:
        return 'cancel';
      case NotificationType.newOrder:
        return 'shopping_bag';
      case NotificationType.newReview:
        return 'star';
      default:
        return 'notifications';
    }
  }

  /// Create from database map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      relatedId: map['related_id'] as String?,
      isRead: (map['is_read'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'related_id': relatedId,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with new values
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    String? relatedId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedId: relatedId ?? this.relatedId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: $type, title: $title, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
