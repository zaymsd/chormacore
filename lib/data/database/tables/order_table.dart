import '../../../core/constants/db_constants.dart';

/// Order table definition
class OrderTable {
  static const String tableName = DbConstants.tableOrders;

  // Column names
  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnSellerId = 'seller_id';
  static const String columnTotal = 'total';
  static const String columnStatus = 'status'; // pending, processing, shipped, delivered, cancelled
  static const String columnAddress = 'address';
  static const String columnPaymentMethod = 'payment_method';
  static const String columnNotes = 'notes';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  /// SQL query to create orders table
  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnUserId TEXT NOT NULL,
      $columnSellerId TEXT NOT NULL,
      $columnTotal REAL NOT NULL,
      $columnStatus TEXT NOT NULL DEFAULT 'pending',
      $columnAddress TEXT NOT NULL,
      $columnPaymentMethod TEXT NOT NULL,
      $columnNotes TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT,
      FOREIGN KEY ($columnUserId) REFERENCES ${DbConstants.tableUsers} (id),
      FOREIGN KEY ($columnSellerId) REFERENCES ${DbConstants.tableUsers} (id)
    )
  ''';

  /// SQL query to create indexes
  static const String createUserIndexQuery = '''
    CREATE INDEX idx_orders_user ON $tableName ($columnUserId)
  ''';

  static const String createSellerIndexQuery = '''
    CREATE INDEX idx_orders_seller ON $tableName ($columnSellerId)
  ''';

  static const String createStatusIndexQuery = '''
    CREATE INDEX idx_orders_status ON $tableName ($columnStatus)
  ''';
}
