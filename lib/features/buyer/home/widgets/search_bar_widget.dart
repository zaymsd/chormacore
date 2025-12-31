import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';

/// Search bar widget for buyer home
class SearchBarWidget extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String)? onSearch;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final String hint;

  const SearchBarWidget({
    super.key,
    this.controller,
    this.onSearch,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.hint = 'Cari produk...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSearch,
        onTap: onTap,
        readOnly: readOnly,
        style: TextStyles.bodyMedium,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyles.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          suffixIcon: controller != null && controller!.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    controller?.clear();
                    onSearch?.call('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
