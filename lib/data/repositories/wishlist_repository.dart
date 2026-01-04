import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../core/constants/db_constants.dart';
import '../database/database_helper.dart';
import '../models/wishlist_model.dart';
import '../models/product_model.dart';

/// Repository for wishlist-related database operations
class WishlistRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  /// Add product to wishlist
  Future<WishlistModel> addToWishlist({
    required String userId,
    required String productId,
  }) async {
    // Check if already in wishlist
    final existing = await isInWishlist(userId, productId);
    if (existing) {
      final items = await _db.query(
        DbConstants.tableWishlist,
        where: 'user_id = ? AND product_id = ?',
        whereArgs: [userId, productId],
        limit: 1,
      );
      return WishlistModel.fromMap(items.first);
    }

    final wishlistItem = WishlistModel(
      id: _uuid.v4(),
      userId: userId,
      productId: productId,
      createdAt: DateTime.now(),
    );

    await _db.insert(DbConstants.tableWishlist, wishlistItem.toMap());
    return wishlistItem;
  }

  /// Remove from wishlist
  Future<bool> removeFromWishlist(String wishlistId) async {
    final result = await _db.delete(
      DbConstants.tableWishlist,
      where: 'id = ?',
      whereArgs: [wishlistId],
    );
    return result > 0;
  }

  /// Remove by user and product
  Future<bool> removeByUserAndProduct(String userId, String productId) async {
    final result = await _db.delete(
      DbConstants.tableWishlist,
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
    return result > 0;
  }

  /// Parse images from database
  List<String> _parseImages(dynamic imagesData) {
    if (imagesData == null) return [];
    if (imagesData is String) {
      try {
        final decoded = json.decode(imagesData);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        return imagesData.isNotEmpty ? [imagesData] : [];
      }
    }
    if (imagesData is List) {
      return imagesData.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Get wishlist by user with product details
  Future<List<WishlistModel>> getWishlistByUser(String userId) async {
    final results = await _db.rawQuery('''
      SELECT w.*, 
             p.id as product_id,
             p.seller_id,
             p.category_id,
             p.name as product_name,
             p.description as product_description,
             p.price as product_price,
             p.stock as product_stock,
             p.images as product_images,
             p.rating as product_rating,
             p.rating_count as product_rating_count,
             p.is_active as product_is_active,
             p.created_at as product_created_at
      FROM ${DbConstants.tableWishlist} w
      JOIN ${DbConstants.tableProducts} p ON w.product_id = p.id
      WHERE w.user_id = ? AND p.is_active = 1
      ORDER BY w.created_at DESC
    ''', [userId]);

    return results.map((map) {
      final product = ProductModel(
        id: map['product_id'] as String,
        sellerId: map['seller_id'] as String,
        categoryId: map['category_id'] as String,
        name: map['product_name'] as String,
        description: map['product_description'] as String?,
        price: (map['product_price'] as num).toDouble(),
        stock: map['product_stock'] as int,
        images: _parseImages(map['product_images']),
        rating: (map['product_rating'] as num?)?.toDouble() ?? 0,
        ratingCount: map['product_rating_count'] as int? ?? 0,
        isActive: (map['product_is_active'] as int?) == 1,
        createdAt: DateTime.parse(map['product_created_at'] as String),
      );
      return WishlistModel.fromMap(map, product: product);
    }).toList();
  }

  /// Check if product is in wishlist
  Future<bool> isInWishlist(String userId, String productId) async {
    final count = await _db.count(
      DbConstants.tableWishlist,
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
    return count > 0;
  }

  /// Get wishlist count
  Future<int> getWishlistCount(String userId) async {
    return await _db.count(
      DbConstants.tableWishlist,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Clear wishlist
  Future<bool> clearWishlist(String userId) async {
    final result = await _db.delete(
      DbConstants.tableWishlist,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result >= 0;
  }

  /// Toggle wishlist (add if not exists, remove if exists)
  Future<bool> toggleWishlist(String userId, String productId) async {
    final exists = await isInWishlist(userId, productId);
    if (exists) {
      await removeByUserAndProduct(userId, productId);
      return false; // Removed
    } else {
      await addToWishlist(userId: userId, productId: productId);
      return true; // Added
    }
  }
}
