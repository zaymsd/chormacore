import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stats_card_widget.dart';
import '../widgets/recent_orders_widget.dart';
import '../../products/pages/seller_product_list_page.dart';
import '../../orders/pages/seller_order_list_page.dart';
import '../../../notifications/providers/notification_provider.dart';

/// Seller dashboard page with statistics and recent orders
class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        Provider.of<DashboardProvider>(context, listen: false)
            .setSeller(authProvider.currentUser!.id);
        Provider.of<NotificationProvider>(context, listen: false)
            .loadNotifications(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildDashboardPage(),
            _buildProductsPage(),
            _buildOrdersPage(),
            _buildProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDashboardPage() {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<DashboardProvider>(context, listen: false).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<DashboardProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const SizedBox(
                      height: 200,
                      child: LoadingWidget(),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                        children: [
                          StatsCardWidget(
                            title: 'Total Produk',
                            value: '${provider.totalProducts}',
                            icon: Icons.inventory_2_outlined,
                            color: AppColors.primary,
                          ),
                          StatsCardWidget(
                            title: 'Total Pesanan',
                            value: '${provider.totalOrders}',
                            icon: Icons.shopping_bag_outlined,
                            color: AppColors.info,
                          ),
                          StatsCardWidget(
                            title: 'Pesanan Pending',
                            value: '${provider.pendingOrders}',
                            icon: Icons.pending_actions_outlined,
                            color: AppColors.warning,
                          ),
                          StatsCardWidget(
                            title: 'Pesanan Selesai',
                            value: '${provider.completedOrders}',
                            icon: Icons.check_circle_outline,
                            color: AppColors.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Revenue Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Pendapatan',
                              style: TextStyles.bodyMedium.copyWith(
                                color: AppColors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.format(provider.totalRevenue),
                              style: TextStyles.h3.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Recent Orders
                      RecentOrdersWidget(
                        orders: provider.recentOrders,
                        onViewAll: () {
                          setState(() => _currentIndex = 2);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
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
              _buildHeaderAvatar(user),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.getGreeting(),
                      style: TextStyles.caption,
                    ),
                    Text(
                      user?.name ?? 'Penjual',
                      style: TextStyles.h6,
                    ),
                  ],
                ),
              ),
              Consumer<NotificationProvider>(
                builder: (context, notifProvider, _) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.sellerNotifications);
                        },
                      ),
                      if (notifProvider.unreadCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              notifProvider.unreadCount > 99 
                                  ? '99+' 
                                  : '${notifProvider.unreadCount}',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductsPage() {
    // Use page with category filter
    return const SellerProductListPage();
  }

  Widget _buildOrdersPage() {
    // Use page with date filter
    return const SellerOrderListPage();
  }

  Widget _buildProfilePage() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 20),
            Center(
              child: _buildProfileAvatar(user),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🏪 Penjual',
                  style: TextStyles.labelMedium.copyWith(color: AppColors.secondary),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(user?.name ?? 'Penjual', style: TextStyles.h5),
            ),
            Center(
              child: Text(
                user?.email ?? '',
                style: TextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 32),
            _buildProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Edit Profil',
              onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
            ),
            _buildProfileMenuItem(
              icon: Icons.store_outlined,
              title: 'Pengaturan Toko',
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

  Widget _buildProfileAvatar(dynamic user) {
    ImageProvider? avatarImage;
    
    if (user?.avatar != null && user!.avatar.isNotEmpty) {
      final avatarPath = user.avatar as String;
      if (avatarPath.startsWith('http')) {
        avatarImage = NetworkImage(avatarPath);
      } else {
        final file = File(avatarPath);
        if (file.existsSync()) {
          avatarImage = FileImage(file);
        }
      }
    }
    
    return CircleAvatar(
      radius: 50,
      backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
      backgroundImage: avatarImage,
      child: avatarImage == null
          ? Text(
              user?.name?.isNotEmpty == true 
                  ? user!.name[0].toUpperCase() 
                  : 'S',
              style: TextStyles.h2.copyWith(color: AppColors.secondary),
            )
          : null,
    );
  }

  Widget _buildHeaderAvatar(dynamic user) {
    ImageProvider? avatarImage;
    
    if (user?.avatar != null && user!.avatar.isNotEmpty) {
      final avatarPath = user.avatar as String;
      if (avatarPath.startsWith('http')) {
        avatarImage = NetworkImage(avatarPath);
      } else {
        final file = File(avatarPath);
        if (file.existsSync()) {
          avatarImage = FileImage(file);
        }
      }
    }
    
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      backgroundImage: avatarImage,
      child: avatarImage == null
          ? Text(
              user?.name?.isNotEmpty == true 
                  ? user!.name[0].toUpperCase() 
                  : 'S',
              style: TextStyles.h5.copyWith(color: AppColors.primary),
            )
          : null,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            rippleColor: AppColors.primaryLight,
            hoverColor: AppColors.primaryLight.withOpacity(0.1),
            gap: 8,
            activeColor: AppColors.primary,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: AppColors.primaryLight.withOpacity(0.1),
            color: AppColors.textSecondary,
            tabs: const [
              GButton(
                icon: Icons.dashboard_outlined,
                text: 'Dashboard',
              ),
              GButton(
                icon: Icons.inventory_2_outlined,
                text: 'Produk',
              ),
              GButton(
                icon: Icons.receipt_long_outlined,
                text: 'Pesanan',
              ),
              GButton(
                icon: Icons.person_outline,
                text: 'Profil',
              ),
            ],
            selectedIndex: _currentIndex,
            onTabChange: (index) => setState(() => _currentIndex = index),
          ),
        ),
      ),
    );
  }
}
