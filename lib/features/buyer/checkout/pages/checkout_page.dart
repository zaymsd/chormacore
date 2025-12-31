import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/checkout_provider.dart';

/// Checkout page for completing order
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill address from user profile
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user?.address != null) {
      _addressController.text = user!.address!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _processCheckout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);

    checkoutProvider.setAddress(_addressController.text);
    checkoutProvider.setNotes(_notesController.text.isNotEmpty ? _notesController.text : null);

    final order = await checkoutProvider.processCheckout(
      userId: authProvider.currentUser!.id,
      cartItems: cartProvider.items,
    );

    if (order != null && mounted) {
      // Reload cart to show empty
      await cartProvider.loadCart();
      
      // Show success dialog
      _showSuccessDialog(order.id);
    } else if (mounted && checkoutProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(checkoutProvider.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 60,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Pesanan Berhasil!',
              style: TextStyles.h5,
            ),
            const SizedBox(height: 8),
            Text(
              'Pesanan Anda telah dibuat.\nMohon tunggu konfirmasi dari penjual.',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Lihat Pesanan',
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.buyerHome,
                  (route) => false,
                );
              },
            ),
          ],
        ),
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
      body: Consumer2<CartProvider, CheckoutProvider>(
        builder: (context, cartProvider, checkoutProvider, _) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Address Section
                      _buildSectionCard(
                        title: 'Alamat Pengiriman',
                        icon: Icons.location_on_outlined,
                        child: CustomTextField(
                          controller: _addressController,
                          hint: 'Masukkan alamat lengkap pengiriman',
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Payment Method Section
                      _buildSectionCard(
                        title: 'Metode Pembayaran',
                        icon: Icons.payment_outlined,
                        child: Column(
                          children: [
                            _buildPaymentOption(
                              value: AppConstants.paymentCOD,
                              title: 'Bayar di Tempat (COD)',
                              subtitle: 'Bayar saat pesanan diterima',
                              icon: Icons.money_outlined,
                              provider: checkoutProvider,
                            ),
                            _buildPaymentOption(
                              value: AppConstants.paymentTransfer,
                              title: 'Transfer Bank',
                              subtitle: 'Transfer ke rekening penjual',
                              icon: Icons.account_balance_outlined,
                              provider: checkoutProvider,
                            ),
                            _buildPaymentOption(
                              value: AppConstants.paymentEwallet,
                              title: 'E-Wallet',
                              subtitle: 'DANA, OVO, GoPay, dll',
                              icon: Icons.wallet_outlined,
                              provider: checkoutProvider,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes Section
                      _buildSectionCard(
                        title: 'Catatan (Opsional)',
                        icon: Icons.note_outlined,
                        child: CustomTextField(
                          controller: _notesController,
                          hint: 'Catatan untuk penjual...',
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Order Summary
                      _buildSectionCard(
                        title: 'Ringkasan Pesanan',
                        icon: Icons.receipt_outlined,
                        child: Column(
                          children: [
                            ...cartProvider.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.product?.name ?? "Produk"} x${item.quantity}',
                                      style: TextStyles.bodyMedium,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(item.subtotal),
                                    style: TextStyles.labelMedium,
                                  ),
                                ],
                              ),
                            )),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total', style: TextStyles.labelLarge),
                                Text(
                                  CurrencyFormatter.format(cartProvider.total),
                                  style: TextStyles.priceLarge,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Checkout Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: CustomButton(
                    text: 'Buat Pesanan - ${CurrencyFormatter.format(cartProvider.total)}',
                    onPressed: _processCheckout,
                    isLoading: checkoutProvider.isLoading,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: TextStyles.labelLarge),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required CheckoutProvider provider,
  }) {
    final isSelected = provider.paymentMethod == value;
    return GestureDetector(
      onTap: () => provider.setPaymentMethod(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.labelMedium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
