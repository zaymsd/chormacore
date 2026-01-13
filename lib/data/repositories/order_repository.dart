import 'package:uuid/uuid.dart';
import '../../core/constants/db_constants.dart';
import '../../core/constants/app_constants.dart';
import '../database/database_helper.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../models/notification_model.dart';
import 'notification_repository.dart';

/// Repository for order-related database operations
class OrderRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();
  final NotificationRepository _notificationRepository = NotificationRepository();

  /// Create order from cart items
  Future<OrderModel> createOrder({
    required String userId,
    required String sellerId,
    required List<CartModel> cartItems,
    required String address,
    required String paymentMethod,
    String? notes,
  }) async {
    final orderId = _uuid.v4();
    final now = DateTime.now();

    // Calculate total
    double total = 0;
    for (var item in cartItems) {
      total += (item.product?.price ?? 0) * item.quantity;
    }

    // Create order
    final order = OrderModel(
      id: orderId,
      userId: userId,
      sellerId: sellerId,
      total: total,
      status: AppConstants.orderStatusPending,
      address: address,
      paymentMethod: paymentMethod,
      notes: notes,
      createdAt: now,
    );

    await _db.insert(DbConstants.tableOrders, order.toMap());

    // Create order items
    List<OrderItemModel> orderItems = [];
    for (var item in cartItems) {
      if (item.product != null) {
        final orderItem = OrderItemModel(
          id: _uuid.v4(),
          orderId: orderId,
          productId: item.productId,
          productName: item.product!.name,
          productImage: item.product!.firstImage,
          quantity: item.quantity,
          price: item.product!.price,
          subtotal: item.product!.price * item.quantity,
        );
        await _db.insert(DbConstants.tableOrderItems, orderItem.toMap());
        orderItems.add(orderItem);
      }
    }

    // Create notification for seller about new order
    await _notificationRepository.createNotification(
      userId: sellerId,
      type: NotificationType.newOrder,
      title: 'Pesanan Baru',
      message: 'Anda menerima pesanan baru dari pembeli',
      relatedId: orderId,
    );

    return order.copyWith(items: orderItems);
  }

  /// Get order by ID with items
  Future<OrderModel?> getOrderById(String id) async {
    final orderResults = await _db.rawQuery('''
      SELECT o.*, 
             buyer.name as buyer_name,
             seller.name as seller_name
      FROM ${DbConstants.tableOrders} o
      LEFT JOIN ${DbConstants.tableUsers} buyer ON o.user_id = buyer.id
      LEFT JOIN ${DbConstants.tableUsers} seller ON o.seller_id = seller.id
      WHERE o.id = ?
    ''', [id]);

    if (orderResults.isEmpty) return null;

    // Get order items
    final itemResults = await _db.query(
      DbConstants.tableOrderItems,
      where: 'order_id = ?',
      whereArgs: [id],
    );

    final items = itemResults.map((m) => OrderItemModel.fromMap(m)).toList();
    return OrderModel.fromMap(orderResults.first, items: items);
  }

  /// Get orders by buyer
  Future<List<OrderModel>> getOrdersByBuyer(String userId) async {
    final results = await _db.rawQuery('''
      SELECT o.*, seller.name as seller_name
      FROM ${DbConstants.tableOrders} o
      LEFT JOIN ${DbConstants.tableUsers} seller ON o.seller_id = seller.id
      WHERE o.user_id = ?
      ORDER BY o.created_at DESC
    ''', [userId]);

    List<OrderModel> orders = [];
    for (var map in results) {
      final itemResults = await _db.query(
        DbConstants.tableOrderItems,
        where: 'order_id = ?',
        whereArgs: [map['id']],
      );
      final items = itemResults.map((m) => OrderItemModel.fromMap(m)).toList();
      orders.add(OrderModel.fromMap(map, items: items));
    }

    return orders;
  }

  /// Get orders by seller
  Future<List<OrderModel>> getOrdersBySeller(String sellerId) async {
    final results = await _db.rawQuery('''
      SELECT o.*, buyer.name as buyer_name
      FROM ${DbConstants.tableOrders} o
      LEFT JOIN ${DbConstants.tableUsers} buyer ON o.user_id = buyer.id
      WHERE o.seller_id = ?
      ORDER BY o.created_at DESC
    ''', [sellerId]);

    List<OrderModel> orders = [];
    for (var map in results) {
      final itemResults = await _db.query(
        DbConstants.tableOrderItems,
        where: 'order_id = ?',
        whereArgs: [map['id']],
      );
      final items = itemResults.map((m) => OrderItemModel.fromMap(m)).toList();
      orders.add(OrderModel.fromMap(map, items: items));
    }

    return orders;
  }

  /// Get orders by status
  Future<List<OrderModel>> getOrdersByStatus(String sellerId, String status) async {
    final results = await _db.rawQuery('''
      SELECT o.*, buyer.name as buyer_name
      FROM ${DbConstants.tableOrders} o
      LEFT JOIN ${DbConstants.tableUsers} buyer ON o.user_id = buyer.id
      WHERE o.seller_id = ? AND o.status = ?
      ORDER BY o.created_at DESC
    ''', [sellerId, status]);

    return results.map((map) => OrderModel.fromMap(map)).toList();
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    // Get order to find buyer ID
    final order = await getOrderById(orderId);
    
    final result = await _db.update(
      DbConstants.tableOrders,
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
    
    // Create notification for buyer about status change
    if (result > 0 && order != null) {
      String notifType;
      String notifTitle;
      String notifMessage;
      
      switch (status) {
        case AppConstants.orderStatusProcessing:
          notifType = NotificationType.orderConfirmed;
          notifTitle = 'Pesanan Dikonfirmasi';
          notifMessage = 'Pesanan Anda sedang diproses oleh penjual';
          break;
        case AppConstants.orderStatusShipped:
          notifType = NotificationType.orderShipped;
          notifTitle = 'Pesanan Dikirim';
          notifMessage = 'Pesanan Anda sedang dalam pengiriman';
          break;
        case AppConstants.orderStatusDelivered:
          notifType = NotificationType.orderDelivered;
          notifTitle = 'Pesanan Selesai';
          notifMessage = 'Pesanan Anda telah sampai. Terima kasih telah berbelanja!';
          break;
        case AppConstants.orderStatusCancelled:
          notifType = NotificationType.orderCancelled;
          notifTitle = 'Pesanan Dibatalkan';
          notifMessage = 'Pesanan Anda telah dibatalkan';
          break;
        default:
          notifType = '';
          notifTitle = '';
          notifMessage = '';
      }
      
      if (notifType.isNotEmpty) {
        await _notificationRepository.createNotification(
          userId: order.userId,
          type: notifType,
          title: notifTitle,
          message: notifMessage,
          relatedId: orderId,
        );
      }
    }
    
    return result > 0;
  }

  /// Cancel order
  Future<bool> cancelOrder(String orderId) async {
    return await updateOrderStatus(orderId, AppConstants.orderStatusCancelled);
  }

  /// Get order count by seller
  Future<int> getOrderCountBySeller(String sellerId) async {
    return await _db.count(
      DbConstants.tableOrders,
      where: 'seller_id = ?',
      whereArgs: [sellerId],
    );
  }

  /// Get order count by status for seller
  Future<int> getOrderCountByStatus(String sellerId, String status) async {
    return await _db.count(
      DbConstants.tableOrders,
      where: 'seller_id = ? AND status = ?',
      whereArgs: [sellerId, status],
    );
  }

  /// Get total revenue for seller
  Future<double> getTotalRevenue(String sellerId) async {
    final results = await _db.rawQuery('''
      SELECT SUM(total) as revenue
      FROM ${DbConstants.tableOrders}
      WHERE seller_id = ? AND status = ?
    ''', [sellerId, AppConstants.orderStatusDelivered]);

    if (results.isNotEmpty && results.first['revenue'] != null) {
      return (results.first['revenue'] as num).toDouble();
    }
    return 0;
  }

  /// Get recent orders for seller
  Future<List<OrderModel>> getRecentOrders(String sellerId, {int limit = 5}) async {
    final results = await _db.rawQuery('''
      SELECT o.*, buyer.name as buyer_name
      FROM ${DbConstants.tableOrders} o
      LEFT JOIN ${DbConstants.tableUsers} buyer ON o.user_id = buyer.id
      WHERE o.seller_id = ?
      ORDER BY o.created_at DESC
      LIMIT ?
    ''', [sellerId, limit]);

    return results.map((map) => OrderModel.fromMap(map)).toList();
  }
}
