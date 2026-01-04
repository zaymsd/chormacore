import 'dart:io';
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

/// Buyer order list page with dropdown filters
class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedStatus;
  
  final List<Map<String, dynamic>> _statusOptions = [
    {'value': null, 'label': 'Semua Status'},
    {'value': 'pending', 'label': 'Menunggu'},
    {'value': 'processing', 'label': 'Diproses'},
    {'value': 'shipped', 'label': 'Dikirim'},
    {'value': 'delivered', 'label': 'Selesai'},
    {'value': 'cancelled', 'label': 'Dibatalkan'},
  ];

  @override
  void initState() {
    super.initState();
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

  List<OrderModel> _applyFilters(List<OrderModel> orders) {
    var filtered = orders;
    
    // Filter by status
    if (_selectedStatus != null) {
      filtered = filtered.where((o) => o.status == _selectedStatus).toList();
    }
    
    // Filter by date
    if (_startDate != null || _endDate != null) {
      filtered = filtered.where((order) {
        final orderDate = order.createdAt;
        if (_startDate != null && orderDate.isBefore(_startDate!)) return false;
        if (_endDate != null && orderDate.isAfter(_endDate!.add(const Duration(days: 1)))) return false;
        return true;
      }).toList();
    }
    
    return filtered;
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

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        actions: [
          if (_startDate != null || _endDate != null || _selectedStatus != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              onPressed: _clearFilters,
              tooltip: 'Hapus Filter',
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Header
          _buildFilterHeader(),
          
          // Order List
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, _) {
                if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
                  return const LoadingWidget(message: 'Memuat pesanan...');
                }

                final filteredOrders = _applyFilters(orderProvider.orders);

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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    final dateFormat = DateFormat('dd/MM/yy', 'id_ID');
    String dateLabel = 'Pilih Tanggal';
    if (_startDate != null && _endDate != null) {
      dateLabel = '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}';
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date Filter Dropdown
          Expanded(
            child: GestureDetector(
              onTap: _selectDateRange,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                  color: _startDate != null ? AppColors.primary.withValues(alpha: 0.05) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: _startDate != null ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dateLabel,
                        style: TextStyles.bodySmall.copyWith(
                          color: _startDate != null ? AppColors.primary : AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_startDate != null)
                      GestureDetector(
                        onTap: () => setState(() {
                          _startDate = null;
                          _endDate = null;
                        }),
                        child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Status Filter Dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
                color: _selectedStatus != null ? AppColors.primary.withValues(alpha: 0.05) : null,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _selectedStatus,
                  isExpanded: true,
                  hint: Text(
                    'Status',
                    style: TextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  style: TextStyles.bodySmall.copyWith(
                    color: _selectedStatus != null ? AppColors.primary : AppColors.textPrimary,
                  ),
                  items: _statusOptions.map((option) {
                    return DropdownMenuItem<String?>(
                      value: option['value'],
                      child: Text(
                        option['label'],
                        style: TextStyles.bodySmall,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                  },
                ),
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
            // Header - Order ID & Status
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
                        if (order.sellerName != null)
                          Text(
                            order.sellerName!,
                            style: TextStyles.bodySmall.copyWith(
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

            // Items with photos
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ...order.items.take(2).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 50,
                            height: 50,
                            color: AppColors.surfaceVariant,
                            child: _buildProductImage(item.productImage),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Product Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: TextStyles.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${item.quantity}x ${CurrencyFormatter.format(item.price)}',
                                style: TextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
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
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '+${order.items.length - 2} produk lainnya',
                        style: TextStyles.caption.copyWith(color: AppColors.primary),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Footer - Date & Total
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      DateFormatter.formatDateTime(order.createdAt),
                      style: TextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Total', style: TextStyles.caption),
                      Text(
                        CurrencyFormatter.format(order.total),
                        style: TextStyles.priceMedium,
                      ),
                    ],
                  ),
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
      return const Center(
        child: Icon(Icons.computer, size: 24, color: AppColors.textHint),
      );
    }
    
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 24),
      );
    } else {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return const Center(
      child: Icon(Icons.computer, size: 24, color: AppColors.textHint),
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
        style: TextStyles.labelSmall.copyWith(color: textColor, fontWeight: FontWeight.w500),
      ),
    );
  }
}
