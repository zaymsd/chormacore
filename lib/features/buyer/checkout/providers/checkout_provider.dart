import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/cart_model.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/repositories/cart_repository.dart';
import '../../../../data/repositories/product_repository.dart';

/// Provider for checkout process
class CheckoutProvider extends ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();
  final CartRepository _cartRepository = CartRepository();
  final ProductRepository _productRepository = ProductRepository();

  bool _isLoading = false;
  String? _error;
  String _address = '';
  String _paymentMethod = AppConstants.paymentCOD;
  String? _notes;
  OrderModel? _lastOrder;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get address => _address;
  String get paymentMethod => _paymentMethod;
  String? get notes => _notes;
  OrderModel? get lastOrder => _lastOrder;

  /// Set delivery address
  void setAddress(String value) {
    _address = value;
    notifyListeners();
  }

  /// Set payment method
  void setPaymentMethod(String value) {
    _paymentMethod = value;
    notifyListeners();
  }

  /// Set notes
  void setNotes(String? value) {
    _notes = value;
    notifyListeners();
  }

  /// Validate checkout data
  bool validate() {
    if (_address.trim().isEmpty) {
      _setError('Alamat pengiriman harus diisi');
      return false;
    }
    return true;
  }

  /// Process checkout
  Future<OrderModel?> processCheckout({
    required String userId,
    required List<CartModel> cartItems,
  }) async {
    if (!validate()) return null;
    if (cartItems.isEmpty) {
      _setError('Keranjang kosong');
      return null;
    }

    _setLoading(true);
    _clearError();

    try {
      // Group cart items by seller
      final Map<String, List<CartModel>> itemsBySeller = {};
      for (var item in cartItems) {
        final sellerId = item.product?.sellerId ?? '';
        if (sellerId.isEmpty) continue;
        
        itemsBySeller.putIfAbsent(sellerId, () => []);
        itemsBySeller[sellerId]!.add(item);
      }

      OrderModel? firstOrder;

      // Create order for each seller
      for (var entry in itemsBySeller.entries) {
        final sellerId = entry.key;
        final sellerItems = entry.value;

        final order = await _orderRepository.createOrder(
          userId: userId,
          sellerId: sellerId,
          cartItems: sellerItems,
          address: _address,
          paymentMethod: _paymentMethod,
          notes: _notes,
        );

        firstOrder ??= order;

        // Update product stock and sold count
        for (var item in sellerItems) {
          await _productRepository.decreaseStock(item.productId, item.quantity);
          await _productRepository.incrementSoldCount(item.productId, item.quantity);
        }
      }

      // Clear cart
      await _cartRepository.clearCart(userId);

      _lastOrder = firstOrder;
      _resetForm();
      
      return firstOrder;
    } catch (e) {
      _setError('Gagal memproses pesanan: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Reset form
  void _resetForm() {
    _address = '';
    _paymentMethod = AppConstants.paymentCOD;
    _notes = null;
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
