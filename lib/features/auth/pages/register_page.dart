import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/password_field_widget.dart';

/// Register page for new user registration
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedRole = AppConstants.roleBuyer;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
      phone: _phoneController.text.trim().isNotEmpty 
          ? _phoneController.text.trim() 
          : null,
    );

    if (success && mounted) {
      // Navigate based on role
      if (authProvider.isSeller) {
        Navigator.pushReplacementNamed(context, AppRoutes.sellerDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.buyerHome);
      }
    } else if (mounted && authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Buat Akun Baru',
                      style: TextStyles.h3,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Daftar untuk mulai berbelanja atau berjualan',
                      style: TextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Role Selection
                    Text(
                      'Daftar sebagai',
                      style: TextStyles.labelMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _RoleCard(
                            icon: Icons.shopping_bag_outlined,
                            label: 'Pembeli',
                            isSelected: _selectedRole == AppConstants.roleBuyer,
                            onTap: () {
                              setState(() {
                                _selectedRole = AppConstants.roleBuyer;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _RoleCard(
                            icon: Icons.store_outlined,
                            label: 'Penjual',
                            isSelected: _selectedRole == AppConstants.roleSeller,
                            onTap: () {
                              setState(() {
                                _selectedRole = AppConstants.roleSeller;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Name field
                    CustomTextField(
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline,
                      validator: Validators.validateName,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    
                    // Email field
                    CustomTextField(
                      label: 'Email',
                      hint: 'Masukkan email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.validateEmail,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone field
                    CustomTextField(
                      label: 'Nomor Telepon (Opsional)',
                      hint: 'Contoh: 08123456789',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    
                    // Password field
                    PasswordFieldWidget(
                      controller: _passwordController,
                      validator: Validators.validatePassword,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    
                    // Confirm password field
                    PasswordFieldWidget(
                      controller: _confirmPasswordController,
                      label: 'Konfirmasi Password',
                      hint: 'Masukkan ulang password',
                      validator: (value) => Validators.validateConfirmPassword(
                        value, 
                        _passwordController.text,
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 32),
                    
                    // Submit button
                    CustomButton(
                      text: 'Daftar',
                      onPressed: _handleRegister,
                      isLoading: authProvider.isLoading,
                    ),
                    const SizedBox(height: 24),
                    
                    // Footer
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah punya akun?',
                            style: TextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Masuk',
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
          },
        ),
      ),
    );
  }
}

/// Role selection card widget
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyles.labelLarge.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
