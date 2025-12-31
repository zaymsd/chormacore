import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../data/models/order_model.dart';
import '../providers/order_provider.dart';

/// Order detail page showing full order information
class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false)
          .getOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading) {
            return const LoadingWidget(message: 'Memuat detail...');
          }

          final order = orderProvider.selectedOrder;
          if (order == null) {
            return const Center(child: Text('Pesanan tidak ditemukan'));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Status
                      _buildStatusCard(order),
                      const SizedBox(height: 16),

                      // Order Info
                      _buildInfoCard(order),
                      const SizedBox(height: 16),

                      // Delivery Address
                      _buildAddressCard(order),
                      const SizedBox(height: 16),

                      // Order Items
                      _buildItemsCard(order),
                      const SizedBox(height: 16),

                      // Payment Summary
                      _buildPaymentCard(order),
                    ],
                  ),
                ),
              ),

              // Action Button
              if (order.isPending)
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
                    child: SecondaryButton(
                      text: 'Batalkan Pesanan',
                      onPressed: () => _showCancelDialog(order.id),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: _getStatusGradient(order.status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(order.status),
              color: AppColors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.statusText,
                  style: TextStyles.h6.copyWith(color: AppColors.white),
                ),
                Text(
                  _getStatusDescription(order.status),
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow('No. Pesanan', '#${order.id.substring(0, 8).toUpperCase()}'),
          const Divider(height: 16),
          _buildInfoRow('Tanggal', DateFormatter.formatOrderDate(order.createdAt)),
          const Divider(height: 16),
          _buildInfoRow('Pembayaran', order.paymentMethodText),
          if (order.sellerName != null) ...[
            const Divider(height: 16),
            _buildInfoRow('Penjual', order.sellerName!),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Alamat Pengiriman', style: TextStyles.labelLarge),
            ],
          ),
          const SizedBox(height: 12),
          Text(order.address, style: TextStyles.bodyMedium),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Catatan: ${order.notes}',
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Produk Dipesan', style: TextStyles.labelLarge),
          const SizedBox(height: 12),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: item.productImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.productImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_outlined,
                              color: AppColors.textHint,
                            ),
                          ),
                        )
                      : const Icon(Icons.image_outlined, color: AppColors.textHint),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.productName, style: TextStyles.bodyMedium),
                      Text(
                        '${item.quantity} x ${CurrencyFormatter.format(item.price)}',
                        style: TextStyles.caption,
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
        ],
      ),
    );
  }

  Widget _buildPaymentCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Pembayaran', style: TextStyles.labelLarge),
              Text(
                CurrencyFormatter.format(order.total),
                style: TextStyles.priceLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text(value, style: TextStyles.labelMedium),
      ],
    );
  }

  LinearGradient _getStatusGradient(String status) {
    switch (status) {
      case 'pending':
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        );
      case 'processing':
        return const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
        );
      case 'shipped':
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
        );
      case 'delivered':
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF34D399)],
        );
      case 'cancelled':
        return const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFF87171)],
        );
      default:
        return AppColors.primaryGradient;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'processing':
        return Icons.inventory_2_outlined;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu konfirmasi penjual';
      case 'processing':
        return 'Pesanan sedang diproses';
      case 'shipped':
        return 'Pesanan dalam pengiriman';
      case 'delivered':
        return 'Pesanan telah diterima';
      case 'cancelled':
        return 'Pesanan dibatalkan';
      default:
        return '';
    }
  }

  void _showCancelDialog(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final orderProvider = Provider.of<OrderProvider>(context, listen: false);
              await orderProvider.cancelOrder(orderId);
              if (context.mounted) {
                Navigator.pop(context); // Go back to order list
              }
            },
            child: const Text('Ya, Batalkan', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
