import 'package:sqflite/sqflite.dart';

/// Chat messages table schema
class ChatMessageTable {
  ChatMessageTable._();

  static const String tableName = 'chat_messages';

  // Column names
  static const String columnId = 'id';
  static const String columnChatId = 'chat_id';
  static const String columnSenderId = 'sender_id';
  static const String columnReceiverId = 'receiver_id';
  static const String columnMessage = 'message';
  static const String columnIsRead = 'is_read';
  static const String columnCreatedAt = 'created_at';

  /// Create table SQL
  static const String createTableSQL = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnChatId TEXT NOT NULL,
      $columnSenderId TEXT NOT NULL,
      $columnReceiverId TEXT NOT NULL,
      $columnMessage TEXT NOT NULL,
      $columnIsRead INTEGER NOT NULL DEFAULT 0,
      $columnCreatedAt TEXT NOT NULL,
      FOREIGN KEY ($columnChatId) REFERENCES chats(id) ON DELETE CASCADE,
      FOREIGN KEY ($columnSenderId) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY ($columnReceiverId) REFERENCES users(id) ON DELETE CASCADE
    )
  ''';

  /// Create indexes for faster queries
  static const String createChatIndexSQL = '''
    CREATE INDEX idx_chat_messages_chat_id ON $tableName($columnChatId)
  ''';

  static const String createSenderIndexSQL = '''
    CREATE INDEX idx_chat_messages_sender_id ON $tableName($columnSenderId)
  ''';

  static const String createReceiverIndexSQL = '''
    CREATE INDEX idx_chat_messages_receiver_id ON $tableName($columnReceiverId)
  ''';

  /// Create table
  static Future<void> createTable(Database db) async {
    await db.execute(createTableSQL);
    await db.execute(createChatIndexSQL);
    await db.execute(createSenderIndexSQL);
    await db.execute(createReceiverIndexSQL);
  }
}
