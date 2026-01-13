import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/db_constants.dart';
import 'migrations/migration_v1.dart';
import 'migrations/migration_v2.dart';

/// Database helper singleton for SQLite operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(DbConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: DbConstants.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await MigrationV1.createTables(db);
    await MigrationV1.seedData(db);
    // Apply V2 migration for new installations
    if (version >= 2) {
      await MigrationV2.migrate(db);
    }
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle migrations for future versions
    if (oldVersion < 2) {
      await MigrationV2.migrate(db);
    }
  }

  // ========== Generic CRUD Operations ==========

  /// Insert a record into a table
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all records from a table
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  /// Get a single record by ID
  Future<Map<String, dynamic>?> getById(String table, String id) async {
    final db = await database;
    final result = await db.query(
      table,
      where: '${DbConstants.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Get records with conditions
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Update a record
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Delete a record
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Execute raw SQL query
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Execute raw SQL command
  Future<void> rawExecute(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    await db.execute(sql, arguments);
  }

  /// Count records in a table
  Future<int> count(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table ${where != null ? 'WHERE $where' : ''}',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete all data (for testing/reset)
  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete(DbConstants.tableNotifications);
    await db.delete(DbConstants.tableReviews);
    await db.delete(DbConstants.tableWishlist);
    await db.delete(DbConstants.tableOrderItems);
    await db.delete(DbConstants.tableOrders);
    await db.delete(DbConstants.tableCart);
    await db.delete(DbConstants.tableProducts);
    await db.delete(DbConstants.tableCategories);
    await db.delete(DbConstants.tableUsers);
  }
}
