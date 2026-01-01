import 'package:flutter/foundation.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/repositories/product_repository.dart';

/// Provider for buyer order management
class OrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();
  final ProductRepository _productRepository = ProductRepository();

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

  /// Load orders for buyer (alias)
  Future<void> loadBuyerOrders(String userId) async {
    _userId = userId;
    await loadOrders();
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

  /// Cancel order and restore stock
  Future<bool> cancelOrder(String orderId) async {
    _setLoading(true);
    _clearError();

    try {
      // Get order details first to restore stock
      final order = await _orderRepository.getOrderById(orderId);
      if (order == null) return false;

      // Cancel order
      final success = await _orderRepository.cancelOrder(orderId);
      
      if (success) {
        // Restore stock for each item
        for (var item in order.items) {
          await _productRepository.increaseStock(item.productId, item.quantity);
        }
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
