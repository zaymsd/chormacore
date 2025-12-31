import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/product_management_provider.dart';

/// Seller product list page - Standalone with GridView
class SellerProductListPage extends StatefulWidget {
  const SellerProductListPage({super.key});

  @override
  State<SellerProductListPage> createState() => _SellerProductListPageState();
}

class _SellerProductListPageState extends State<SellerProductListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        Provider.of<ProductManagementProvider>(context, listen: false)
            .setSeller(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Produk Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addProduct),
          ),
        ],
      ),
      body: Consumer<ProductManagementProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.hasProducts) {
            return const LoadingWidget(message: 'Memuat produk...');
          }

          if (!provider.hasProducts) {
            return EmptyProductWidget(
              onAddProduct: () => Navigator.pushNamed(context, AppRoutes.addProduct),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                final product = provider.products[index];
                return _buildProductCard(context, product, provider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addProduct),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product, ProductManagementProvider provider) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.getEditProductRoute(product.id));
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
            // Product Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  width: double.infinity,
                  color: AppColors.surfaceVariant,
                  child: _buildProductImage(product),
                ),
              ),
            ),
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyles.labelMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      CurrencyFormatter.format(product.price),
                      style: TextStyles.priceMedium.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildSmallBadge(
                          'Stok: ${product.stock}',
                          product.isInStock ? AppColors.success : AppColors.error,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _showDeleteDialog(context, provider, product.id),
                          child: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        ),
                      ],
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

  Widget _buildProductImage(dynamic product) {
    if (product.images != null && product.images.isNotEmpty) {
      final imagePath = product.images[0] as String;
      
      if (imagePath.startsWith('http')) {
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
        );
      } else {
        final file = File(imagePath);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
          );
        }
      }
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(Icons.computer, size: 40, color: AppColors.textHint),
    );
  }

  Widget _buildSmallBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ProductManagementProvider provider, String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Produk yang dihapus tidak dapat dikembalikan. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteProduct(productId);
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
