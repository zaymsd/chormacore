/// Database constants for SQLite
class DbConstants {
  DbConstants._();

  // Database Info
  static const String databaseName = 'chromacore_marketplace.db';
  static const int databaseVersion = 1;

  // Table Names
  static const String tableUsers = 'users';
  static const String tableCategories = 'categories';
  static const String tableProducts = 'products';
  static const String tableCart = 'cart';
  static const String tableOrders = 'orders';
  static const String tableOrderItems = 'order_items';
  static const String tableWishlist = 'wishlist';
  static const String tableReviews = 'reviews';

  // Common Column Names
  static const String columnId = 'id';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
}
