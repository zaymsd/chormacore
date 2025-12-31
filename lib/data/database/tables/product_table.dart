import '../../../core/constants/db_constants.dart';

/// Product table definition
class ProductTable {
  static const String tableName = DbConstants.tableProducts;

  // Column names
  static const String columnId = 'id';
  static const String columnSellerId = 'seller_id';
  static const String columnCategoryId = 'category_id';
  static const String columnName = 'name';
  static const String columnDescription = 'description';
  static const String columnPrice = 'price';
  static const String columnStock = 'stock';
  static const String columnImages = 'images'; // JSON array of image paths
  static const String columnRating = 'rating';
  static const String columnRatingCount = 'rating_count';
  static const String columnSoldCount = 'sold_count';
  static const String columnIsActive = 'is_active';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  /// SQL query to create products table
  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnSellerId TEXT NOT NULL,
      $columnCategoryId TEXT NOT NULL,
      $columnName TEXT NOT NULL,
      $columnDescription TEXT,
      $columnPrice REAL NOT NULL,
      $columnStock INTEGER NOT NULL DEFAULT 0,
      $columnImages TEXT,
      $columnRating REAL DEFAULT 0,
      $columnRatingCount INTEGER DEFAULT 0,
      $columnSoldCount INTEGER DEFAULT 0,
      $columnIsActive INTEGER DEFAULT 1,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT,
      FOREIGN KEY ($columnSellerId) REFERENCES ${DbConstants.tableUsers} (id),
      FOREIGN KEY ($columnCategoryId) REFERENCES ${DbConstants.tableCategories} (id)
    )
  ''';

  /// SQL query to create indexes
  static const String createSellerIndexQuery = '''
    CREATE INDEX idx_products_seller ON $tableName ($columnSellerId)
  ''';

  static const String createCategoryIndexQuery = '''
    CREATE INDEX idx_products_category ON $tableName ($columnCategoryId)
  ''';
}
