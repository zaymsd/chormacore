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
            Icon(
              _getIconData(category.icon),
              size: 18,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
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

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'devices':
        return Icons.devices;
      case 'man':
        return Icons.man;
      case 'woman':
        return Icons.woman;
      case 'spa':
        return Icons.spa;
      case 'home':
        return Icons.home;
      case 'sports_basketball':
        return Icons.sports_basketball;
      case 'restaurant':
        return Icons.restaurant;
      case 'toys':
        return Icons.toys;
      default:
        return Icons.category;
    }
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
