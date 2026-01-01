import 'package:uuid/uuid.dart';
import '../../core/constants/db_constants.dart';
import '../database/database_helper.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

/// Repository for product-related database operations
class ProductRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  /// Create a new product
  Future<ProductModel> createProduct({
    required String sellerId,
    required String categoryId,
    required String name,
    required double price,
    required int stock,
    String? description,
    List<String>? images,
  }) async {
    final product = ProductModel(
      id: _uuid.v4(),
      sellerId: sellerId,
      categoryId: categoryId,
      name: name,
      description: description,
      price: price,
      stock: stock,
      images: images ?? [],
      createdAt: DateTime.now(),
    );

    await _db.insert(DbConstants.tableProducts, product.toMap());
    return product;
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(String id) async {
    final results = await _db.rawQuery('''
      SELECT p.*, u.name as seller_name, c.name as category_name
      FROM ${DbConstants.tableProducts} p
      LEFT JOIN ${DbConstants.tableUsers} u ON p.seller_id = u.id
      LEFT JOIN ${DbConstants.tableCategories} c ON p.category_id = c.id
      WHERE p.id = ?
    ''', [id]);

    if (results.isNotEmpty) {
      return ProductModel.fromMap(results.first);
    }
    return null;
  }

  /// Get all active products
  Future<List<ProductModel>> getAllProducts({
    int? limit,
    int? offset,
    String? orderBy,
  }) async {
    final results = await _db.rawQuery('''
      SELECT p.*, u.name as seller_name, c.name as category_name
      FROM ${DbConstants.tableProducts} p
      LEFT JOIN ${DbConstants.tableUsers} u ON p.seller_id = u.id
      LEFT JOIN ${DbConstants.tableCategories} c ON p.category_id = c.id
      WHERE p.is_active = 1
      ORDER BY ${orderBy ?? 'p.created_at DESC'}
      ${limit != null ? 'LIMIT $limit' : ''}
      ${offset != null ? 'OFFSET $offset' : ''}
    ''');

    return results.map((map) => ProductModel.fromMap(map)).toList();
  }

  /// Get products by seller
  Future<List<ProductModel>> getProductsBySeller(String sellerId) async {
    final results = await _db.rawQuery('''
      SELECT p.*, c.name as category_name
      FROM ${DbConstants.tableProducts} p
      LEFT JOIN ${DbConstants.tableCategories} c ON p.category_id = c.id
      WHERE p.seller_id = ? AND p.is_active = 1
      ORDER BY p.created_at DESC
    ''', [sellerId]);

    return results.map((map) => ProductModel.fromMap(map)).toList();
  }

  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    final results = await _db.rawQuery('''
      SELECT p.*, u.name as seller_name, c.name as category_name
      FROM ${DbConstants.tableProducts} p
      LEFT JOIN ${DbConstants.tableUsers} u ON p.seller_id = u.id
      LEFT JOIN ${DbConstants.tableCategories} c ON p.category_id = c.id
      WHERE p.category_id = ? AND p.is_active = 1
      ORDER BY p.created_at DESC
    ''', [categoryId]);

    return results.map((map) => ProductModel.fromMap(map)).toList();
  }

  /// Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    final searchPattern = '%$query%';
    final results = await _db.rawQuery('''
      SELECT p.*, u.name as seller_name, c.name as category_name
      FROM ${DbConstants.tableProducts} p
      LEFT JOIN ${DbConstants.tableUsers} u ON p.seller_id = u.id
      LEFT JOIN ${DbConstants.tableCategories} c ON p.category_id = c.id
      WHERE p.is_active = 1 AND (
        p.name LIKE ? OR 
        p.description LIKE ? OR
        c.name LIKE ?
      )
      ORDER BY p.created_at DESC
    ''', [searchPattern, searchPattern, searchPattern]);

    return results.map((map) => ProductModel.fromMap(map)).toList();
  }

  /// Update product
  Future<bool> updateProduct(ProductModel product) async {
    final updatedProduct = product.copyWith(updatedAt: DateTime.now());
    final result = await _db.update(
      DbConstants.tableProducts,
      updatedProduct.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
    return result > 0;
  }

  /// Update product stock
  Future<bool> updateStock(String productId, int newStock) async {
    final result = await _db.update(
      DbConstants.tableProducts,
      {
        'stock': newStock,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
    return result > 0;
  }

  /// Decrease stock after purchase
  Future<bool> decreaseStock(String productId, int quantity) async {
    final product = await getProductById(productId);
    if (product == null || product.stock < quantity) {
      return false;
    }
    return await updateStock(productId, product.stock - quantity);
  }

  /// Increase stock (for order cancellation)
  Future<bool> increaseStock(String productId, int quantity) async {
    final product = await getProductById(productId);
    if (product == null) {
      return false;
    }
    return await updateStock(productId, product.stock + quantity);
  }

  /// Update product rating
  Future<bool> updateRating(String productId, double newRating, int ratingCount) async {
    final result = await _db.update(
      DbConstants.tableProducts,
      {
        'rating': newRating,
        'rating_count': ratingCount,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
    return result > 0;
  }

  /// Increment sold count
  Future<bool> incrementSoldCount(String productId, int quantity) async {
    await _db.rawExecute('''
      UPDATE ${DbConstants.tableProducts}
      SET sold_count = sold_count + ?,
          updated_at = ?
      WHERE id = ?
    ''', [quantity, DateTime.now().toIso8601String(), productId]);
    return true;
  }

  /// Delete product (soft delete)
  Future<bool> softDeleteProduct(String id) async {
    final result = await _db.update(
      DbConstants.tableProducts,
      {
        'is_active': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }

  /// Delete product (hard delete)
  Future<bool> deleteProduct(String id) async {
    final result = await _db.delete(
      DbConstants.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }

  /// Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    final results = await _db.getAll(DbConstants.tableCategories);
    return results.map((map) => CategoryModel.fromMap(map)).toList();
  }

  /// Get category by ID
  Future<CategoryModel?> getCategoryById(String id) async {
    final result = await _db.getById(DbConstants.tableCategories, id);
    if (result != null) {
      return CategoryModel.fromMap(result);
    }
    return null;
  }

  /// Count products by seller (only active products)
  Future<int> countProductsBySeller(String sellerId) async {
    return await _db.count(
      DbConstants.tableProducts,
      where: 'seller_id = ? AND is_active = 1',
      whereArgs: [sellerId],
    );
  }
}
