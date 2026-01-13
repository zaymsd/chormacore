import 'package:flutter/material.dart';

/// Application route names and configuration
class AppRoutes {
  AppRoutes._();

  // Auth Routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String editProfile = '/edit-profile';
  static const String guestBrowse = '/guest/browse';

  // Buyer Routes
  static const String buyerHome = '/buyer/home';
  static const String productDetail = '/buyer/product/:id';
  static const String cart = '/buyer/cart';
  static const String checkout = '/buyer/checkout';
  static const String addressSelection = '/buyer/address-selection';
  static const String buyerOrders = '/buyer/orders';
  static const String buyerOrderDetail = '/buyer/orders/:id';
  static const String wishlist = '/buyer/wishlist';
  static const String buyerProfile = '/buyer/profile';

  // Seller Routes
  static const String sellerDashboard = '/seller/dashboard';
  static const String sellerProducts = '/seller/products';
  static const String addProduct = '/seller/products/add';
  static const String editProduct = '/seller/products/edit/:id';
  static const String sellerOrders = '/seller/orders';
  static const String sellerOrderDetail = '/seller/orders/:id';
  static const String sellerProfile = '/seller/profile';
  static const String sellerProductDetail = '/seller/product/:id';

  // Review Routes
  static const String addReview = '/buyer/orders/:orderId/review/:productId';

  // Notification Routes
  static const String buyerNotifications = '/buyer/notifications';
  static const String sellerNotifications = '/seller/notifications';

  // Search
  static const String search = '/search';

  /// Helper method to get product detail route with ID
  static String getProductDetailRoute(String productId) {
    return '/buyer/product/$productId';
  }

  /// Helper method to get order detail route with ID
  static String getBuyerOrderDetailRoute(String orderId) {
    return '/buyer/orders/$orderId';
  }
  
  /// Alias for getBuyerOrderDetailRoute
  static String getOrderDetailRoute(String orderId) => getBuyerOrderDetailRoute(orderId);

  /// Helper method to get seller order detail route with ID
  static String getSellerOrderDetailRoute(String orderId) {
    return '/seller/orders/$orderId';
  }

  /// Helper method to get edit product route with ID
  static String getEditProductRoute(String productId) {
    return '/seller/products/edit/$productId';
  }

  /// Helper method to get add review route
  static String getAddReviewRoute(String orderId, String productId) {
    return '/buyer/orders/$orderId/review/$productId';
  }

  /// Helper method to get seller product detail route
  static String getSellerProductDetailRoute(String productId) {
    return '/seller/product/$productId';
  }

  /// Extract ID from route
  static String? extractId(String route) {
    final segments = route.split('/');
    if (segments.isNotEmpty) {
      return segments.last;
    }
    return null;
  }

  /// Generate route with query parameters
  static String withQuery(String route, Map<String, String> params) {
    if (params.isEmpty) return route;
    
    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$route?$queryString';
  }

  /// Custom page transition
  static PageRouteBuilder<T> fadeTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Slide transition from right
  static PageRouteBuilder<T> slideTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
