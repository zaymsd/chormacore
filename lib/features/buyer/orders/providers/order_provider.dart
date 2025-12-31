import 'package:flutter/foundation.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';

/// Provider for buyer order management
class OrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();

  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  String? _userId;

  // Getters
  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasOrders => _orders.isNotEmpty;

  /// Set user and load orders
  Future<void> setUser(String userId) async {
    if (_userId == userId) return;
    _userId = userId;
    await loadOrders();
  }

  /// Load all orders for buyer
  Future<void> loadOrders() async {
    if (_userId == null) return;

    _setLoading(true);
    _clearError();

    try {
      _orders = await _orderRepository.getOrdersByBuyer(_userId!);
    } catch (e) {
      _setError('Gagal memuat pesanan: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Get order by ID
  Future<void> getOrderDetail(String orderId) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedOrder = await _orderRepository.getOrderById(orderId);
    } catch (e) {
      _setError('Gagal memuat detail pesanan: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Cancel order
  Future<bool> cancelOrder(String orderId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _orderRepository.cancelOrder(orderId);
      if (success) {
        await loadOrders();
      }
      return success;
    } catch (e) {
      _setError('Gagal membatalkan pesanan: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh orders
  Future<void> refresh() async {
    await loadOrders();
  }

  /// Clear selected order
  void clearSelectedOrder() {
    _selectedOrder = null;
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
