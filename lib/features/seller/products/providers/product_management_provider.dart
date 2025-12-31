import 'package:flutter/foundation.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/product_repository.dart';

/// Provider for seller product management
class ProductManagementProvider extends ChangeNotifier {
  final ProductRepository _productRepository = ProductRepository();

  List<ProductModel> _products = [];
  ProductModel? _selectedProduct;
  bool _isLoading = false;
  String? _error;
  String? _sellerId;

  // Getters
  List<ProductModel> get products => _products;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProducts => _products.isNotEmpty;
  int get productCount => _products.length;

  /// Set seller and load products
  Future<void> setSeller(String sellerId) async {
    if (_sellerId == sellerId) return;
    _sellerId = sellerId;
    await loadProducts();
  }

  /// Load all products for seller
  Future<void> loadProducts() async {
    if (_sellerId == null) return;

    _setLoading(true);
    _clearError();

    try {
      _products = await _productRepository.getProductsBySeller(_sellerId!);
    } catch (e) {
      _setError('Gagal memuat produk: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Get product by ID
  Future<void> getProductDetail(String productId) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedProduct = await _productRepository.getProductById(productId);
    } catch (e) {
      _setError('Gagal memuat detail produk: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Create new product
  Future<ProductModel?> createProduct({
    required String name,
    required String categoryId,
    required double price,
    required int stock,
    String? description,
    List<String>? images,
  }) async {
    if (_sellerId == null) return null;

    _setLoading(true);
    _clearError();

    try {
      final product = await _productRepository.createProduct(
        sellerId: _sellerId!,
        categoryId: categoryId,
        name: name,
        price: price,
        stock: stock,
        description: description,
        images: images,
      );
      
      await loadProducts();
      return product;
    } catch (e) {
      _setError('Gagal membuat produk: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Update product
  Future<bool> updateProduct(ProductModel product) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _productRepository.updateProduct(product);
      if (success) {
        await loadProducts();
      }
      return success;
    } catch (e) {
      _setError('Gagal memperbarui produk: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update stock
  Future<bool> updateStock(String productId, int newStock) async {
    try {
      final success = await _productRepository.updateStock(productId, newStock);
      if (success) {
        await loadProducts();
      }
      return success;
    } catch (e) {
      _setError('Gagal memperbarui stok: ${e.toString()}');
      return false;
    }
  }

  /// Delete product (soft delete)
  Future<bool> deleteProduct(String productId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _productRepository.softDeleteProduct(productId);
      if (success) {
        _products.removeWhere((p) => p.id == productId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Gagal menghapus produk: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear selected product
  void clearSelectedProduct() {
    _selectedProduct = null;
  }

  /// Refresh products
  Future<void> refresh() async {
    await loadProducts();
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
