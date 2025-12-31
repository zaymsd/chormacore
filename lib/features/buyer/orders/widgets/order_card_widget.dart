import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/order_model.dart';

/// Order card widget for displaying in order list
class OrderCardWidget extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const OrderCardWidget({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8).toUpperCase()}',
                        style: TextStyles.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatter.formatOrderDate(order.createdAt),
                        style: TextStyles.caption,
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const Divider(height: 24),
            
            // Order items preview
            if (order.items.isNotEmpty)
              ...order.items.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
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
                                  size: 20,
                                  color: AppColors.textHint,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.image_outlined,
                              size: 20,
                              color: AppColors.textHint,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${item.productName} x${item.quantity}',
                        style: TextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
            
            if (order.items.length > 2)
              Text(
                '+${order.items.length - 2} produk lainnya',
                style: TextStyles.caption.copyWith(color: AppColors.primary),
              ),
            
            const SizedBox(height: 12),
            
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pesanan',
                      style: TextStyles.caption,
                    ),
                    Text(
                      CurrencyFormatter.format(order.total),
                      style: TextStyles.priceMedium,
                    ),
                  ],
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.statusPending;
      case 'processing':
        return AppColors.statusProcessing;
      case 'shipped':
        return AppColors.statusShipped;
      case 'delivered':
        return AppColors.statusDelivered;
      case 'cancelled':
        return AppColors.statusCancelled;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}
