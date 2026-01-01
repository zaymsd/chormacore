import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/wishlist_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

/// Wishlist page
class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        Provider.of<WishlistProvider>(context, listen: false)
            .setUser(authProvider.currentUser!.id);
      }
    });
  }

  Future<void> _addToCart(WishlistModel item) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.setUser(authProvider.currentUser!.id);
    
    final success = await cartProvider.addToCart(item.productId);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ditambahkan ke keranjang'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Lihat',
              textColor: Colors.white,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlist, _) {
              if (wishlist.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => _showClearDialog(context, wishlist),
              );
            },
          ),
        ],
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlist, _) {
          if (wishlist.isLoading && wishlist.isEmpty) {
            return const LoadingWidget(message: 'Memuat wishlist...');
          }

          if (wishlist.isEmpty) {
            return EmptyWishlistWidget(
              onExplore: () => Navigator.pop(context),
            );
          }

          return RefreshIndicator(
            onRefresh: wishlist.refresh,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemCount: wishlist.items.length,
              itemBuilder: (context, index) {
                return _buildWishlistCard(wishlist.items[index], wishlist);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildWishlistCard(WishlistModel item, WishlistProvider wishlist) {
    final product = item.product;
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.getProductDetailRoute(item.productId),
        );
      },
      child: Container(
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
            // Product Image with Remove Button
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      color: AppColors.surfaceVariant,
                      child: _buildProductImage(product?.firstImage),
                    ),
                  ),
                ),
                // Remove Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => wishlist.removeFromWishlist(item.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 18,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.name ?? 'Produk',
                      style: TextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      CurrencyFormatter.format(product?.price ?? 0),
                      style: TextStyles.priceMedium.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    
                    // Add to Cart Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: product?.isInStock == true
                            ? () => _addToCart(item)
                            : null,
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: Text(
                          product?.isInStock == true ? 'Keranjang' : 'Habis',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
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
        child: Icon(Icons.computer, size: 40, color: AppColors.textHint),
      );
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
    return const Center(
      child: Icon(Icons.computer, size: 40, color: AppColors.textHint),
    );
  }

  void _showClearDialog(BuildContext context, WishlistProvider wishlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kosongkan Wishlist'),
        content: const Text('Semua item akan dihapus dari wishlist. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              wishlist.clearWishlist();
            },
            child: const Text('Kosongkan', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
