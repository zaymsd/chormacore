import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/product_management_provider.dart';

/// Seller product list page with category filter and FAB
class SellerProductListPage extends StatefulWidget {
  const SellerProductListPage({super.key});

  @override
  State<SellerProductListPage> createState() => _SellerProductListPageState();
}

class _SellerProductListPageState extends State<SellerProductListPage> {
  final CategoryRepository _categoryRepository = CategoryRepository();
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      Provider.of<ProductManagementProvider>(context, listen: false)
          .setSeller(authProvider.currentUser!.id);
    }
    await _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryRepository.getAllCategories();
      if (mounted) {
        setState(() => _categories = categories);
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Produk Saya'),
      ),
      body: Column(
        children: [
          // Category Filter
          _buildCategoryFilter(),
          
          // Product Grid
          Expanded(
            child: Consumer<ProductManagementProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && !provider.hasProducts) {
                  return const LoadingWidget(message: 'Memuat produk...');
                }

                if (!provider.hasProducts) {
                  return EmptyProductWidget(
                    onAddProduct: () => Navigator.pushNamed(context, AppRoutes.addProduct),
                  );
                }

                // Filter by category
                final products = _selectedCategoryId == null
                    ? provider.products
                    : provider.products
                        .where((p) => p.categoryId == _selectedCategoryId)
                        .toList();

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Tidak ada produk di kategori ini', style: TextStyles.bodyMedium),
                      ],
                    ),
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
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(context, product, provider);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addProduct),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryFilter() {
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
          const Icon(Icons.filter_list, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _selectedCategoryId,
                  isExpanded: true,
                  hint: Text(
                    'Semua Kategori',
                    style: TextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Semua Kategori', style: TextStyles.bodyMedium),
                    ),
                    ..._categories.map((category) {
                      return DropdownMenuItem<String?>(
                        value: category.id,
                        child: Text(category.name, style: TextStyles.bodyMedium),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCategoryId = value);
                  },
                ),
              ),
            ),
          ),
          if (_selectedCategoryId != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _selectedCategoryId = null),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close, size: 16, color: AppColors.error),
              ),
            ),
          ],
        ],
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
    return const Center(
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
