import 'package:uuid/uuid.dart';
import '../../core/constants/db_constants.dart';
import '../database/database_helper.dart';
import '../models/notification_model.dart';

/// Repository for notification operations
class NotificationRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  static const _uuid = Uuid();

  /// Get all notifications for a user
  Future<List<NotificationModel>> getNotificationsByUserId(String userId) async {
    final results = await _db.query(
      DbConstants.tableNotifications,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return results.map((map) => NotificationModel.fromMap(map)).toList();
  }

  /// Get unread notification count for a user
  Future<int> getUnreadCount(String userId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DbConstants.tableNotifications} WHERE user_id = ? AND is_read = 0',
      [userId],
    );
    return result.first['count'] as int? ?? 0;
  }

  /// Create a new notification
  Future<NotificationModel> createNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    String? relatedId,
  }) async {
    final notification = NotificationModel(
      id: _uuid.v4(),
      userId: userId,
      type: type,
      title: title,
      message: message,
      relatedId: relatedId,
      isRead: false,
      createdAt: DateTime.now(),
    );

    await _db.insert(DbConstants.tableNotifications, notification.toMap());
    return notification;
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    await _db.update(
      DbConstants.tableNotifications,
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    await _db.update(
      DbConstants.tableNotifications,
      {'is_read': 1},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _db.delete(
      DbConstants.tableNotifications,
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  /// Delete all notifications for a user
  Future<void> deleteAllForUser(String userId) async {
    await _db.delete(
      DbConstants.tableNotifications,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
