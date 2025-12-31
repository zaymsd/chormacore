import 'package:uuid/uuid.dart';
import '../../core/constants/db_constants.dart';
import '../database/database_helper.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

/// Repository for cart-related database operations
class CartRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  /// Add item to cart
  Future<CartModel> addToCart({
    required String userId,
    required String productId,
    int quantity = 1,
  }) async {
    // Check if item already exists in cart
    final existing = await getCartItem(userId, productId);
    
    if (existing != null) {
      // Update quantity
      final updated = existing.copyWith(
        quantity: existing.quantity + quantity,
        updatedAt: DateTime.now(),
      );
      await updateCartItem(updated);
      return updated;
    }

    // Create new cart item
    final cartItem = CartModel(
      id: _uuid.v4(),
      userId: userId,
      productId: productId,
      quantity: quantity,
      createdAt: DateTime.now(),
    );

    await _db.insert(DbConstants.tableCart, cartItem.toMap());
    return cartItem;
  }

  /// Get cart item by user and product
  Future<CartModel?> getCartItem(String userId, String productId) async {
    final results = await _db.query(
      DbConstants.tableCart,
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return CartModel.fromMap(results.first);
    }
    return null;
  }

  /// Get all cart items for user with product details
  Future<List<CartModel>> getCartByUser(String userId) async {
    final results = await _db.rawQuery('''
      SELECT c.*, 
             p.name as product_name,
             p.price as product_price,
             p.images as product_images,
             p.stock as product_stock,
             p.seller_id as product_seller_id
      FROM ${DbConstants.tableCart} c
      JOIN ${DbConstants.tableProducts} p ON c.product_id = p.id
      WHERE c.user_id = ?
      ORDER BY c.created_at DESC
    ''', [userId]);

    return results.map((map) {
      final product = ProductModel(
        id: map['product_id'] as String,
        sellerId: map['product_seller_id'] as String,
        categoryId: '',
        name: map['product_name'] as String,
        price: (map['product_price'] as num).toDouble(),
        stock: map['product_stock'] as int,
        createdAt: DateTime.now(),
      );
      return CartModel.fromMap(map, product: product);
    }).toList();
  }

  /// Update cart item
  Future<bool> updateCartItem(CartModel cartItem) async {
    final result = await _db.update(
      DbConstants.tableCart,
      cartItem.toMap(),
      where: 'id = ?',
      whereArgs: [cartItem.id],
    );
    return result > 0;
  }

  /// Update cart item quantity
  Future<bool> updateQuantity(String cartId, int quantity) async {
    if (quantity <= 0) {
      return await removeFromCart(cartId);
    }
    
    final result = await _db.update(
      DbConstants.tableCart,
      {
        'quantity': quantity,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [cartId],
    );
    return result > 0;
  }

  /// Remove item from cart
  Future<bool> removeFromCart(String cartId) async {
    final result = await _db.delete(
      DbConstants.tableCart,
      where: 'id = ?',
      whereArgs: [cartId],
    );
    return result > 0;
  }

  /// Clear cart for user
  Future<bool> clearCart(String userId) async {
    final result = await _db.delete(
      DbConstants.tableCart,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result >= 0;
  }

  /// Get cart count
  Future<int> getCartCount(String userId) async {
    return await _db.count(
      DbConstants.tableCart,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Get cart total
  Future<double> getCartTotal(String userId) async {
    final results = await _db.rawQuery('''
      SELECT SUM(c.quantity * p.price) as total
      FROM ${DbConstants.tableCart} c
      JOIN ${DbConstants.tableProducts} p ON c.product_id = p.id
      WHERE c.user_id = ?
    ''', [userId]);

    if (results.isNotEmpty && results.first['total'] != null) {
      return (results.first['total'] as num).toDouble();
    }
    return 0;
  }

  /// Check if product is in cart
  Future<bool> isInCart(String userId, String productId) async {
    final count = await _db.count(
      DbConstants.tableCart,
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
    return count > 0;
  }
}
