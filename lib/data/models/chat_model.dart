import 'dart:convert';

/// Chat conversation model representing a chat between buyer and seller
class ChatModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final DateTime createdAt;

  // Related data
  final String? buyerName;
  final String? sellerName;
  final int unreadCountBuyer;
  final int unreadCountSeller;

  const ChatModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    this.lastMessage,
    this.lastMessageTime,
    required this.createdAt,
    this.buyerName,
    this.sellerName,
    this.unreadCountBuyer = 0,
    this.unreadCountSeller = 0,
  });

  /// Create from database map
  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] as String,
      buyerId: map['buyer_id'] as String,
      sellerId: map['seller_id'] as String,
      lastMessage: map['last_message'] as String?,
      lastMessageTime: map['last_message_time'] != null
          ? DateTime.parse(map['last_message_time'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      buyerName: map['buyer_name'] as String?,
      sellerName: map['seller_name'] as String?,
      unreadCountBuyer: map['unread_count_buyer'] as int? ?? 0,
      unreadCountSeller: map['unread_count_seller'] as int? ?? 0,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert to JSON string
  String toJson() => json.encode(toMap());

  /// Create from JSON string
  factory ChatModel.fromJson(String source) =>
      ChatModel.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Copy with new values
  ChatModel copyWith({
    String? id,
    String? buyerId,
    String? sellerId,
    String? lastMessage,
    DateTime? lastMessageTime,
    DateTime? createdAt,
    String? buyerName,
    String? sellerName,
    int? unreadCountBuyer,
    int? unreadCountSeller,
  }) {
    return ChatModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      createdAt: createdAt ?? this.createdAt,
      buyerName: buyerName ?? this.buyerName,
      sellerName: sellerName ?? this.sellerName,
      unreadCountBuyer: unreadCountBuyer ?? this.unreadCountBuyer,
      unreadCountSeller: unreadCountSeller ?? this.unreadCountSeller,
    );
  }

  /// Get other participant name based on current user role
  String getOtherParticipantName(String currentUserId) {
    return currentUserId == buyerId ? (sellerName ?? 'Penjual') : (buyerName ?? 'Pembeli');
  }

  /// Get unread count for current user
  int getUnreadCount(String currentUserId) {
    return currentUserId == buyerId ? unreadCountBuyer : unreadCountSeller;
  }

  @override
  String toString() {
    return 'ChatModel(id: $id, buyerId: $buyerId, sellerId: $sellerId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Chat message model for individual messages
class ChatMessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  // Related data
  final String? senderName;

  const ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.isRead = false,
    required this.createdAt,
    this.senderName,
  });

  /// Check if message is from current user
  bool isFromMe(String currentUserId) => senderId == currentUserId;

  /// Create from database map
  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] as String,
      chatId: map['chat_id'] as String,
      senderId: map['sender_id'] as String,
      receiverId: map['receiver_id'] as String,
      message: map['message'] as String,
      isRead: (map['is_read'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      senderName: map['sender_name'] as String?,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert to JSON string
  String toJson() => json.encode(toMap());

  /// Create from JSON string
  factory ChatMessageModel.fromJson(String source) =>
      ChatMessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Copy with new values
  ChatMessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    String? senderName,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName,
    );
  }

  @override
  String toString() {
    return 'ChatMessageModel(id: $id, chatId: $chatId, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
