import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/cart_model.dart';

/// Cart item widget displaying product in cart
class CartItemWidget extends StatelessWidget {
  final CartModel cartItem;
  final VoidCallback? onRemove;
  final Function(int)? onQuantityChanged;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    this.onRemove,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final product = cartItem.product;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: AppColors.surfaceVariant,
              child: product?.firstImage != null
                  ? Image.network(
                      product!.firstImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_outlined,
                        color: AppColors.textHint,
                      ),
                    )
                  : const Icon(
                      Icons.image_outlined,
                      color: AppColors.textHint,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product?.name ?? 'Produk',
                  style: TextStyles.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(product?.price ?? 0),
                  style: TextStyles.priceNormal,
                ),
                const SizedBox(height: 8),
                
                // Quantity Controls
                Row(
                  children: [
                    _buildQuantityButton(
                      icon: Icons.remove,
                      onPressed: cartItem.quantity > 1
                          ? () => onQuantityChanged?.call(cartItem.quantity - 1)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${cartItem.quantity}',
                        style: TextStyles.labelLarge,
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Icons.add,
                      onPressed: () => onQuantityChanged?.call(cartItem.quantity + 1),
                    ),
                    const Spacer(),
                    // Subtotal
                    Text(
                      CurrencyFormatter.format(cartItem.subtotal),
                      style: TextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Remove button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: onPressed != null 
              ? AppColors.surfaceVariant 
              : AppColors.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onPressed != null 
              ? AppColors.textPrimary 
              : AppColors.textDisabled,
        ),
      ),
    );
  }
}
