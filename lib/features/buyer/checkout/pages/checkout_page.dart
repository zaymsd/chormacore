import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';

/// Checkout page
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedPayment = 'cod';
  String _selectedCourier = 'jne';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'cod', 'name': 'Bayar di Tempat (COD)', 'icon': Icons.money},
    {'id': 'transfer', 'name': 'Transfer Bank', 'icon': Icons.account_balance},
    {'id': 'ewallet', 'name': 'E-Wallet', 'icon': Icons.account_balance_wallet},
  ];

  final List<Map<String, dynamic>> _couriers = [
    {'id': 'jne', 'name': 'JNE Regular', 'price': 15000},
    {'id': 'jnt', 'name': 'J&T Express', 'price': 12000},
    {'id': 'sicepat', 'name': 'SiCepat REG', 'price': 14000},
    {'id': 'anteraja', 'name': 'AnterAja', 'price': 13000},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }

  void _loadUserAddress() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser?.address != null) {
      _addressController.text = authProvider.currentUser!.address!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    if (authProvider.currentUser == null || cartProvider.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang kosong'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final orderRepository = OrderRepository();
      final productRepository = ProductRepository();
      
      // Group cart items by seller
      final itemsBySeller = <String, List>{};
      for (var item in cartProvider.items) {
        final sellerId = item.product?.sellerId ?? '';
        if (sellerId.isEmpty) continue;
        itemsBySeller.putIfAbsent(sellerId, () => []).add(item);
      }

      // Create orders for each seller
      for (var entry in itemsBySeller.entries) {
        final sellerId = entry.key;
        final items = entry.value;

        await orderRepository.createOrder(
          userId: authProvider.currentUser!.id,
          sellerId: sellerId,
          cartItems: items.cast(),
          address: _addressController.text.trim(),
          paymentMethod: _selectedPayment,
          notes: _notesController.text.trim().isNotEmpty 
              ? _notesController.text.trim() 
              : null,
        );

        // Decrease stock for each product
        for (var item in items) {
          await productRepository.decreaseStock(item.productId, item.quantity);
        }
      }

      // Clear cart
      await cartProvider.clearCart();

      if (mounted) {
        // Show success dialog
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses pesanan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 32),
            const SizedBox(width: 8),
            const Text('Pesanan Berhasil'),
          ],
        ),
        content: const Text(
          'Pesanan Anda telah berhasil dibuat. Anda dapat melihat status pesanan di halaman Pesanan.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.buyerHome,
                (route) => false,
              );
            },
            child: const Text('Kembali ke Beranda'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.buyerOrders,
                (route) => route.settings.name == AppRoutes.buyerHome,
              );
            },
            child: const Text('Lihat Pesanan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Shipping Address
                        _buildSectionTitle('Alamat Pengiriman'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: 'Alamat Lengkap',
                          hint: 'Masukkan alamat pengiriman lengkap',
                          controller: _addressController,
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Alamat wajib diisi';
                            }
                            return null;
                          },
                          prefixIcon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 24),

                        // Order Items
                        _buildSectionTitle('Ringkasan Pesanan (${cart.itemCount} item)'),
                        const SizedBox(height: 8),
                        _buildOrderSummary(cart),
                        const SizedBox(height: 24),

                        // Payment Method
                        _buildSectionTitle('Metode Pembayaran'),
                        const SizedBox(height: 8),
                        _buildPaymentMethods(),
                        const SizedBox(height: 24),

                        // Courier Selection
                        _buildSectionTitle('Pilih Kurir'),
                        const SizedBox(height: 8),
                        _buildCourierSelection(),
                        const SizedBox(height: 24),

                        // Notes
                        _buildSectionTitle('Catatan (Opsional)'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: 'Catatan untuk penjual',
                          hint: 'Contoh: Kirim setelah jam 5 sore',
                          controller: _notesController,
                          maxLines: 2,
                          prefixIcon: Icons.note_outlined,
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Summary & Pay Button
                _buildBottomSection(cart),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyles.labelLarge);
  }

  Widget _buildOrderSummary(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ...cart.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product?.name ?? 'Produk',
                        style: TextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${item.quantity} x ${CurrencyFormatter.format(item.product?.price ?? 0)}',
                        style: TextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(item.subtotal),
                  style: TextStyles.labelMedium,
                ),
              ],
            ),
          )),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyles.labelMedium),
              Text(
                CurrencyFormatter.format(cart.total),
                style: TextStyles.h6.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: _paymentMethods.map((method) {
          final isSelected = _selectedPayment == method['id'];
          return RadioListTile<String>(
            value: method['id'],
            groupValue: _selectedPayment,
            onChanged: (value) => setState(() => _selectedPayment = value!),
            title: Row(
              children: [
                Icon(
                  method['icon'],
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  method['name'],
                  style: TextStyles.bodyMedium.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            activeColor: AppColors.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCourierSelection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: _couriers.map((courier) {
          final isSelected = _selectedCourier == courier['id'];
          return RadioListTile<String>(
            value: courier['id'],
            groupValue: _selectedCourier,
            onChanged: (value) => setState(() => _selectedCourier = value!),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  courier['name'],
                  style: TextStyles.bodyMedium.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(courier['price'].toDouble()),
                  style: TextStyles.labelMedium.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            activeColor: AppColors.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          );
        }).toList(),
      ),
    );
  }

  double _getShippingCost() {
    final courier = _couriers.firstWhere(
      (c) => c['id'] == _selectedCourier,
      orElse: () => {'price': 0},
    );
    return (courier['price'] as num).toDouble();
  }

  Widget _buildBottomSection(CartProvider cart) {
    final shippingCost = _getShippingCost();
    final grandTotal = cart.total + shippingCost;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Shipping cost
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ongkos Kirim', style: TextStyles.caption),
                Text(CurrencyFormatter.format(shippingCost), style: TextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            // Grand total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Bayar', style: TextStyles.labelMedium),
                Text(
                  CurrencyFormatter.format(grandTotal),
                  style: TextStyles.h6.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Pay Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Bayar Sekarang',
                onPressed: _isLoading ? null : _processCheckout,
                isLoading: _isLoading,
                icon: Icons.payment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
