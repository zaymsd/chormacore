---
description: How to implement notification feature for seller and buyer
---

# Notification Feature Implementation Workflow

Workflow untuk mengimplementasikan fitur notifikasi di ChormaCore app.

## Step 1: Buat Notification Model

Buat file `lib/data/models/notification_model.dart` dengan fields:
- id, userId, type, title, message, relatedId, isRead, createdAt

## Step 2: Buat Notification Table

Buat file `lib/data/database/tables/notification_table.dart` dengan SQL schema.

## Step 3: Update Database Constants

Edit `lib/core/constants/db_constants.dart`:
- Tambah `tableNotifications = 'notifications'`
- Update `databaseVersion` ke 2

## Step 4: Update Database Helper

Edit `lib/data/database/database_helper.dart`:
- Tambah migration di `_upgradeDB` untuk membuat tabel notifications
- Tambah delete notifications di `deleteAllData`

## Step 5: Buat Notification Repository

Buat file `lib/data/repositories/notification_repository.dart` dengan methods:
- getNotificationsByUserId, getUnreadCount, createNotification, markAsRead, markAllAsRead

## Step 6: Buat Notification Provider

Buat folder `lib/features/notifications/providers/` dan file `notification_provider.dart`.

## Step 7: Buat Notification UI

Buat files:
- `lib/features/notifications/pages/notification_list_page.dart`
- `lib/features/notifications/widgets/notification_item_widget.dart`

## Step 8: Update Routes

Edit `lib/core/routes/app_routes.dart`:
- Tambah `buyerNotifications` dan `sellerNotifications` routes

## Step 9: Register Provider dan Routes

Edit `lib/main.dart`:
- Tambah NotificationProvider di MultiProvider
- Tambah route handlers

## Step 10: Tambah Badge Icon

Edit buyer home page dan seller dashboard page:
- Tambah IconButton dengan badge di AppBar

## Step 11: Trigger Notifikasi

Edit `order_repository.dart` dan `review_repository.dart`:
- Panggil NotificationRepository saat order dibuat atau status berubah

// turbo
## Step 12: Test dengan Hot Restart

```powershell
flutter run
```

Pastikan test flow:
1. Login buyer → buat order → cek notif seller
2. Login seller → update status → cek notif buyer
