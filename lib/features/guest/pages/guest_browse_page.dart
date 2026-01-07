import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/routes/app_routes.dart';
import '../../buyer/home/providers/product_list_provider.dart';
import '../../buyer/home/widgets/product_card_widget.dart';
import '../../buyer/home/widgets/category_chip_widget.dart';
import '../../buyer/home/widgets/search_bar_widget.dart';

/// Guest browse page for lazy login - allows browsing products without authentication
class GuestBrowsePage extends StatefulWidget {
  const GuestBrowsePage({super.key});

  @override
  State<GuestBrowsePage> createState() => _GuestBrowsePageState();
}

class _GuestBrowsePageState extends State<GuestBrowsePage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductListProvider>(context, listen: false).loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Provider.of<ProductListProvider>(context, listen: false).refresh();
          },
          child: CustomScrollView(
            slivers: [
              // Header with Login/Register buttons
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),
              
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SearchBarWidget(
                    controller: _searchController,
                    onChanged: (query) {
                      Provider.of<ProductListProvider>(context, listen: false)
                          .search(query);
                    },
                  ),
                ),
              ),
              
              // Categories
              SliverToBoxAdapter(
                child: Consumer<ProductListProvider>(
                  builder: (context, provider, _) {
                    if (provider.categories.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CategoryListWidget(
                        categories: provider.categories,
                        selectedCategoryId: provider.selectedCategoryId,
                        onCategorySelected: provider.filterByCategory,
                      ),
                    );
                  },
                ),
              ),
              
              // Products Grid
              Consumer<ProductListProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.products.isEmpty) {
                    return const SliverFillRemaining(
                      child: LoadingWidget(message: 'Memuat produk...'),
                    );
                  }

                  if (provider.error != null && provider.products.isEmpty) {
                    return SliverFillRemaining(
                      child: ErrorStateWidget(
                        message: provider.error,
                        onRetry: provider.refresh,
                      ),
                    );
                  }

                  if (!provider.hasProducts) {
                    return SliverFillRemaining(
                      child: EmptySearchWidget(
                        query: provider.searchQuery.isNotEmpty 
                            ? provider.searchQuery 
                            : 'produk',
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = provider.products[index];
                          return ProductCardWidget(
                            product: product,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.getProductDetailRoute(product.id),
                              );
                            },
                            onFavoritePressed: () {
                              _showLoginPrompt(context);
                            },
                          );
                        },
                        childCount: provider.products.length,
                      ),
                    ),
                  );
                },
              ),
              
              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
            ],
          ),
        ),
      ),
      // No bottom navigation bar for guest mode
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // App title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Klik, Bayar, Sampai!',
                      style: TextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ChormaCore',
                      style: TextStyles.h5.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Login button
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(width: 8),
              // Register button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.register);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Register'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Diperlukan'),
        content: const Text(
          'Untuk menambahkan produk ke wishlist, Anda perlu login terlebih dahulu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nanti'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.login);
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
