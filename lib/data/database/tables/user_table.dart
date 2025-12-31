import '../../../core/constants/db_constants.dart';

/// User table definition
class UserTable {
  static const String tableName = DbConstants.tableUsers;

  // Column names
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnEmail = 'email';
  static const String columnPassword = 'password';
  static const String columnPhone = 'phone';
  static const String columnAddress = 'address';
  static const String columnRole = 'role'; // 'buyer' or 'seller'
  static const String columnAvatar = 'avatar';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  /// SQL query to create users table
  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnEmail TEXT NOT NULL UNIQUE,
      $columnPassword TEXT NOT NULL,
      $columnPhone TEXT,
      $columnAddress TEXT,
      $columnRole TEXT NOT NULL DEFAULT 'buyer',
      $columnAvatar TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT
    )
  ''';

  /// SQL query to create index on email
  static const String createEmailIndexQuery = '''
    CREATE UNIQUE INDEX idx_users_email ON $tableName ($columnEmail)
  ''';
}
