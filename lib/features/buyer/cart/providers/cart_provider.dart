import 'package:flutter/foundation.dart';
import '../../../../data/models/cart_model.dart';
import '../../../../data/repositories/cart_repository.dart';

/// Provider for cart operations
class CartProvider extends ChangeNotifier {
  final CartRepository _cartRepository = CartRepository();

  List<CartModel> _items = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;

  // Getters
  List<CartModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;

  /// Get total cart value
  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);

  /// Get total quantity
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Set user ID and load cart
  Future<void> setUser(String userId) async {
    if (_userId == userId) return;
    _userId = userId;
    await loadCart();
  }

  /// Load cart items
  Future<void> loadCart() async {
    if (_userId == null) return;

    _setLoading(true);
    _clearError();

    try {
      _items = await _cartRepository.getCartByUser(_userId!);
    } catch (e) {
      _setError('Gagal memuat keranjang: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Add item to cart
  Future<bool> addToCart(String productId, {int quantity = 1}) async {
    if (_userId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      await _cartRepository.addToCart(
        userId: _userId!,
        productId: productId,
        quantity: quantity,
      );
      await loadCart();
      return true;
    } catch (e) {
      _setError('Gagal menambahkan ke keranjang: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update item quantity
  Future<bool> updateQuantity(String cartId, int quantity) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _cartRepository.updateQuantity(cartId, quantity);
      if (success) {
        await loadCart();
      }
      return success;
    } catch (e) {
      _setError('Gagal mengubah jumlah: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Remove item from cart
  Future<bool> removeItem(String cartId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _cartRepository.removeFromCart(cartId);
      if (success) {
        _items.removeWhere((item) => item.id == cartId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Gagal menghapus item: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear cart
  Future<bool> clearCart() async {
    if (_userId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success = await _cartRepository.clearCart(_userId!);
      if (success) {
        _items = [];
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Gagal mengosongkan keranjang: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if product is in cart
  Future<bool> isInCart(String productId) async {
    if (_userId == null) return false;
    return await _cartRepository.isInCart(_userId!, productId);
  }

  /// Get cart count for badge
  Future<int> getCartCount() async {
    if (_userId == null) return 0;
    return await _cartRepository.getCartCount(_userId!);
  }

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
