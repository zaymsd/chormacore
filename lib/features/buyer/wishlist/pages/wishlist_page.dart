import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

/// Wishlist page showing all favorited products
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, provider, _) {
              if (provider.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => _showClearDialog(context, provider),
              );
            },
          ),
        ],
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, _) {
          if (wishlistProvider.isLoading && wishlistProvider.isEmpty) {
            return const LoadingWidget(message: 'Memuat wishlist...');
          }

          if (wishlistProvider.isEmpty) {
            return EmptyWishlistWidget(
              onExplore: () => Navigator.pop(context),
            );
          }

          return RefreshIndicator(
            onRefresh: wishlistProvider.refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wishlistProvider.items.length,
              itemBuilder: (context, index) {
                final item = wishlistProvider.items[index];
                final product = item.product;
                
                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    wishlistProvider.removeFromWishlist(item.id);
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppColors.error,
                    child: const Icon(Icons.delete, color: AppColors.white),
                  ),
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.getProductDetailRoute(item.productId),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  color: AppColors.surfaceVariant,
                                  child: product?.firstImage != null
                                      ? Image.network(
                                          product!.firstImage!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.image_outlined),
                                        )
                                      : const Icon(Icons.image_outlined),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Product Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product?.name ?? 'Produk',
                                      style: TextStyles.bodyMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      CurrencyFormatter.format(product?.price ?? 0),
                                      style: TextStyles.priceMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    // Add to cart button
                                    SizedBox(
                                      height: 32,
                                      child: ElevatedButton.icon(
                                        onPressed: product?.isInStock == true
                                            ? () => _addToCart(context, item.productId)
                                            : null,
                                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                                        label: Text(
                                          product?.isInStock == true
                                              ? 'Tambah ke Keranjang'
                                              : 'Stok Habis',
                                          style: TextStyles.labelSmall,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Remove button
                              IconButton(
                                icon: const Icon(
                                  Icons.favorite,
                                  color: AppColors.error,
                                ),
                                onPressed: () {
                                  wishlistProvider.removeFromWishlist(item.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _addToCart(BuildContext context, String productId) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final success = await cartProvider.addToCart(productId);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Ditambahkan ke keranjang' : 'Gagal menambahkan'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _showClearDialog(BuildContext context, WishlistProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kosongkan Wishlist'),
        content: const Text('Hapus semua item dari wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.clearWishlist();
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
