import 'package:sqflite/sqflite.dart';

/// Notifications table schema
class NotificationTable {
  NotificationTable._();

  static const String tableName = 'notifications';

  // Column names
  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnType = 'type';
  static const String columnTitle = 'title';
  static const String columnMessage = 'message';
  static const String columnRelatedId = 'related_id';
  static const String columnIsRead = 'is_read';
  static const String columnCreatedAt = 'created_at';

  /// Create table SQL
  static const String createTableSQL = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnUserId TEXT NOT NULL,
      $columnType TEXT NOT NULL,
      $columnTitle TEXT NOT NULL,
      $columnMessage TEXT NOT NULL,
      $columnRelatedId TEXT,
      $columnIsRead INTEGER NOT NULL DEFAULT 0,
      $columnCreatedAt TEXT NOT NULL,
      FOREIGN KEY ($columnUserId) REFERENCES users(id) ON DELETE CASCADE
    )
  ''';

  /// Create index for faster queries
  static const String createIndexSQL = '''
    CREATE INDEX idx_notifications_user_id ON $tableName($columnUserId)
  ''';

  /// Create table
  static Future<void> createTable(Database db) async {
    await db.execute(createTableSQL);
    await db.execute(createIndexSQL);
  }
}
