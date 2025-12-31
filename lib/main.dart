import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';

// Conditional import for database
import 'core/utils/platform_helper.dart'
    if (dart.library.html) 'core/utils/platform_helper_web.dart';

// Providers
import 'features/auth/providers/auth_provider.dart';
import 'features/buyer/home/providers/product_list_provider.dart';
import 'features/buyer/cart/providers/cart_provider.dart';
import 'features/buyer/checkout/providers/checkout_provider.dart';
import 'features/buyer/orders/providers/order_provider.dart';
import 'features/buyer/wishlist/providers/wishlist_provider.dart';
import 'features/seller/dashboard/providers/dashboard_provider.dart';
import 'features/seller/products/providers/product_management_provider.dart';
import 'features/seller/orders/providers/seller_order_provider.dart';

// Pages
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/register_page.dart';
import 'features/auth/pages/edit_profile_page.dart';
import 'features/buyer/home/pages/buyer_home_page.dart';
import 'features/buyer/cart/pages/cart_page.dart';
import 'features/buyer/checkout/pages/checkout_page.dart';
import 'features/buyer/orders/pages/order_list_page.dart';
import 'features/buyer/orders/pages/order_detail_page.dart';
import 'features/buyer/wishlist/pages/wishlist_page.dart';
import 'features/seller/dashboard/pages/seller_dashboard_page.dart';
import 'features/seller/products/pages/seller_product_list_page.dart';
import 'features/seller/products/pages/add_edit_product_page.dart';
import 'features/seller/orders/pages/seller_order_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database for desktop platforms only
  if (!kIsWeb) {
    await initializeDatabaseFactory();
  }

  runApp(const ChromaCoreApp());
}

class ChromaCoreApp extends StatelessWidget {
  const ChromaCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductListProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProductManagementProvider()),
        ChangeNotifierProvider(create: (_) => SellerOrderProvider()),
      ],
      child: MaterialApp(
        title: 'TechZone - Komputer & Aksesoris',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
          useMaterial3: true,
        ),
        home: const LoginPage(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.login:
              return MaterialPageRoute(builder: (_) => const LoginPage());
            case AppRoutes.register:
              return MaterialPageRoute(builder: (_) => const RegisterPage());
            case AppRoutes.editProfile:
              return MaterialPageRoute(builder: (_) => const EditProfilePage());
            case AppRoutes.buyerHome:
              return MaterialPageRoute(builder: (_) => const BuyerHomePage());
            case AppRoutes.cart:
              return MaterialPageRoute(builder: (_) => const CartPage());
            case AppRoutes.checkout:
              return MaterialPageRoute(builder: (_) => const CheckoutPage());
            case AppRoutes.buyerOrders:
              return MaterialPageRoute(builder: (_) => const OrderListPage());
            case AppRoutes.wishlist:
              return MaterialPageRoute(builder: (_) => const WishlistPage());
            case AppRoutes.sellerDashboard:
              return MaterialPageRoute(builder: (_) => const SellerDashboardPage());
            case AppRoutes.sellerProducts:
              return MaterialPageRoute(builder: (_) => const SellerProductListPage());
            case AppRoutes.addProduct:
              return MaterialPageRoute(builder: (_) => const AddEditProductPage());
            case AppRoutes.sellerOrders:
              return MaterialPageRoute(builder: (_) => const SellerOrderListPage());
            default:
              final uri = Uri.parse(settings.name ?? '');
              final pathSegments = uri.pathSegments;
              
              if (pathSegments.length >= 3) {
                final section = pathSegments[0];
                final type = pathSegments[1];
                
                if (section == 'buyer' && type == 'orders' && pathSegments.length > 2) {
                  return MaterialPageRoute(
                    builder: (_) => OrderDetailPage(orderId: pathSegments[2]),
                  );
                }
                if (section == 'seller' && type == 'products' && 
                    pathSegments.length >= 4 && pathSegments[2] == 'edit') {
                  return MaterialPageRoute(
                    builder: (_) => AddEditProductPage(productId: pathSegments[3]),
                  );
                }
              }
              return MaterialPageRoute(builder: (_) => const LoginPage());
          }
        },
      ),
    );
  }
}
