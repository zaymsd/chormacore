import '../../../core/constants/db_constants.dart';

/// Wishlist table definition
class WishlistTable {
  static const String tableName = DbConstants.tableWishlist;

  // Column names
  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnProductId = 'product_id';
  static const String columnCreatedAt = 'created_at';

  /// SQL query to create wishlist table
  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnUserId TEXT NOT NULL,
      $columnProductId TEXT NOT NULL,
      $columnCreatedAt TEXT NOT NULL,
      FOREIGN KEY ($columnUserId) REFERENCES ${DbConstants.tableUsers} (id),
      FOREIGN KEY ($columnProductId) REFERENCES ${DbConstants.tableProducts} (id),
      UNIQUE ($columnUserId, $columnProductId)
    )
  ''';

  /// SQL query to create user index
  static const String createUserIndexQuery = '''
    CREATE INDEX idx_wishlist_user ON $tableName ($columnUserId)
  ''';
}
