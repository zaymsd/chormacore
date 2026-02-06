import 'package:sqflite/sqflite.dart';

/// Chats table schema
class ChatTable {
  ChatTable._();

  static const String tableName = 'chats';

  // Column names
  static const String columnId = 'id';
  static const String columnBuyerId = 'buyer_id';
  static const String columnSellerId = 'seller_id';
  static const String columnLastMessage = 'last_message';
  static const String columnLastMessageTime = 'last_message_time';
  static const String columnCreatedAt = 'created_at';

  /// Create table SQL
  static const String createTableSQL = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnBuyerId TEXT NOT NULL,
      $columnSellerId TEXT NOT NULL,
      $columnLastMessage TEXT,
      $columnLastMessageTime TEXT,
      $columnCreatedAt TEXT NOT NULL,
      FOREIGN KEY ($columnBuyerId) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY ($columnSellerId) REFERENCES users(id) ON DELETE CASCADE
    )
  ''';

  /// Create indexes for faster queries
  static const String createBuyerIndexSQL = '''
    CREATE INDEX idx_chats_buyer_id ON $tableName($columnBuyerId)
  ''';

  static const String createSellerIndexSQL = '''
    CREATE INDEX idx_chats_seller_id ON $tableName($columnSellerId)
  ''';

  /// Create unique index to prevent duplicate chats
  static const String createUniqueIndexSQL = '''
    CREATE UNIQUE INDEX idx_chats_buyer_seller ON $tableName($columnBuyerId, $columnSellerId)
  ''';

  /// Create table
  static Future<void> createTable(Database db) async {
    await db.execute(createTableSQL);
    await db.execute(createBuyerIndexSQL);
    await db.execute(createSellerIndexSQL);
    await db.execute(createUniqueIndexSQL);
  }
}
