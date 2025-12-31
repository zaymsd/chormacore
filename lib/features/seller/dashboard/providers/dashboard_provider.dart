import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/repositories/product_repository.dart';

/// Provider for seller dashboard statistics
class DashboardProvider extends ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();
  final ProductRepository _productRepository = ProductRepository();

  bool _isLoading = false;
  String? _error;
  String? _sellerId;

  // Dashboard stats
  int _totalProducts = 0;
  int _totalOrders = 0;
  int _pendingOrders = 0;
  int _completedOrders = 0;
  double _totalRevenue = 0;
  List<OrderModel> _recentOrders = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalProducts => _totalProducts;
  int get totalOrders => _totalOrders;
  int get pendingOrders => _pendingOrders;
  int get completedOrders => _completedOrders;
  double get totalRevenue => _totalRevenue;
  List<OrderModel> get recentOrders => _recentOrders;

  /// Set seller ID and load dashboard
  Future<void> setSeller(String sellerId) async {
    if (_sellerId == sellerId) return;
    _sellerId = sellerId;
    await loadDashboard();
  }

  /// Load dashboard data
  Future<void> loadDashboard() async {
    if (_sellerId == null) return;

    _setLoading(true);
    _clearError();

    try {
      // Load all stats concurrently
      final results = await Future.wait([
        _productRepository.countProductsBySeller(_sellerId!),
        _orderRepository.getOrderCountBySeller(_sellerId!),
        _orderRepository.getOrderCountByStatus(_sellerId!, AppConstants.orderStatusPending),
        _orderRepository.getOrderCountByStatus(_sellerId!, AppConstants.orderStatusDelivered),
        _orderRepository.getTotalRevenue(_sellerId!),
        _orderRepository.getRecentOrders(_sellerId!, limit: 5),
      ]);

      _totalProducts = results[0] as int;
      _totalOrders = results[1] as int;
      _pendingOrders = results[2] as int;
      _completedOrders = results[3] as int;
      _totalRevenue = results[4] as double;
      _recentOrders = results[5] as List<OrderModel>;
    } catch (e) {
      _setError('Gagal memuat dashboard: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh dashboard
  Future<void> refresh() async {
    await loadDashboard();
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
