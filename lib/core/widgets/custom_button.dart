import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/text_styles.dart';

/// Custom button widget with various styles and loading state
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final IconData? icon;
  final bool iconOnRight;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 52,
    this.borderRadius = 12,
    this.icon,
    this.iconOnRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? AppColors.primary : AppColors.white,
              ),
            ),
          )
        : _buildContent();

    if (isOutlined) {
      return SizedBox(
        width: isFullWidth ? double.infinity : width,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: onPressed == null
                  ? AppColors.textDisabled
                  : (backgroundColor ?? AppColors.primary),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: buttonChild,
        ),
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? AppColors.white,
          disabledBackgroundColor: AppColors.textDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 2,
        ),
        child: buttonChild,
      ),
    );
  }

  Widget _buildContent() {
    final textWidget = Text(
      text,
      style: TextStyles.buttonMedium.copyWith(
        color: isOutlined
            ? (textColor ?? AppColors.primary)
            : (textColor ?? AppColors.white),
      ),
    );

    if (icon == null) {
      return textWidget;
    }

    final iconWidget = Icon(
      icon,
      size: 20,
      color: isOutlined
          ? (textColor ?? AppColors.primary)
          : (textColor ?? AppColors.white),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconOnRight
          ? [textWidget, const SizedBox(width: 8), iconWidget]
          : [iconWidget, const SizedBox(width: 8), textWidget],
    );
  }
}

/// Secondary button preset
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isOutlined: true,
      icon: icon,
    );
  }
}

/// Icon button with background
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? AppColors.textPrimary,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
