import 'package:flutter/foundation.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';

/// Provider for managing notifications state
class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNotifications => _notifications.isNotEmpty;

  /// Load notifications for a user
  Future<void> loadNotifications(String userId) async {
    if (_isLoading) return;

    _currentUserId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _repository.getNotificationsByUserId(userId);
      _unreadCount = await _repository.getUnreadCount(userId);
      _error = null;
    } catch (e) {
      _error = 'Gagal memuat notifikasi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh notifications
  Future<void> refresh() async {
    if (_currentUserId == null) return;
    await loadNotifications(_currentUserId!);
  }

  /// Update unread count only
  Future<void> updateUnreadCount(String userId) async {
    try {
      _unreadCount = await _repository.getUnreadCount(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating unread count: $e');
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Gagal menandai sudah dibaca: $e';
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    try {
      await _repository.markAllAsRead(_currentUserId!);
      
      // Update local state
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = 'Gagal menandai semua sudah dibaca: $e';
      notifyListeners();
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final notification = _notifications.firstWhere((n) => n.id == notificationId);
      await _repository.deleteNotification(notificationId);
      
      // Update local state
      _notifications.removeWhere((n) => n.id == notificationId);
      if (!notification.isRead) {
        _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
      }
      notifyListeners();
    } catch (e) {
      _error = 'Gagal menghapus notifikasi: $e';
      notifyListeners();
    }
  }

  /// Clear all data
  void clear() {
    _notifications = [];
    _unreadCount = 0;
    _isLoading = false;
    _error = null;
    _currentUserId = null;
    notifyListeners();
  }
}
