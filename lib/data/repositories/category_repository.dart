import '../../core/constants/db_constants.dart';
import '../database/database_helper.dart';
import '../models/category_model.dart';

/// Repository for category-related database operations
class CategoryRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    final results = await _db.query(
      DbConstants.tableCategories,
      orderBy: 'name ASC',
    );
    return results.map((map) => CategoryModel.fromMap(map)).toList();
  }

  /// Get category by ID
  Future<CategoryModel?> getCategoryById(String id) async {
    final results = await _db.query(
      DbConstants.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return CategoryModel.fromMap(results.first);
  }

  /// Get categories count
  Future<int> getCategoryCount() async {
    return await _db.count(DbConstants.tableCategories);
  }
}
