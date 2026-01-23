import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../data/models/category_model.dart';

/// Category chip widget for filtering
class CategoryChipWidget extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChipWidget({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Use Image.asset instead of Icon
            Image.asset(
              _getCategoryImagePath(category.name),
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.category,
                  size: 24,
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                );
              },
            ),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: TextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryImagePath(String categoryName) {
    // Normalize category name
    final normalized = categoryName.toLowerCase().trim();
    
    // Explicit mapping for known mismatches
    final Map<String, String> categoryMap = {
      'pc desktop': 'Pcdesktop.png',
      'desktop': 'Pcdesktop.png',
      'keyboard mouse': 'keyboarddanmouse.png',
      'keyboard & mouse': 'keyboarddanmouse.png',
      'keyboard': 'keyboarddanmouse.png', // Fallback if just keyboard
      'mouse': 'keyboarddanmouse.png',    // Fallback if just mouse
      'monitor': 'monitor.png',
      'printer': 'printer.png',
      'printer & scanner': 'printer.png', // Exact match from seed data
      'scanner': 'printer.png',
      'komponen pc': 'komponen pc.png',
      'aksesoris': 'aksesoris.png',
      'audio': 'audio.png',
      'laptop': 'laptop.png',
      'networking': 'networking.png',
      'storage': 'storage.png',
    };

    if (categoryMap.containsKey(normalized)) {
      return 'assets/images/category/${categoryMap[normalized]}';
    }

    // Default fallback: try to use the normalized name directly
    // This handles simple cases like "audio" -> "audio.png"
    return 'assets/images/category/$normalized.png';
  }
}

/// Category list widget with horizontal scroll
class CategoryListWidget extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  const CategoryListWidget({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // All categories chip
          GestureDetector(
            onTap: () => onCategorySelected(null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selectedCategoryId == null 
                    ? AppColors.primary 
                    : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selectedCategoryId == null 
                      ? AppColors.primary 
                      : AppColors.border,
                  width: 1,
                ),
              ),
              child: Text(
                'Semua',
                style: TextStyles.labelMedium.copyWith(
                  color: selectedCategoryId == null 
                      ? AppColors.white 
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Category chips
          ...categories.map((category) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CategoryChipWidget(
              category: category,
              isSelected: selectedCategoryId == category.id,
              onTap: () => onCategorySelected(category.id),
            ),
          )),
        ],
      ),
    );
  }
}
