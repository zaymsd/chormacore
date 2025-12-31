import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';

/// Cart summary widget showing total and checkout button
class CartSummaryWidget extends StatelessWidget {
  final double total;
  final int itemCount;
  final VoidCallback? onCheckout;
  final bool isLoading;

  const CartSummaryWidget({
    super.key,
    required this.total,
    required this.itemCount,
    this.onCheckout,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary rows
            _buildSummaryRow(
              'Total Item',
              '$itemCount item',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Total Belanja',
              CurrencyFormatter.format(total),
              isTotal: true,
            ),
            const SizedBox(height: 16),
            
            // Checkout button
            CustomButton(
              text: 'Checkout (${CurrencyFormatter.format(total)})',
              onPressed: onCheckout,
              isLoading: isLoading,
              icon: Icons.shopping_cart_checkout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal 
              ? TextStyles.labelLarge 
              : TextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: isTotal 
              ? TextStyles.priceLarge 
              : TextStyles.labelLarge,
        ),
      ],
    );
  }
}
