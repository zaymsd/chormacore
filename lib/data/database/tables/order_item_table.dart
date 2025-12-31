import '../../../core/constants/db_constants.dart';

/// Order Item table definition
class OrderItemTable {
  static const String tableName = DbConstants.tableOrderItems;

  // Column names
  static const String columnId = 'id';
  static const String columnOrderId = 'order_id';
  static const String columnProductId = 'product_id';
  static const String columnProductName = 'product_name';
  static const String columnProductImage = 'product_image';
  static const String columnQuantity = 'quantity';
  static const String columnPrice = 'price';
  static const String columnSubtotal = 'subtotal';

  /// SQL query to create order_items table
  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnOrderId TEXT NOT NULL,
      $columnProductId TEXT NOT NULL,
      $columnProductName TEXT NOT NULL,
      $columnProductImage TEXT,
      $columnQuantity INTEGER NOT NULL,
      $columnPrice REAL NOT NULL,
      $columnSubtotal REAL NOT NULL,
      FOREIGN KEY ($columnOrderId) REFERENCES ${DbConstants.tableOrders} (id) ON DELETE CASCADE,
      FOREIGN KEY ($columnProductId) REFERENCES ${DbConstants.tableProducts} (id)
    )
  ''';

  /// SQL query to create order index
  static const String createOrderIndexQuery = '''
    CREATE INDEX idx_order_items_order ON $tableName ($columnOrderId)
  ''';
}
