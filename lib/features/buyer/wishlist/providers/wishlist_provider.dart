import 'package:flutter/foundation.dart';
import '../../../../data/models/wishlist_model.dart';
import '../../../../data/repositories/wishlist_repository.dart';

/// Provider for wishlist management
class WishlistProvider extends ChangeNotifier {
  final WishlistRepository _wishlistRepository = WishlistRepository();

  List<WishlistModel> _items = [];
  Set<String> _productIds = {};
  bool _isLoading = false;
  String? _error;
  String? _userId;

  // Getters
  List<WishlistModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _items.isEmpty;
  int get count => _items.length;

  /// Check if product is in wishlist
  bool isInWishlist(String productId) => _productIds.contains(productId);

  /// Set user and load wishlist
  Future<void> setUser(String userId) async {
    if (_userId == userId) return;
    _userId = userId;
    await loadWishlist();
  }

  /// Load wishlist
  Future<void> loadWishlist() async {
    if (_userId == null) return;

    _setLoading(true);
    _clearError();

    try {
      _items = await _wishlistRepository.getWishlistByUser(_userId!);
      _productIds = _items.map((item) => item.productId).toSet();
    } catch (e) {
      _setError('Gagal memuat wishlist: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle wishlist
  Future<bool> toggleWishlist(String productId) async {
    if (_userId == null) return false;

    try {
      final added = await _wishlistRepository.toggleWishlist(_userId!, productId);
      
      if (added) {
        _productIds.add(productId);
      } else {
        _productIds.remove(productId);
      }
      
      await loadWishlist();
      return added;
    } catch (e) {
      _setError('Gagal mengubah wishlist: ${e.toString()}');
      return false;
    }
  }

  /// Remove from wishlist
  Future<bool> removeFromWishlist(String wishlistId) async {
    _setLoading(true);

    try {
      final success = await _wishlistRepository.removeFromWishlist(wishlistId);
      if (success) {
        final item = _items.firstWhere((i) => i.id == wishlistId);
        _productIds.remove(item.productId);
        _items.removeWhere((i) => i.id == wishlistId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Gagal menghapus dari wishlist: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear wishlist
  Future<bool> clearWishlist() async {
    if (_userId == null) return false;

    _setLoading(true);

    try {
      final success = await _wishlistRepository.clearWishlist(_userId!);
      if (success) {
        _items = [];
        _productIds = {};
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Gagal mengosongkan wishlist: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh wishlist
  Future<void> refresh() async {
    await loadWishlist();
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
