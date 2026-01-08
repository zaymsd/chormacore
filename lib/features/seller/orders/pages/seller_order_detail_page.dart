import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../providers/seller_order_provider.dart';

/// Seller order detail page
class SellerOrderDetailPage extends StatefulWidget {
  final String orderId;
  
  const SellerOrderDetailPage({super.key, required this.orderId});

  @override
  State<SellerOrderDetailPage> createState() => _SellerOrderDetailPageState();
}

class _SellerOrderDetailPageState extends State<SellerOrderDetailPage> {
  final OrderRepository _orderRepository = OrderRepository();
  OrderModel? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    try {
      final order = await _orderRepository.getOrderById(widget.orderId);
      if (mounted) {
        setState(() {
          _order = order;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat detail...')
          : _order == null
              ? const Center(child: Text('Pesanan tidak ditemukan'))
              : _buildContent(),
      bottomNavigationBar: _order != null && !_order!.isCancelled && !_order!.isDelivered
          ? _buildActionBar()
          : null,
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          _buildOrderHeader(),
          const SizedBox(height: 16),
          
          // Buyer Info
          _buildSection('Informasi Pembeli', _buildBuyerInfo()),
          const SizedBox(height: 16),
          
          // Order Items
          _buildSection('Produk Dipesan', _buildOrderItems()),
          const SizedBox(height: 16),
          
          // Order Summary
          _buildSection('Ringkasan Pembayaran', _buildPaymentSummary()),
          
          // Notes
          if (_order!.notes != null && _order!.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection('Catatan Pembeli', _buildNotes()),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${_order!.id.substring(0, 8).toUpperCase()}',
                  style: TextStyles.h5,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.formatDateTime(_order!.createdAt),
                      style: TextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildStatusBadge(_order!.status),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyles.labelLarge),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: content,
        ),
      ],
    );
  }

  Widget _buildBuyerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person_outline, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(_order!.buyerName ?? 'Pembeli', style: TextStyles.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _order!.address ?? '-',
                style: TextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.payment_outlined, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              _getPaymentMethodLabel(_order!.paymentMethod ?? '-'),
              style: TextStyles.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderItems() {
    return Column(
      children: _order!.items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 60,
                  color: AppColors.surfaceVariant,
                  child: _buildProductImage(item.productImage),
                ),
              ),
              const SizedBox(width: 12),
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: TextStyles.labelMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.quantity}x ${CurrencyFormatter.format(item.price)}',
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
        );
      }).toList(),
    );
  }

  Widget _buildProductImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const Center(child: Icon(Icons.computer, size: 28, color: AppColors.textHint));
    }
    
    if (imagePath.startsWith('http')) {
      return Image.network(imagePath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => 
        const Icon(Icons.broken_image, size: 28, color: AppColors.textHint));
    } else {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return const Center(child: Icon(Icons.computer, size: 28, color: AppColors.textHint));
  }

  Widget _buildPaymentSummary() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal Produk', style: TextStyles.bodySmall),
            Text(CurrencyFormatter.format(_order!.total), style: TextStyles.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ongkos Kirim', style: TextStyles.bodySmall),
            Text('Rp 0', style: TextStyles.bodySmall), // Simplified
          ],
        ),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: TextStyles.labelLarge),
            Text(
              CurrencyFormatter.format(_order!.total),
              style: TextStyles.h6.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Text(
      _order!.notes!,
      style: TextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: _buildActionButton(),
      ),
    );
  }

  Widget _buildActionButton() {
    final provider = Provider.of<SellerOrderProvider>(context, listen: false);
    
    if (_order!.isPending) {
      return CustomButton(
        text: 'Konfirmasi Pesanan',
        icon: Icons.check_circle_outline,
        onPressed: () async {
          await provider.confirmOrder(_order!.id);
          _loadOrder();
        },
      );
    } else if (_order!.isProcessing) {
      return CustomButton(
        text: 'Kirim Pesanan',
        icon: Icons.local_shipping_outlined,
        onPressed: () async {
          await provider.shipOrder(_order!.id);
          _loadOrder();
        },
      );
    } else if (_order!.isShipped) {
      return CustomButton(
        text: 'Selesaikan Pesanan',
        icon: Icons.done_all,
        onPressed: () async {
          await provider.completeOrder(_order!.id);
          _loadOrder();
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = AppColors.warning;
        label = 'Menunggu';
        break;
      case 'processing':
        color = AppColors.info;
        label = 'Diproses';
        break;
      case 'shipped':
        color = AppColors.secondary;
        label = 'Dikirim';
        break;
      case 'delivered':
        color = AppColors.success;
        label = 'Selesai';
        break;
      case 'cancelled':
        color = AppColors.error;
        label = 'Dibatalkan';
        break;
      default:
        color = AppColors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'cod':
        return 'Bayar di Tempat (COD)';
      case 'transfer':
        return 'Transfer Bank';
      case 'ewallet':
        return 'E-Wallet';
      default:
        return method;
    }
  }
}
