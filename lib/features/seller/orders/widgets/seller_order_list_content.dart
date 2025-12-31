import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/seller_order_provider.dart';

/// Embedded order list content for seller dashboard
class SellerOrderListContent extends StatefulWidget {
  const SellerOrderListContent({super.key});

  @override
  State<SellerOrderListContent> createState() => _SellerOrderListContentState();
}

class _SellerOrderListContentState extends State<SellerOrderListContent> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = [
    {'label': 'Semua', 'status': null},
    {'label': 'Baru', 'status': AppConstants.orderStatusPending},
    {'label': 'Proses', 'status': AppConstants.orderStatusProcessing},
    {'label': 'Kirim', 'status': AppConstants.orderStatusShipped},
    {'label': 'Selesai', 'status': AppConstants.orderStatusDelivered},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        Provider.of<SellerOrderProvider>(context, listen: false)
            .setSeller(authProvider.currentUser!.id);
      }
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final status = _tabs[_tabController.index]['status'] as String?;
    Provider.of<SellerOrderProvider>(context, listen: false).filterByStatus(status);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with tabs
        Container(
          color: AppColors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text('Pesanan Masuk', style: TextStyles.h5),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: _tabs.map((tab) => Tab(text: tab['label'] as String)).toList(),
              ),
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: Consumer<SellerOrderProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && !provider.hasOrders) {
                return const LoadingWidget(message: 'Memuat pesanan...');
              }

              if (!provider.hasOrders) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('Belum Ada Pesanan', style: TextStyles.h5),
                      const SizedBox(height: 8),
                      Text(
                        'Pesanan akan muncul di sini',
                        style: TextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: provider.refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.orders.length,
                  itemBuilder: (context, index) {
                    final order = provider.orders[index];
                    return _buildOrderCard(context, order, provider);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order, SellerOrderProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.id.substring(0, 8).toUpperCase()}',
                        style: TextStyles.labelLarge,
                      ),
                      Text(
                        order.buyerName ?? 'Pembeli',
                        style: TextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
          ),
          const Divider(height: 1),

          // Items preview
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ...order.items.take(2).map<Widget>((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.productName} x${item.quantity}',
                          style: TextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(item.subtotal),
                        style: TextStyles.labelSmall,
                      ),
                    ],
                  ),
                )),
                if (order.items.length > 2)
                  Text(
                    '+${order.items.length - 2} produk lainnya',
                    style: TextStyles.caption.copyWith(color: AppColors.primary),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Footer with actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormatter.formatShortDate(order.createdAt),
                        style: TextStyles.caption,
                      ),
                      Text(
                        CurrencyFormatter.format(order.total),
                        style: TextStyles.priceMedium,
                      ),
                    ],
                  ),
                ),
                _buildActionButton(order, provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }

  Widget _buildActionButton(dynamic order, SellerOrderProvider provider) {
    if (order.isCancelled || order.isDelivered) {
      return const SizedBox.shrink();
    }

    String buttonText;
    VoidCallback onPressed;
    Color color = AppColors.primary;

    if (order.isPending) {
      buttonText = 'Konfirmasi';
      onPressed = () => provider.confirmOrder(order.id);
      color = AppColors.success;
    } else if (order.isProcessing) {
      buttonText = 'Kirim';
      onPressed = () => provider.shipOrder(order.id);
      color = AppColors.info;
    } else if (order.isShipped) {
      buttonText = 'Selesai';
      onPressed = () => provider.completeOrder(order.id);
      color = AppColors.success;
    } else {
      return const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        buttonText,
        style: TextStyles.labelSmall.copyWith(color: AppColors.white),
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
        return 'Baru';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Selesai';
      case 'cancelled':
        return 'Batal';
      default:
        return status;
    }
  }
}
