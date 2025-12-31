/// API-related constants (for future API integration)
class ApiConstants {
  ApiConstants._();

  // Base URL (placeholder for future API)
  static const String baseUrl = 'https://api.chromacore.com/v1';
  
  // Endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authLogout = '/auth/logout';
  
  static const String users = '/users';
  static const String products = '/products';
  static const String categories = '/categories';
  static const String orders = '/orders';
  static const String cart = '/cart';
  static const String wishlist = '/wishlist';
  static const String reviews = '/reviews';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
