import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/text_styles.dart';

/// Password field widget with toggle visibility
class PasswordFieldWidget extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction textInputAction;

  const PasswordFieldWidget({
    super.key,
    this.controller,
    this.label = 'Password',
    this.hint = 'Masukkan password',
    this.validator,
    this.onChanged,
    this.textInputAction = TextInputAction.done,
  });

  @override
  State<PasswordFieldWidget> createState() => _PasswordFieldWidgetState();
}

class _PasswordFieldWidgetState extends State<PasswordFieldWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyles.labelMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          validator: widget.validator,
          onChanged: widget.onChanged,
          textInputAction: widget.textInputAction,
          style: TextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: const Icon(Icons.lock_outline, size: 22),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 22,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
