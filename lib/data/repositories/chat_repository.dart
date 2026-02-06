import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../database/tables/chat_table.dart';
import '../database/tables/chat_message_table.dart';
import '../models/chat_model.dart';
import '../../core/constants/db_constants.dart';

/// Repository for chat operations
class ChatRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final _uuid = const Uuid();

  /// Get or create a chat between buyer and seller
  Future<ChatModel> getOrCreateChat(String buyerId, String sellerId) async {
    // Try to find existing chat
    final results = await _db.query(
      DbConstants.tableChats,
      where: '${ChatTable.columnBuyerId} = ? AND ${ChatTable.columnSellerId} = ?',
      whereArgs: [buyerId, sellerId],
    );

    if (results.isNotEmpty) {
      return _chatFromMapWithUserNames(results.first);
    }

    // Create new chat
    final now = DateTime.now();
    final chat = ChatModel(
      id: _uuid.v4(),
      buyerId: buyerId,
      sellerId: sellerId,
      createdAt: now,
    );

    await _db.insert(DbConstants.tableChats, chat.toMap());
    return chat;
  }

  /// Get all chats for a user (buyer or seller)
  Future<List<ChatModel>> getChatsForUser(String userId) async {
    final results = await _db.rawQuery('''
      SELECT 
        c.*,
        buyer.name as buyer_name,
        seller.name as seller_name,
        (SELECT COUNT(*) FROM ${DbConstants.tableChatMessages} 
         WHERE chat_id = c.id AND receiver_id = ? AND is_read = 0) as unread_count_buyer,
        (SELECT COUNT(*) FROM ${DbConstants.tableChatMessages} 
         WHERE chat_id = c.id AND receiver_id = c.seller_id AND is_read = 0) as unread_count_seller
      FROM ${DbConstants.tableChats} c
      LEFT JOIN ${DbConstants.tableUsers} buyer ON c.buyer_id = buyer.id
      LEFT JOIN ${DbConstants.tableUsers} seller ON c.seller_id = seller.id
      WHERE c.buyer_id = ? OR c.seller_id = ?
      ORDER BY c.last_message_time DESC, c.created_at DESC
    ''', [userId, userId, userId]);

    return results.map((map) => ChatModel.fromMap(map)).toList();
  }

  /// Get a specific chat by ID
  Future<ChatModel?> getChatById(String chatId) async {
    final results = await _db.rawQuery('''
      SELECT 
        c.*,
        buyer.name as buyer_name,
        seller.name as seller_name
      FROM ${DbConstants.tableChats} c
      LEFT JOIN ${DbConstants.tableUsers} buyer ON c.buyer_id = buyer.id
      LEFT JOIN ${DbConstants.tableUsers} seller ON c.seller_id = seller.id
      WHERE c.id = ?
    ''', [chatId]);

    if (results.isEmpty) return null;
    return ChatModel.fromMap(results.first);
  }

  /// Get messages for a chat
  Future<List<ChatMessageModel>> getMessages(String chatId, {int limit = 50, int offset = 0}) async {
    final results = await _db.rawQuery('''
      SELECT 
        m.*,
        u.name as sender_name
      FROM ${DbConstants.tableChatMessages} m
      LEFT JOIN ${DbConstants.tableUsers} u ON m.sender_id = u.id
      WHERE m.chat_id = ?
      ORDER BY m.created_at ASC
      LIMIT ? OFFSET ?
    ''', [chatId, limit, offset]);

    return results.map((map) => ChatMessageModel.fromMap(map)).toList();
  }

  /// Send a new message
  Future<ChatMessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    final now = DateTime.now();
    final messageModel = ChatMessageModel(
      id: _uuid.v4(),
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      isRead: false,
      createdAt: now,
    );

    await _db.insert(DbConstants.tableChatMessages, messageModel.toMap());

    // Update chat's last message
    await _db.update(
      DbConstants.tableChats,
      {
        'last_message': message,
        'last_message_time': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [chatId],
    );

    return messageModel;
  }

  /// Mark messages as read for a user in a chat
  Future<void> markAsRead(String chatId, String userId) async {
    await _db.update(
      DbConstants.tableChatMessages,
      {'is_read': 1},
      where: 'chat_id = ? AND receiver_id = ? AND is_read = 0',
      whereArgs: [chatId, userId],
    );
  }

  /// Get total unread message count for a user
  Future<int> getUnreadCount(String userId) async {
    return await _db.count(
      DbConstants.tableChatMessages,
      where: 'receiver_id = ? AND is_read = 0',
      whereArgs: [userId],
    );
  }

  /// Get chat between buyer and seller (if exists)
  Future<ChatModel?> findChat(String buyerId, String sellerId) async {
    final results = await _db.rawQuery('''
      SELECT 
        c.*,
        buyer.name as buyer_name,
        seller.name as seller_name
      FROM ${DbConstants.tableChats} c
      LEFT JOIN ${DbConstants.tableUsers} buyer ON c.buyer_id = buyer.id
      LEFT JOIN ${DbConstants.tableUsers} seller ON c.seller_id = seller.id
      WHERE c.buyer_id = ? AND c.seller_id = ?
    ''', [buyerId, sellerId]);

    if (results.isEmpty) return null;
    return ChatModel.fromMap(results.first);
  }

  /// Delete a chat and all its messages
  Future<void> deleteChat(String chatId) async {
    await _db.delete(
      DbConstants.tableChatMessages,
      where: 'chat_id = ?',
      whereArgs: [chatId],
    );
    await _db.delete(
      DbConstants.tableChats,
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }

  // Helper to add user names to chat
  Future<ChatModel> _chatFromMapWithUserNames(Map<String, dynamic> map) async {
    final buyerResult = await _db.getById(DbConstants.tableUsers, map['buyer_id']);
    final sellerResult = await _db.getById(DbConstants.tableUsers, map['seller_id']);

    final updatedMap = Map<String, dynamic>.from(map);
    updatedMap['buyer_name'] = buyerResult?['name'];
    updatedMap['seller_name'] = sellerResult?['name'];

    return ChatModel.fromMap(updatedMap);
  }
}
