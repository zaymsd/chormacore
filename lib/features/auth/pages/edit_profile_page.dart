import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

/// Edit profile page for updating user information
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  XFile? _selectedImage;
  String? _existingAvatar;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
      _existingAvatar = user.avatar;
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(ctx);
                _pickFromCamera();
              },
            ),
            if (_selectedImage != null || _existingAvatar != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Hapus Foto', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _selectedImage = null;
                    _existingAvatar = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (pickedFile != null && mounted) {
        debugPrint('Selected gallery image: ${pickedFile.path}');
        setState(() => _selectedImage = pickedFile);
      }
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (pickedFile != null && mounted) {
        debugPrint('Captured camera image: ${pickedFile.path}');
        setState(() => _selectedImage = pickedFile);
      }
    } catch (e) {
      debugPrint('Error picking from camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil foto: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    String? avatarPath;
    if (_selectedImage != null) {
      avatarPath = _selectedImage!.path;
    } else if (_existingAvatar != null) {
      avatarPath = _existingAvatar;
    }
    
    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty 
          ? _phoneController.text.trim() 
          : null,
      address: _addressController.text.trim().isNotEmpty 
          ? _addressController.text.trim() 
          : null,
      avatar: avatarPath,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else if (authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(child: Text('User tidak ditemukan'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar with image picker
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          backgroundImage: _getAvatarImage(),
                          child: _selectedImage == null && _existingAvatar == null
                              ? Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                  style: TextStyles.h2.copyWith(
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ketuk untuk ubah foto',
                    style: TextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  
                  // Email (read-only)
                  CustomTextField(
                    label: 'Email',
                    controller: TextEditingController(text: user.email),
                    prefixIcon: Icons.email_outlined,
                    enabled: false,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // Role (read-only)
                  CustomTextField(
                    label: 'Role',
                    controller: TextEditingController(
                      text: user.isSeller ? 'Penjual' : 'Pembeli',
                    ),
                    prefixIcon: user.isSeller 
                        ? Icons.store_outlined 
                        : Icons.shopping_bag_outlined,
                    enabled: false,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  
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
                  
                  // Phone field
                  CustomTextField(
                    label: 'Nomor Telepon',
                    hint: 'Contoh: 08123456789',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  
                  // Address field
                  CustomTextField(
                    label: 'Alamat',
                    hint: 'Masukkan alamat lengkap',
                    controller: _addressController,
                    prefixIcon: Icons.location_on_outlined,
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 32),
                  
                  // Save button
                  CustomButton(
                    text: 'Simpan Perubahan',
                    onPressed: _handleSave,
                    isLoading: authProvider.isLoading,
                  ),
                  const SizedBox(height: 16),
                  
                  // Change password button
                  SecondaryButton(
                    text: 'Ubah Password',
                    onPressed: () {
                      _showChangePasswordDialog(context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  ImageProvider? _getAvatarImage() {
    if (_selectedImage != null) {
      return FileImage(File(_selectedImage!.path));
    } else if (_existingAvatar != null && _existingAvatar!.isNotEmpty) {
      // Check if it's a file path or URL
      if (_existingAvatar!.startsWith('http')) {
        return NetworkImage(_existingAvatar!);
      } else {
        return FileImage(File(_existingAvatar!));
      }
    }
    return null;
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password Saat Ini',
                ),
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password Baru',
                ),
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                ),
                validator: (value) => Validators.validateConfirmPassword(
                  value,
                  newPasswordController.text,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return TextButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          final success = await authProvider.changePassword(
                            currentPasswordController.text,
                            newPasswordController.text,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Password berhasil diubah'
                                      : authProvider.error ?? 'Gagal mengubah password',
                                ),
                                backgroundColor:
                                    success ? AppColors.success : AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                child: Text(authProvider.isLoading ? 'Menyimpan...' : 'Simpan'),
              );
            },
          ),
        ],
      ),
    );
  }
}
