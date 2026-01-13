import 'package:sqflite/sqflite.dart';
import '../tables/notification_table.dart';

/// Database migration for version 2 - Add notifications table
class MigrationV2 {
  /// Run migration
  static Future<void> migrate(Database db) async {
    await NotificationTable.createTable(db);
  }
}
