import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/order_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/order_provider.dart';

/// Buyer order list page with date filter
class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _startDate;
  DateTime? _endDate;
  
  final _tabs = [
    {'label': 'Semua', 'status': null},
    {'label': 'Pending', 'status': 'pending'},
    {'label': 'Diproses', 'status': 'processing'},
    {'label': 'Dikirim', 'status': 'shipped'},
    {'label': 'Selesai', 'status': 'delivered'},
    {'label': 'Dibatalkan', 'status': 'cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  void _loadOrders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      Provider.of<OrderProvider>(context, listen: false)
          .loadBuyerOrders(authProvider.currentUser!.id);
    }
  }

  List<OrderModel> _filterByDate(List<OrderModel> orders) {
    if (_startDate == null && _endDate == null) return orders;
    
    return orders.where((order) {
      final orderDate = order.createdAt;
      if (_startDate != null && orderDate.isBefore(_startDate!)) return false;
      if (_endDate != null && orderDate.isAfter(_endDate!.add(const Duration(days: 1)))) return false;
      return true;
    }).toList();
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
        title: const Text('Pesanan Saya'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_month,
              color: (_startDate != null || _endDate != null) 
                  ? AppColors.primary 
                  : null,
            ),
            onPressed: _selectDateRange,
            tooltip: 'Filter tanggal',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_startDate != null ? 90 : 46),
          child: Column(
            children: [
              // Date filter indicator
              if (_startDate != null) _buildDateFilterChip(),
              // Status tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _tabs.map((tab) => Tab(text: tab['label'] as String)).toList(),
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
            return const LoadingWidget(message: 'Memuat pesanan...');
          }

          return TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) {
              final status = tab['status'] as String?;
              var filteredOrders = status == null
                  ? orderProvider.orders
                  : orderProvider.orders.where((o) => o.status == status).toList();

              // Apply date filter
              filteredOrders = _filterByDate(filteredOrders);

              if (filteredOrders.isEmpty) {
                return const EmptyOrderWidget();
              }

              return RefreshIndicator(
                onRefresh: () async => _loadOrders(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(filteredOrders[index]);
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildDateFilterChip() {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final startStr = _startDate != null ? dateFormat.format(_startDate!) : '';
    final endStr = _endDate != null ? dateFormat.format(_endDate!) : '';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 16, color: AppColors.primary),
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
                  Icon(Icons.close, size: 14, color: AppColors.error),
                  const SizedBox(width: 4),
                  Text(
                    'Hapus Filter',
                    style: TextStyles.caption.copyWith(color: AppColors.error),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.getBuyerOrderDetailRoute(order.id),
        );
      },
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 8).toUpperCase()}',
                  style: TextStyles.labelMedium,
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 8),
            
            // Date
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  DateFormatter.formatDateTime(order.createdAt),
                  style: TextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Seller
            if (order.sellerName != null)
              Row(
                children: [
                  const Icon(Icons.store, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    order.sellerName!,
                    style: TextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            
            const Divider(height: 24),
            
            // Items Summary
            if (order.items.isNotEmpty)
              Text(
                order.items.map((i) => '${i.quantity}x ${i.productName}').join(', '),
                style: TextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            
            const SizedBox(height: 12),
            
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Pembayaran', style: TextStyles.caption),
                Text(
                  CurrencyFormatter.format(order.total),
                  style: TextStyles.priceMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'pending':
        bgColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        label = 'Menunggu';
        break;
      case 'processing':
        bgColor = AppColors.info.withValues(alpha: 0.1);
        textColor = AppColors.info;
        label = 'Diproses';
        break;
      case 'shipped':
        bgColor = AppColors.secondary.withValues(alpha: 0.1);
        textColor = AppColors.secondary;
        label = 'Dikirim';
        break;
      case 'delivered':
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        label = 'Selesai';
        break;
      case 'cancelled':
        bgColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        label = 'Dibatalkan';
        break;
      default:
        bgColor = AppColors.surfaceVariant;
        textColor = AppColors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyles.caption.copyWith(color: textColor, fontWeight: FontWeight.w500),
      ),
    );
  }
}
