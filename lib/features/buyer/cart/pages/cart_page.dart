import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/routes/app_routes.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/cart_summary_widget.dart';

/// Cart page displaying all items in cart
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Keranjang'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              if (cartProvider.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => _showClearCartDialog(context, cartProvider),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.isLoading && cartProvider.isEmpty) {
            return const LoadingWidget(message: 'Memuat keranjang...');
          }

          if (cartProvider.isEmpty) {
            return EmptyCartWidget(
              onStartShopping: () => Navigator.pop(context),
            );
          }

          return Column(
            children: [
              // Cart items list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return CartItemWidget(
                      cartItem: item,
                      onRemove: () => _showRemoveDialog(
                        context,
                        cartProvider,
                        item.id,
                      ),
                      onQuantityChanged: (quantity) {
                        cartProvider.updateQuantity(item.id, quantity);
                      },
                    );
                  },
                ),
              ),
              
              // Cart summary
              CartSummaryWidget(
                total: cartProvider.total,
                itemCount: cartProvider.itemCount,
                isLoading: cartProvider.isLoading,
                onCheckout: () {
                  Navigator.pushNamed(context, AppRoutes.checkout);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRemoveDialog(
    BuildContext context,
    CartProvider provider,
    String cartId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item'),
        content: const Text('Apakah Anda yakin ingin menghapus item ini dari keranjang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.removeItem(cartId);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(
    BuildContext context,
    CartProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kosongkan Keranjang'),
        content: const Text('Apakah Anda yakin ingin menghapus semua item dari keranjang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.clearCart();
            },
            child: const Text(
              'Kosongkan',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
