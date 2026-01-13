import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';
import 'package:intl/intl.dart';

/// Widget for displaying a single notification item
class NotificationItemWidget extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        color: isRead ? null : theme.colorScheme.primary.withValues(alpha: 0.05),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: isRead
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.primary.withValues(alpha: 0.15),
            child: Icon(
              _getIcon(),
              color: isRead
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(notification.createdAt),
                style: TextStyle(
                  color: theme.colorScheme.outline,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: !isRead
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.orderConfirmed:
        return Icons.check_circle_outline;
      case NotificationType.orderShipped:
        return Icons.local_shipping_outlined;
      case NotificationType.orderDelivered:
        return Icons.inventory_2_outlined;
      case NotificationType.orderCancelled:
        return Icons.cancel_outlined;
      case NotificationType.newOrder:
        return Icons.shopping_bag_outlined;
      case NotificationType.newReview:
        return Icons.star_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return DateFormat('dd MMM yyyy', 'id_ID').format(dateTime);
    }
  }
}
