import '../../../core/constants/db_constants.dart';

/// Category table definition
class CategoryTable {
  static const String tableName = DbConstants.tableCategories;

  // Column names
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnIcon = 'icon';
  static const String columnDescription = 'description';

  /// SQL query to create categories table
  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnIcon TEXT,
      $columnDescription TEXT
    )
  ''';
}
