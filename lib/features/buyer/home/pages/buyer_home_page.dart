import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../../orders/providers/order_provider.dart';
import '../providers/product_list_provider.dart';
import '../widgets/product_card_widget.dart';
import '../widgets/category_chip_widget.dart';
import '../widgets/search_bar_widget.dart';

/// Buyer home page with product listing
class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({super.key});

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  final _searchController = TextEditingController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductListProvider>(context, listen: false).loadData();
      
      // Initialize wishlist and orders
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        Provider.of<WishlistProvider>(context, listen: false)
            .setUser(authProvider.currentUser!.id);
        Provider.of<OrderProvider>(context, listen: false)
            .loadBuyerOrders(authProvider.currentUser!.id);
      }
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
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomePage(),
            _buildWishlistPage(),
            _buildOrdersPage(),
            _buildProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomePage() {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<ProductListProvider>(context, listen: false).refresh();
      },
      child: CustomScrollView(
        slivers: [
          // App Bar
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
                          // TODO: Toggle wishlist
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
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormatter.getGreeting(),
                          style: TextStyles.bodyMedium.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.name ?? 'Pengguna',
                          style: TextStyles.h5.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Cart icon
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.cart);
                    },
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.white,
                    ),
                  ),
                  // Notification icon
                  IconButton(
                    onPressed: () {
                      // TODO: Open notifications
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWishlistPage() {
    return Consumer<WishlistProvider>(
      builder: (context, wishlist, _) {
        if (wishlist.isLoading && wishlist.isEmpty) {
          return const LoadingWidget(message: 'Memuat wishlist...');
        }

        if (wishlist.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Wishlist Kosong', style: TextStyles.h5),
                const SizedBox(height: 8),
                Text(
                  'Produk favorit Anda akan muncul di sini',
                  style: TextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
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
              final item = wishlist.items[index];
              final product = item.product;
              if (product == null) {
                return const SizedBox.shrink();
              }
              return ProductCardWidget(
                product: product,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.getProductDetailRoute(item.productId),
                  );
                },
                onFavoritePressed: () {
                  wishlist.toggleWishlist(item.productId);
                },
                isFavorite: true,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOrdersPage() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
          return const LoadingWidget(message: 'Memuat pesanan...');
        }

        if (orderProvider.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Belum Ada Pesanan', style: TextStyles.h5),
                const SizedBox(height: 8),
                Text(
                  'Pesanan Anda akan muncul di sini',
                  style: TextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: orderProvider.refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
              return _buildOrderCard(order);
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(dynamic order) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.toString().substring(0, 8).toUpperCase()}',
                  style: TextStyles.labelMedium,
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${CurrencyFormatter.format(order.total)}',
              style: TextStyles.priceMedium,
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
      default:
        bgColor = AppColors.surfaceVariant;
        textColor = AppColors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyles.caption.copyWith(color: textColor)),
    );
  }

  Widget _buildProfilePage() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 20),
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  user?.name.isNotEmpty == true 
                      ? user!.name[0].toUpperCase() 
                      : '?',
                  style: TextStyles.h2.copyWith(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Name
            Center(
              child: Text(
                user?.name ?? 'Pengguna',
                style: TextStyles.h5,
              ),
            ),
            Center(
              child: Text(
                user?.email ?? '',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Menu items
            _buildProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Edit Profil',
              onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
            ),
            _buildProfileMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Alamat Pengiriman',
              onTap: () {},
            ),
            _buildProfileMenuItem(
              icon: Icons.settings_outlined,
              title: 'Pengaturan',
              onTap: () {},
            ),
            _buildProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Bantuan',
              onTap: () {},
            ),
            const Divider(height: 32),
            _buildProfileMenuItem(
              icon: Icons.logout,
              title: 'Keluar',
              isDestructive: true,
              onTap: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyles.bodyMedium.copyWith(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Pesanan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
