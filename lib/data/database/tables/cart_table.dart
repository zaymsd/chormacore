import '../../../core/constants/db_constants.dart';

/// Cart table definition
class CartTable {
  static const String tableName = DbConstants.tableCart;

  // Column names
  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnProductId = 'product_id';
  static const String columnQuantity = 'quantity';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  /// SQL query to create cart table
  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnUserId TEXT NOT NULL,
      $columnProductId TEXT NOT NULL,
      $columnQuantity INTEGER NOT NULL DEFAULT 1,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT,
      FOREIGN KEY ($columnUserId) REFERENCES ${DbConstants.tableUsers} (id),
      FOREIGN KEY ($columnProductId) REFERENCES ${DbConstants.tableProducts} (id),
      UNIQUE ($columnUserId, $columnProductId)
    )
  ''';

  /// SQL query to create user index
  static const String createUserIndexQuery = '''
    CREATE INDEX idx_cart_user ON $tableName ($columnUserId)
  ''';
}
