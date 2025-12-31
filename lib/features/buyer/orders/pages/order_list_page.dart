import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/order_card_widget.dart';

/// Order list page showing all buyer orders
class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        Provider.of<OrderProvider>(context, listen: false)
            .setUser(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading && !orderProvider.hasOrders) {
            return const LoadingWidget(message: 'Memuat pesanan...');
          }

          if (!orderProvider.hasOrders) {
            return EmptyOrderWidget(
              onBrowse: () => Navigator.pop(context),
            );
          }

          return RefreshIndicator(
            onRefresh: orderProvider.refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderProvider.orders.length,
              itemBuilder: (context, index) {
                final order = orderProvider.orders[index];
                return OrderCardWidget(
                  order: order,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.getOrderDetailRoute(order.id),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
