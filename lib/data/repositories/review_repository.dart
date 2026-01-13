import 'package:uuid/uuid.dart';
import '../../core/constants/db_constants.dart';
import '../database/database_helper.dart';
import '../models/review_model.dart';
import '../models/notification_model.dart';
import 'product_repository.dart';
import 'notification_repository.dart';

/// Repository for review-related database operations
class ReviewRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final ProductRepository _productRepository = ProductRepository();
  final NotificationRepository _notificationRepository = NotificationRepository();
  final Uuid _uuid = const Uuid();

  /// Create a new review
  Future<ReviewModel> createReview({
    required String userId,
    required String productId,
    required String orderId,
    required int rating,
    String? comment,
    List<String>? images,
  }) async {
    final review = ReviewModel(
      id: _uuid.v4(),
      userId: userId,
      productId: productId,
      orderId: orderId,
      rating: rating,
      comment: comment,
      images: images ?? [],
      createdAt: DateTime.now(),
    );

    await _db.insert(DbConstants.tableReviews, review.toMap());
    
    // Update product rating after adding review
    await _updateProductRating(productId);
    
    // Get product to find seller and create notification
    final product = await _productRepository.getProductById(productId);
    if (product != null) {
      await _notificationRepository.createNotification(
        userId: product.sellerId,
        type: NotificationType.newReview,
        title: 'Review Baru',
        message: 'Seseorang memberikan review untuk ${product.name}',
        relatedId: productId,
      );
    }

    return review;
  }

  /// Get all reviews for a product
  Future<List<ReviewModel>> getReviewsByProduct(String productId) async {
    final results = await _db.rawQuery('''
      SELECT r.*, u.name as user_name, u.avatar as user_avatar
      FROM ${DbConstants.tableReviews} r
      LEFT JOIN ${DbConstants.tableUsers} u ON r.user_id = u.id
      WHERE r.product_id = ?
      ORDER BY r.created_at DESC
    ''', [productId]);

    return results.map((map) => ReviewModel.fromMap(map)).toList();
  }

  /// Get review by order ID and product ID
  Future<ReviewModel?> getReviewByOrderAndProduct(
    String orderId,
    String productId,
  ) async {
    final results = await _db.rawQuery('''
      SELECT r.*, u.name as user_name, u.avatar as user_avatar
      FROM ${DbConstants.tableReviews} r
      LEFT JOIN ${DbConstants.tableUsers} u ON r.user_id = u.id
      WHERE r.order_id = ? AND r.product_id = ?
      LIMIT 1
    ''', [orderId, productId]);

    if (results.isNotEmpty) {
      return ReviewModel.fromMap(results.first);
    }
    return null;
  }

  /// Check if user has reviewed a product for a specific order
  Future<bool> hasReviewed(String orderId, String productId) async {
    final count = await _db.count(
      DbConstants.tableReviews,
      where: 'order_id = ? AND product_id = ?',
      whereArgs: [orderId, productId],
    );
    return count > 0;
  }

  /// Get reviews by user
  Future<List<ReviewModel>> getReviewsByUser(String userId) async {
    final results = await _db.rawQuery('''
      SELECT r.*, u.name as user_name, u.avatar as user_avatar
      FROM ${DbConstants.tableReviews} r
      LEFT JOIN ${DbConstants.tableUsers} u ON r.user_id = u.id
      WHERE r.user_id = ?
      ORDER BY r.created_at DESC
    ''', [userId]);

    return results.map((map) => ReviewModel.fromMap(map)).toList();
  }

  /// Get average rating for a product
  Future<double> getAverageRating(String productId) async {
    final results = await _db.rawQuery('''
      SELECT AVG(rating) as avg_rating
      FROM ${DbConstants.tableReviews}
      WHERE product_id = ?
    ''', [productId]);

    if (results.isNotEmpty && results.first['avg_rating'] != null) {
      return (results.first['avg_rating'] as num).toDouble();
    }
    return 0.0;
  }

  /// Get review count for a product
  Future<int> getReviewCount(String productId) async {
    return await _db.count(
      DbConstants.tableReviews,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  /// Update product rating after new review
  Future<void> _updateProductRating(String productId) async {
    final avgRating = await getAverageRating(productId);
    final count = await getReviewCount(productId);
    
    await _productRepository.updateRating(productId, avgRating, count);
  }

  /// Update an existing review
  Future<bool> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
    List<String>? images,
  }) async {
    final result = await _db.update(
      DbConstants.tableReviews,
      {
        'rating': rating,
        'comment': comment,
        'images': images?.join(','),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [reviewId],
    );

    if (result > 0) {
      // Get productId to update rating
      final review = await _db.getById(DbConstants.tableReviews, reviewId);
      if (review != null) {
        await _updateProductRating(review['product_id'] as String);
      }
    }

    return result > 0;
  }

  /// Delete a review
  Future<bool> deleteReview(String reviewId) async {
    // Get productId before deletion to update rating
    final review = await _db.getById(DbConstants.tableReviews, reviewId);
    
    final result = await _db.delete(
      DbConstants.tableReviews,
      where: 'id = ?',
      whereArgs: [reviewId],
    );

    if (result > 0 && review != null) {
      await _updateProductRating(review['product_id'] as String);
    }

    return result > 0;
  }
}
