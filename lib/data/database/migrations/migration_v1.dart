import 'package:sqflite/sqflite.dart';
import '../../../core/constants/db_constants.dart';
import '../tables/user_table.dart';
import '../tables/category_table.dart';
import '../tables/product_table.dart';
import '../tables/cart_table.dart';
import '../tables/order_table.dart';
import '../tables/order_item_table.dart';
import '../tables/wishlist_table.dart';
import '../tables/review_table.dart';

/// Database migration for version 1
class MigrationV1 {
  /// Create all tables
  static Future<void> createTables(Database db) async {
    // Create tables in order of dependencies
    await db.execute(UserTable.createTableQuery);
    await db.execute(CategoryTable.createTableQuery);
    await db.execute(ProductTable.createTableQuery);
    await db.execute(CartTable.createTableQuery);
    await db.execute(OrderTable.createTableQuery);
    await db.execute(OrderItemTable.createTableQuery);
    await db.execute(WishlistTable.createTableQuery);
    await db.execute(ReviewTable.createTableQuery);
  }

  /// Seed initial data (categories)
  static Future<void> seedData(Database db) async {
    // Insert default categories for Computer & Accessories store
    final categories = [
      {
        'id': 'cat_001',
        'name': 'Laptop',
        'icon': 'laptop',
        'description': 'Laptop gaming, ultrabook, dan notebook untuk kerja',
      },
      {
        'id': 'cat_002',
        'name': 'PC Desktop',
        'icon': 'desktop_windows',
        'description': 'PC rakitan, PC built-up, dan mini PC',
      },
      {
        'id': 'cat_003',
        'name': 'Komponen PC',
        'icon': 'memory',
        'description': 'Processor, RAM, VGA, Motherboard, PSU, Casing',
      },
      {
        'id': 'cat_004',
        'name': 'Storage',
        'icon': 'storage',
        'description': 'SSD, HDD, NVMe, dan External Drive',
      },
      {
        'id': 'cat_005',
        'name': 'Monitor',
        'icon': 'monitor',
        'description': 'Monitor gaming, monitor kerja, dan monitor 4K',
      },
      {
        'id': 'cat_006',
        'name': 'Keyboard & Mouse',
        'icon': 'keyboard',
        'description': 'Keyboard mechanical, mouse gaming, dan mousepad',
      },
      {
        'id': 'cat_007',
        'name': 'Audio',
        'icon': 'headphones',
        'description': 'Headset gaming, speaker, soundcard, dan microphone',
      },
      {
        'id': 'cat_008',
        'name': 'Networking',
        'icon': 'router',
        'description': 'Router, switch, kabel LAN, dan aksesoris jaringan',
      },
      {
        'id': 'cat_009',
        'name': 'Aksesoris',
        'icon': 'usb',
        'description': 'USB Hub, webcam, cooling pad, dan aksesoris lainnya',
      },
      {
        'id': 'cat_010',
        'name': 'Printer & Scanner',
        'icon': 'print',
        'description': 'Printer inkjet, laserjet, scanner, dan supplies',
      },
    ];

    for (var category in categories) {
      await db.insert(DbConstants.tableCategories, category);
    }
  }
}
