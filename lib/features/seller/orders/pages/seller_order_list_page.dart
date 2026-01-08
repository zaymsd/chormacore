import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/seller_order_provider.dart';

/// Seller order list page with status tabs and date filter
class SellerOrderListPage extends StatefulWidget {
  const SellerOrderListPage({super.key});

  @override
  State<SellerOrderListPage> createState() => _SellerOrderListPageState();
}

class _SellerOrderListPageState extends State<SellerOrderListPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _startDate;
  DateTime? _endDate;

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

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Kelola Pesanan'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_month,
              color: (_startDate != null) ? AppColors.primary : null,
            ),
            onPressed: _selectDateRange,
            tooltip: 'Filter Tanggal',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_startDate != null ? 90 : 46),
          child: Column(
            children: [
              if (_startDate != null) _buildDateFilterChip(),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _tabs.map((tab) => Tab(text: tab['label'] as String)).toList(),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<SellerOrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.hasOrders) {
            return const LoadingWidget(message: 'Memuat pesanan...');
          }

          if (!provider.hasOrders) {
            return const EmptyOrderWidget();
          }

          // Apply date filter
          var orders = provider.orders;
          if (_startDate != null || _endDate != null) {
            orders = orders.where((order) {
              final orderDate = order.createdAt;
              if (_startDate != null && orderDate.isBefore(_startDate!)) return false;
              if (_endDate != null && orderDate.isAfter(_endDate!.add(const Duration(days: 1)))) return false;
              return true;
            }).toList();
          }

          if (orders.isEmpty) {
            return const Center(
              child: Text('Tidak ada pesanan di rentang tanggal ini'),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(context, order, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateFilterChip() {
    final dateFormat = DateFormat('dd/MM/yy', 'id_ID');
    final startStr = _startDate != null ? dateFormat.format(_startDate!) : '';
    final endStr = _endDate != null ? dateFormat.format(_endDate!) : '';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$startStr - $endStr',
              style: TextStyles.caption.copyWith(color: AppColors.primary),
            ),
          ),
          GestureDetector(
            onTap: _clearDateFilter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.close, size: 14, color: AppColors.error),
                  const SizedBox(width: 4),
                  Text('Hapus', style: TextStyles.caption.copyWith(color: AppColors.error)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order, SellerOrderProvider provider) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.getSellerOrderDetailRoute(order.id));
      },
      child: Container(
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
                          style: TextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
            ),
            const Divider(height: 1),

            // Items preview with images
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ...order.items.take(2).map<Widget>((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            width: 40,
                            height: 40,
                            color: AppColors.surfaceVariant,
                            child: _buildProductImage(item.productImage),
                          ),
                        ),
                        const SizedBox(width: 10),
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
      ),
    );
  }

  Widget _buildProductImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const Center(child: Icon(Icons.computer, size: 20, color: AppColors.textHint));
    }
    
    if (imagePath.startsWith('http')) {
      return Image.network(imagePath, fit: BoxFit.cover, 
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 20));
    } else {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return const Center(child: Icon(Icons.computer, size: 20, color: AppColors.textHint));
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
