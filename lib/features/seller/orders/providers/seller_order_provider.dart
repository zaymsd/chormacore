import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';

/// Provider for seller order management
class SellerOrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();

  List<OrderModel> _orders = [];
  List<OrderModel> _filteredOrders = [];
  OrderModel? _selectedOrder;
  String? _statusFilter;
  bool _isLoading = false;
  String? _error;
  String? _sellerId;

  // Getters
  List<OrderModel> get orders => _statusFilter != null ? _filteredOrders : _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  String? get statusFilter => _statusFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasOrders => orders.isNotEmpty;

  /// Get counts by status
  int get pendingCount => _orders.where((o) => o.isPending).length;
  int get processingCount => _orders.where((o) => o.isProcessing).length;
  int get shippedCount => _orders.where((o) => o.isShipped).length;
  int get completedCount => _orders.where((o) => o.isDelivered).length;

  /// Set seller and load orders
  Future<void> setSeller(String sellerId) async {
    if (_sellerId == sellerId) return;
    _sellerId = sellerId;
    await loadOrders();
  }

  /// Load all orders for seller
  Future<void> loadOrders() async {
    if (_sellerId == null) return;

    _setLoading(true);
    _clearError();

    try {
      _orders = await _orderRepository.getOrdersBySeller(_sellerId!);
      _applyFilter();
    } catch (e) {
      _setError('Gagal memuat pesanan: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Filter by status
  void filterByStatus(String? status) {
    _statusFilter = status;
    _applyFilter();
  }

  void _applyFilter() {
    if (_statusFilter == null) {
      _filteredOrders = [];
    } else {
      _filteredOrders = _orders.where((o) => o.status == _statusFilter).toList();
    }
    notifyListeners();
  }

  /// Get order detail
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

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _orderRepository.updateOrderStatus(orderId, newStatus);
      if (success) {
        await loadOrders();
        if (_selectedOrder?.id == orderId) {
          await getOrderDetail(orderId);
        }
      }
      return success;
    } catch (e) {
      _setError('Gagal memperbarui status: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Confirm order (pending -> processing)
  Future<bool> confirmOrder(String orderId) async {
    return await updateOrderStatus(orderId, AppConstants.orderStatusProcessing);
  }

  /// Ship order (processing -> shipped)
  Future<bool> shipOrder(String orderId) async {
    return await updateOrderStatus(orderId, AppConstants.orderStatusShipped);
  }

  /// Complete order (shipped -> delivered)
  Future<bool> completeOrder(String orderId) async {
    return await updateOrderStatus(orderId, AppConstants.orderStatusDelivered);
  }

  /// Cancel order
  Future<bool> cancelOrder(String orderId) async {
    return await updateOrderStatus(orderId, AppConstants.orderStatusCancelled);
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
