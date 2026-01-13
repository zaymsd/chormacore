import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_item_widget.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/notification_model.dart';

/// Notification list page for buyer and seller
class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    final authProvider = context.read<AuthProvider>();
    final notifProvider = context.read<NotificationProvider>();
    
    if (authProvider.currentUser != null) {
      await notifProvider.loadNotifications(authProvider.currentUser!.id);
    }
  }

  void _onNotificationTap(NotificationModel notification) {
    final notifProvider = context.read<NotificationProvider>();
    
    // Mark as read
    if (!notification.isRead) {
      notifProvider.markAsRead(notification.id);
    }

    // Navigate based on notification type
    if (notification.relatedId != null) {
      final isSeller = context.read<AuthProvider>().currentUser?.role == 'seller';
      
      if (notification.type == NotificationType.newOrder ||
          notification.type == NotificationType.orderConfirmed ||
          notification.type == NotificationType.orderShipped ||
          notification.type == NotificationType.orderDelivered ||
          notification.type == NotificationType.orderCancelled) {
        // Navigate to order detail
        final route = isSeller
            ? AppRoutes.getSellerOrderDetailRoute(notification.relatedId!)
            : AppRoutes.getBuyerOrderDetailRoute(notification.relatedId!);
        Navigator.pushNamed(context, route);
      } else if (notification.type == NotificationType.newReview) {
        // Navigate to product detail for seller
        if (isSeller) {
          Navigator.pushNamed(
            context,
            AppRoutes.getSellerProductDetailRoute(notification.relatedId!),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount > 0) {
                return TextButton(
                  onPressed: provider.markAllAsRead,
                  child: Text(
                    'Tandai Dibaca',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return ErrorStateWidget(
              message: provider.error,
              onRetry: _loadNotifications,
            );
          }

          if (!provider.hasNotifications) {
            return const EmptyStateWidget(
              title: 'Tidak Ada Notifikasi',
              description: 'Notifikasi Anda akan muncul di sini.',
              icon: Icons.notifications_none_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.notifications.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: theme.dividerColor.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return NotificationItemWidget(
                  notification: notification,
                  onTap: () => _onNotificationTap(notification),
                  onDelete: () => provider.deleteNotification(notification.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
