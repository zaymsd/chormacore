import '../../../core/constants/db_constants.dart';

/// Review table definition
class ReviewTable {
  static const String tableName = DbConstants.tableReviews;

  // Column names
  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnProductId = 'product_id';
  static const String columnOrderId = 'order_id';
  static const String columnRating = 'rating';
  static const String columnComment = 'comment';
  static const String columnImages = 'images'; // JSON array of image paths
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  /// SQL query to create reviews table
  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnUserId TEXT NOT NULL,
      $columnProductId TEXT NOT NULL,
      $columnOrderId TEXT,
      $columnRating INTEGER NOT NULL CHECK ($columnRating >= 1 AND $columnRating <= 5),
      $columnComment TEXT,
      $columnImages TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT,
      FOREIGN KEY ($columnUserId) REFERENCES ${DbConstants.tableUsers} (id),
      FOREIGN KEY ($columnProductId) REFERENCES ${DbConstants.tableProducts} (id),
      FOREIGN KEY ($columnOrderId) REFERENCES ${DbConstants.tableOrders} (id)
    )
  ''';

  /// SQL query to create indexes
  static const String createProductIndexQuery = '''
    CREATE INDEX idx_reviews_product ON $tableName ($columnProductId)
  ''';

  static const String createUserIndexQuery = '''
    CREATE INDEX idx_reviews_user ON $tableName ($columnUserId)
  ''';
}
