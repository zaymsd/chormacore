import 'package:flutter/foundation.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/repositories/product_repository.dart';

/// Provider for product listing on buyer home
class ProductListProvider extends ChangeNotifier {
  final ProductRepository _productRepository = ProductRepository();

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ProductModel> get products => 
      _searchQuery.isNotEmpty || _selectedCategoryId != null 
          ? _filteredProducts 
          : _products;
  List<CategoryModel> get categories => _categories;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProducts => products.isNotEmpty;

  /// Load initial data
  Future<void> loadData() async {
    await Future.wait([
      loadProducts(),
      loadCategories(),
    ]);
  }

  /// Load all products
  Future<void> loadProducts() async {
    _setLoading(true);
    _clearError();

    try {
      _products = await _productRepository.getAllProducts();
      _applyFilters();
    } catch (e) {
      _setError('Gagal memuat produk: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load all categories
  Future<void> loadCategories() async {
    try {
      _categories = await _productRepository.getAllCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  /// Filter by category
  void filterByCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
  }

  /// Search products
  void search(String query) {
    _searchQuery = query.trim();
    _applyFilters();
  }

  /// Clear filters
  void clearFilters() {
    _selectedCategoryId = null;
    _searchQuery = '';
    _filteredProducts = [];
    notifyListeners();
  }

  /// Apply filters to products
  void _applyFilters() async {
    if (_searchQuery.isEmpty && _selectedCategoryId == null) {
      _filteredProducts = [];
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      if (_searchQuery.isNotEmpty) {
        // Search from repository for better performance
        _filteredProducts = await _productRepository.searchProducts(_searchQuery);
        
        // Also filter by category if selected
        if (_selectedCategoryId != null) {
          _filteredProducts = _filteredProducts
              .where((p) => p.categoryId == _selectedCategoryId)
              .toList();
        }
      } else if (_selectedCategoryId != null) {
        _filteredProducts = await _productRepository.getProductsByCategory(_selectedCategoryId!);
      }
    } catch (e) {
      debugPrint('Error applying filters: $e');
      // Fallback to local filtering
      _filteredProducts = _products.where((product) {
        final matchesCategory = _selectedCategoryId == null || 
            product.categoryId == _selectedCategoryId;
        final matchesSearch = _searchQuery.isEmpty ||
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (product.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        return matchesCategory && matchesSearch;
      }).toList();
    } finally {
      _setLoading(false);
    }
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
