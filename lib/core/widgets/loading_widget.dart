import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/text_styles.dart';

/// Loading widget with various styles
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final bool isOverlay;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 40,
    this.color,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final loadingIndicator = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primary,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyles.bodyMedium.copyWith(
              color: isOverlay ? AppColors.white : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isOverlay) {
      return Container(
        color: AppColors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: loadingIndicator,
          ),
        ),
      );
    }

    return Center(child: loadingIndicator);
  }
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: LoadingWidget(
              isOverlay: true,
              message: message,
            ),
          ),
      ],
    );
  }
}

/// Shimmer loading placeholder
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Product card shimmer loading
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading(
            height: 150,
            borderRadius: 12,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerLoading(height: 16, width: 120),
                SizedBox(height: 8),
                ShimmerLoading(height: 14, width: 80),
                SizedBox(height: 8),
                ShimmerLoading(height: 18, width: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// List item shimmer loading
class ListItemShimmer extends StatelessWidget {
  const ListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          const ShimmerLoading(width: 60, height: 60, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerLoading(height: 16),
                SizedBox(height: 8),
                ShimmerLoading(height: 14, width: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
