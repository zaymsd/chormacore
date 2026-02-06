gitimport 'package:sqflite/sqflite.dart';
import '../tables/chat_table.dart';
import '../tables/chat_message_table.dart';

/// Migration V3 - Add chat tables
class MigrationV3 {
  MigrationV3._();

  /// Run migration
  static Future<void> migrate(Database db) async {
    // Create chat tables
    await ChatTable.createTable(db);
    await ChatMessageTable.createTable(db);
  }
}
