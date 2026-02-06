/// Application-wide constants for the marketplace app
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'ChormaCore';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Toko Komputer & Aksesoris Terlengkap';

  // User Roles
  static const String roleBuyer = 'buyer';
  static const String roleSeller = 'seller';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxProductImages = 5;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  // Order Status
  static const String orderStatusPending = 'pending';
  static const String orderStatusProcessing = 'processing';
  static const String orderStatusShipped = 'shipped';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';

  // Payment Methods
  static const String paymentCOD = 'cod';
  static const String paymentTransfer = 'transfer';
  static const String paymentEwallet = 'ewallet';

  // Shared Preferences Keys
  static const String prefKeyUser = 'current_user';
  static const String prefKeyTheme = 'app_theme';
  static const String prefKeyOnboarded = 'is_onboarded';
}
