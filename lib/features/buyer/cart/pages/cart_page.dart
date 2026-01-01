import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/cart_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/cart_provider.dart';

/// Shopping cart page
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        Provider.of<CartProvider>(context, listen: false)
            .setUser(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Keranjang'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              if (cart.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showClearCartDialog(context, cart),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isLoading && cart.isEmpty) {
            return const LoadingWidget(message: 'Memuat keranjang...');
          }

          if (cart.isEmpty) {
            return EmptyCartWidget(
              onStartShopping: () => Navigator.pop(context),
            );
          }

          return Column(
            children: [
              // Cart Items List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _buildCartItem(item, cart);
                  },
                ),
              ),

              // Bottom Summary
              _buildSummarySection(cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(CartModel item, CartProvider cart) {
    final product = item.product;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: AppColors.surfaceVariant,
              child: _buildProductImage(product?.firstImage),
            ),
          ),
          const SizedBox(width: 12),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product?.name ?? 'Produk',
                  style: TextStyles.labelMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(product?.price ?? 0),
                  style: TextStyles.priceMedium,
                ),
                const SizedBox(height: 8),
                
                // Quantity Controls
                Row(
                  children: [
                    // Delete Button
                    GestureDetector(
                      onTap: () => _showDeleteItemDialog(context, cart, item),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    const Spacer(),
                    
                    // Quantity Selector
                    _buildQuantitySelector(item, cart),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const Icon(Icons.computer, color: AppColors.textHint);
    }
    
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    } else {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return const Icon(Icons.computer, color: AppColors.textHint);
  }

  Widget _buildQuantitySelector(CartModel item, CartProvider cart) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            onPressed: item.quantity > 1
                ? () => cart.updateQuantity(item.id, item.quantity - 1)
                : () => _showDeleteItemDialog(context, cart, item),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            alignment: Alignment.center,
            child: Text('${item.quantity}', style: TextStyles.labelMedium),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            onPressed: item.quantity < (item.product?.stock ?? 99)
                ? () => cart.updateQuantity(item.id, item.quantity + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Summary Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total (${cart.totalQuantity} item)',
                      style: TextStyles.caption,
                    ),
                    Text(
                      CurrencyFormatter.format(cart.total),
                      style: TextStyles.h5.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                
                // Checkout Button
                SizedBox(
                  width: 160,
                  child: CustomButton(
                    text: 'Checkout',
                    onPressed: cart.isEmpty
                        ? null
                        : () => Navigator.pushNamed(context, AppRoutes.checkout),
                    icon: Icons.shopping_bag_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteItemDialog(BuildContext context, CartProvider cart, CartModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item'),
        content: Text('Hapus "${item.product?.name ?? 'item'}" dari keranjang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cart.removeItem(item.id);
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kosongkan Keranjang'),
        content: const Text('Semua item akan dihapus dari keranjang. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cart.clearCart();
            },
            child: const Text('Kosongkan', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
