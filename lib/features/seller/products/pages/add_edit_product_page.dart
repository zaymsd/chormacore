import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/repositories/product_repository.dart';
import '../providers/product_management_provider.dart';

/// Add/Edit product page for seller
class AddEditProductPage extends StatefulWidget {
  final String? productId;

  const AddEditProductPage({
    super.key,
    this.productId,
  });

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  final List<String> _imagePaths = []; // Store image paths as strings
  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.productId != null;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Load categories
    final productRepo = ProductRepository();
    _categories = await productRepo.getAllCategories();
    
    // Load product if editing
    if (_isEdit && widget.productId != null) {
      final provider = Provider.of<ProductManagementProvider>(context, listen: false);
      await provider.getProductDetail(widget.productId!);
      final product = provider.selectedProduct;
      
      if (product != null) {
        _nameController.text = product.name;
        _descriptionController.text = product.description ?? '';
        _priceController.text = product.price.toStringAsFixed(0);
        _stockController.text = product.stock.toString();
        _selectedCategoryId = product.categoryId;
        _imagePaths.addAll(product.images);
      }
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _pickFromGallery() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFiles.isNotEmpty && mounted) {
        final remainingSlots = 5 - _imagePaths.length;
        if (remainingSlots > 0) {
          setState(() {
            for (var file in pickedFiles.take(remainingSlots)) {
              _imagePaths.add(file.path);
              debugPrint('Added image: ${file.path}');
            }
          });
        } else {
          _showMaxImagesMessage();
        }
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
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
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null && mounted) {
        if (_imagePaths.length < 5) {
          setState(() {
            _imagePaths.add(pickedFile.path);
            debugPrint('Added camera image: ${pickedFile.path}');
          });
        } else {
          _showMaxImagesMessage();
        }
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil foto: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showMaxImagesMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Maksimal 5 gambar'), backgroundColor: AppColors.warning),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
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
              subtitle: const Text('Pilih beberapa gambar sekaligus'),
              onTap: () {
                Navigator.pop(ctx);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Ambil Foto'),
              subtitle: const Text('Ambil foto baru'),
              onTap: () {
                Navigator.pop(ctx);
                _pickFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori produk'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<ProductManagementProvider>(context, listen: false);
    
    bool success;
    if (_isEdit && provider.selectedProduct != null) {
      final updatedProduct = provider.selectedProduct!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        categoryId: _selectedCategoryId,
        images: _imagePaths,
      );
      success = await provider.updateProduct(updatedProduct);
    } else {
      final product = await provider.createProduct(
        name: _nameController.text.trim(),
        categoryId: _selectedCategoryId!,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        images: _imagePaths,
      );
      success = product != null;
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Produk berhasil diperbarui' : 'Produk berhasil ditambahkan'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error!), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Produk' : 'Tambah Produk'),
      ),
      body: _isLoading && _categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Images Section - ListView
                    Text('Foto Produk (${_imagePaths.length}/5)', style: TextStyles.labelMedium),
                    const SizedBox(height: 8),
                    _buildImageSection(),
                    const SizedBox(height: 24),

                    // Name
                    CustomTextField(
                      label: 'Nama Produk',
                      hint: 'Masukkan nama produk',
                      controller: _nameController,
                      validator: Validators.validateRequired,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),

                    // Category
                    Text('Kategori', style: TextStyles.labelMedium),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        hintText: 'Pilih kategori',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(value: cat.id, child: Text(cat.name));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedCategoryId = value),
                    ),
                    const SizedBox(height: 16),

                    // Price
                    CustomTextField(
                      label: 'Harga (Rp)',
                      hint: 'Masukkan harga',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      validator: Validators.validatePrice,
                      prefixIcon: Icons.attach_money,
                    ),
                    const SizedBox(height: 16),

                    // Stock
                    CustomTextField(
                      label: 'Stok',
                      hint: 'Masukkan jumlah stok',
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      validator: Validators.validateStock,
                      prefixIcon: Icons.inventory_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    CustomTextField(
                      label: 'Deskripsi (Opsional)',
                      hint: 'Masukkan deskripsi produk',
                      controller: _descriptionController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    CustomButton(
                      text: _isEdit ? 'Simpan Perubahan' : 'Tambah Produk',
                      onPressed: _handleSubmit,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Image List
          if (_imagePaths.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _imagePaths.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _buildImageListItem(index);
              },
            ),
          
          // Add Image Button
          if (_imagePaths.length < 5)
            InkWell(
              onTap: _showImagePickerOptions,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: _imagePaths.isNotEmpty 
                      ? const Border(top: BorderSide(color: AppColors.border))
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      _imagePaths.isEmpty ? 'Tambah Foto Produk' : 'Tambah Foto Lagi',
                      style: TextStyles.bodyMedium.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageListItem(int index) {
    final imagePath = _imagePaths[index];
    final file = File(imagePath);
    final exists = file.existsSync();
    
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Image Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: AppColors.surfaceVariant,
              child: exists
                  ? Image.file(
                      file,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, __) {
                        debugPrint('Error loading: $error');
                        return _buildErrorImage();
                      },
                    )
                  : _buildErrorImage(),
            ),
          ),
          const SizedBox(width: 12),
          
          // Image Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Foto ${index + 1}',
                  style: TextStyles.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  exists ? 'Tersimpan' : 'File tidak ditemukan',
                  style: TextStyles.caption.copyWith(
                    color: exists ? AppColors.success : AppColors.error,
                  ),
                ),
                Text(
                  _getFileName(imagePath),
                  style: TextStyles.caption.copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Delete Button
          IconButton(
            onPressed: () => _removeImage(index),
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Hapus foto',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorImage() {
    return const Center(
      child: Icon(Icons.broken_image, color: AppColors.error, size: 24),
    );
  }

  String _getFileName(String path) {
    return path.split('/').last.split('\\').last;
  }
}
