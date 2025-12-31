import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/text_styles.dart';
import 'custom_button.dart';

/// Empty state widget for displaying when there's no data
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.buttonText,
    this.onButtonPressed,
    this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize + 40,
              height: iconSize + 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyles.h5,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: buttonText!,
                onPressed: onButtonPressed,
                isFullWidth: false,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty cart state
class EmptyCartWidget extends StatelessWidget {
  final VoidCallback? onStartShopping;

  const EmptyCartWidget({
    super.key,
    this.onStartShopping,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Keranjang Kosong',
      description: 'Tidak ada produk di keranjang belanja Anda.\nMulai berbelanja sekarang!',
      icon: Icons.shopping_cart_outlined,
      buttonText: 'Mulai Belanja',
      onButtonPressed: onStartShopping,
    );
  }
}

/// Empty wishlist state
class EmptyWishlistWidget extends StatelessWidget {
  final VoidCallback? onExplore;

  const EmptyWishlistWidget({
    super.key,
    this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Wishlist Kosong',
      description: 'Belum ada produk di wishlist Anda.\nSimpan produk favorit Anda di sini!',
      icon: Icons.favorite_border,
      buttonText: 'Jelajahi Produk',
      onButtonPressed: onExplore,
    );
  }
}

/// Empty orders state
class EmptyOrdersWidget extends StatelessWidget {
  final VoidCallback? onStartShopping;

  const EmptyOrdersWidget({
    super.key,
    this.onStartShopping,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Belum Ada Pesanan',
      description: 'Anda belum memiliki pesanan.\nMulai berbelanja untuk melihat pesanan Anda di sini.',
      icon: Icons.receipt_long_outlined,
      buttonText: 'Mulai Belanja',
      onButtonPressed: onStartShopping,
    );
  }
}

/// Empty products state for seller
class EmptyProductsWidget extends StatelessWidget {
  final VoidCallback? onAddProduct;

  const EmptyProductsWidget({
    super.key,
    this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Belum Ada Produk',
      description: 'Anda belum menambahkan produk.\nMulai jualan dengan menambahkan produk pertama Anda!',
      icon: Icons.inventory_2_outlined,
      buttonText: 'Tambah Produk',
      onButtonPressed: onAddProduct,
    );
  }
}

/// Alias for EmptyProductsWidget with different parameter name
class EmptyProductWidget extends StatelessWidget {
  final VoidCallback? onAddProduct;

  const EmptyProductWidget({
    super.key,
    this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyProductsWidget(onAddProduct: onAddProduct);
  }
}

/// Alias for EmptyOrdersWidget with different parameter name
class EmptyOrderWidget extends StatelessWidget {
  final VoidCallback? onBrowse;

  const EmptyOrderWidget({
    super.key,
    this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyOrdersWidget(onStartShopping: onBrowse);
  }
}

/// Search empty state
class EmptySearchWidget extends StatelessWidget {
  final String query;

  const EmptySearchWidget({
    super.key,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Tidak Ditemukan',
      description: 'Tidak ada hasil untuk "$query".\nCoba gunakan kata kunci lain.',
      icon: Icons.search_off,
    );
  }
}

/// Error state widget
class ErrorStateWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Terjadi Kesalahan',
              style: TextStyles.h5,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: 'Coba Lagi',
                onPressed: onRetry,
                isFullWidth: false,
                width: 160,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
