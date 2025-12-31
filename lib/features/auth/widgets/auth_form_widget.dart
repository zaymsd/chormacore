import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../core/widgets/custom_button.dart';

/// Reusable auth form widget for login and register
class AuthFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String title;
  final String subtitle;
  final List<Widget> fields;
  final String buttonText;
  final VoidCallback onSubmit;
  final bool isLoading;
  final String? footerText;
  final String? footerActionText;
  final VoidCallback? onFooterAction;

  const AuthFormWidget({
    super.key,
    required this.formKey,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.buttonText,
    required this.onSubmit,
    this.isLoading = false,
    this.footerText,
    this.footerActionText,
    this.onFooterAction,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            
            // Logo/Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 40,
                  color: AppColors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              title,
              style: TextStyles.h3,
            ),
            
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              subtitle,
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Form fields
            ...fields.map((field) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: field,
            )),
            
            const SizedBox(height: 8),
            
            // Submit button
            CustomButton(
              text: buttonText,
              onPressed: onSubmit,
              isLoading: isLoading,
            ),
            
            const SizedBox(height: 24),
            
            // Footer
            if (footerText != null && footerActionText != null)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      footerText!,
                      style: TextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: onFooterAction,
                      child: Text(
                        footerActionText!,
                        style: TextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
