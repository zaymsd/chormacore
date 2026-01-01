import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';

/// Product detail page for buyer
class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  ProductModel? _product;
  bool _isLoading = true;
  bool _isInWishlist = false;
  int _quantity = 1;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    
    try {
      final repository = ProductRepository();
      final product = await repository.getProductById(widget.productId);
      
      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
        
        // Check wishlist status
        _checkWishlistStatus();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat produk: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _checkWishlistStatus() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
      wishlistProvider.setUser(authProvider.currentUser!.id).then((_) {
        if (mounted) {
          setState(() => _isInWishlist = wishlistProvider.isInWishlist(widget.productId));
        }
      });
    }
  }

  Future<void> _addToCart() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.setUser(authProvider.currentUser!.id);
    
    final success = await cartProvider.addToCart(widget.productId, quantity: _quantity);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_quantity item ditambahkan ke keranjang'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Lihat',
              textColor: Colors.white,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cartProvider.error ?? 'Gagal menambahkan ke keranjang'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleWishlist() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
    await wishlistProvider.setUser(authProvider.currentUser!.id);
    
    if (_isInWishlist) {
      await wishlistProvider.removeFromWishlist(widget.productId);
    } else {
      await wishlistProvider.addToWishlist(widget.productId);
    }
    
    if (mounted) {
      setState(() => _isInWishlist = !_isInWishlist);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isInWishlist ? 'Ditambahkan ke wishlist' : 'Dihapus dari wishlist'),
          backgroundColor: _isInWishlist ? AppColors.success : AppColors.info,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          IconButton(
            icon: Icon(
              _isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: _isInWishlist ? AppColors.error : null,
            ),
            onPressed: _toggleWishlist,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Share product
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _product == null
              ? const Center(child: Text('Produk tidak ditemukan'))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Images
                            _buildImageGallery(),
                            
                            // Product Info
                            Container(
                              padding: const EdgeInsets.all(16),
                              color: AppColors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Price
                                  Text(
                                    CurrencyFormatter.format(_product!.price),
                                    style: TextStyles.h4.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Name
                                  Text(_product!.name, style: TextStyles.h5),
                                  const SizedBox(height: 8),
                                  
                                  // Rating & Sold
                                  Row(
                                    children: [
                                      Icon(Icons.star, size: 16, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_product!.rating.toStringAsFixed(1)} | Terjual ${_product!.soldCount}',
                                        style: TextStyles.caption,
                                      ),
                                    ],
                                  ),
                                  
                                  // Out of stock indicator only
                                  if (!_product!.isInStock) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Stok Habis',
                                        style: TextStyles.caption.copyWith(
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Seller Info
                            Container(
                              padding: const EdgeInsets.all(16),
                              color: AppColors.white,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                                    child: const Icon(Icons.store, color: AppColors.secondary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _product!.sellerName ?? 'Toko',
                                          style: TextStyles.labelMedium,
                                        ),
                                        Text(
                                          'Lihat Toko',
                                          style: TextStyles.caption.copyWith(color: AppColors.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      // TODO: Navigate to seller store
                                    },
                                    child: const Text('Kunjungi'),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Description
                            Container(
                              padding: const EdgeInsets.all(16),
                              color: AppColors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Deskripsi Produk', style: TextStyles.labelLarge),
                                  const SizedBox(height: 8),
                                  Text(
                                    _product!.description ?? 'Tidak ada deskripsi',
                                    style: TextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom Action Bar
                    _buildBottomBar(),
                  ],
                ),
    );
  }

  Widget _buildImageGallery() {
    final images = _product?.images ?? [];
    
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          // Main Image
          AspectRatio(
            aspectRatio: 1,
            child: images.isNotEmpty
                ? _buildProductImage(images[_selectedImageIndex])
                : Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.computer, size: 100, color: AppColors.textHint),
                  ),
          ),
          
          // Image Thumbnails
          if (images.length > 1)
            Container(
              height: 80,
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedImageIndex = index),
                    child: Container(
                      width: 64,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedImageIndex == index 
                              ? AppColors.primary 
                              : AppColors.border,
                          width: _selectedImageIndex == index ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: _buildProductImage(images[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    } else {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return Container(
      color: AppColors.surfaceVariant,
      child: const Icon(Icons.computer, color: AppColors.textHint),
    );
  }

  Widget _buildBottomBar() {
    final isInStock = _product?.isInStock ?? false;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity Selector
            if (isInStock) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: _quantity > 1 
                          ? () => setState(() => _quantity--) 
                          : null,
                    ),
                    Text('$_quantity', style: TextStyles.labelMedium),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: _quantity < (_product?.stock ?? 1) 
                          ? () => setState(() => _quantity++) 
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
            
            // Add to Cart Button
            Expanded(
              child: CustomButton(
                text: isInStock ? 'Tambah ke Keranjang' : 'Stok Habis',
                onPressed: isInStock ? _addToCart : null,
                icon: isInStock ? Icons.add_shopping_cart : Icons.remove_shopping_cart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
