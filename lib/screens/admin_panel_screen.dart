import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../models/product.dart';
import '../services/firebase_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9B59FF)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Admin Panel',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
        surfaceTintColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _openAddProduct,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: FirebaseService.productsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) return _buildEmptyState();
          return _buildBody(products);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          5,
          (_) => Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.grey[50]!,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 48, color: Color(0xFFFF6B6B)),
            ),
            const SizedBox(height: 16),
            const Text('Connection Error',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Make sure Firebase is configured correctly.\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF999999), fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF9A3C)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.inventory_2_outlined,
                size: 44, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text('No Products Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Tap "Add Product" to add your first item',
              style: TextStyle(color: Color(0xFF999999), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBody(List<Product> products) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            children: [
              _StatCard(
                label: 'Products',
                value: '${products.length}',
                icon: Icons.inventory_2_rounded,
                color: const Color(0xFFFF6B6B),
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'On Sale',
                value: '${products.where((p) => p.isSale).length}',
                icon: Icons.local_offer_rounded,
                color: const Color(0xFFFF9A3C),
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'New In',
                value: '${products.where((p) => p.isNew).length}',
                icon: Icons.new_releases_rounded,
                color: const Color(0xFF6C63FF),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Category breakdown
          _buildCategoryBreakdown(products),
          const SizedBox(height: 24),

          const Text('All Products',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          // Product list
          ...products.map((p) => _ProductRow(
                product: p,
                onEdit: () => _openEditProduct(p),
                onDelete: () => _confirmDelete(p),
              )),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<Product> products) {
    final categories = <String, int>{};
    for (final p in products) {
      categories[p.category] = (categories[p.category] ?? 0) + 1;
    }
    if (categories.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('By Category',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${entry.key}  ${entry.value}',
                  style: const TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _openAddProduct() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ProductFormSheet(),
    );
  }

  void _openEditProduct(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductFormSheet(product: product),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Product',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            'Are you sure you want to delete\n"${product.name}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF999999))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseService.deleteProduct(product.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${product.name}" deleted'),
                    backgroundColor: const Color(0xFF333333),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  STAT CARD
// ─────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800)),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: Color(0xFF999999))),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PRODUCT ROW
// ─────────────────────────────────────────────────────────────
class _ProductRow extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductRow(
      {required this.product,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: product.image,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              placeholder: (_, __) => Shimmer.fromColors(
                baseColor: Colors.grey[200]!,
                highlightColor: Colors.grey[50]!,
                child: Container(color: Colors.grey[200]),
              ),
              errorWidget: (_, __, ___) => Container(
                color: const Color(0xFFF5F5F5),
                child: const Icon(Icons.image_outlined,
                    color: Colors.grey, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(product.category,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFFFF9A3C),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontWeight: FontWeight.w700,
                          fontSize: 13),
                    ),
                    if (product.originalPrice > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '\$${product.originalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFFBBBBBB),
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    if (product.isNew) _Tag('NEW', const Color(0xFF6C63FF)),
                    if (product.isSale) ...[
                      if (product.isNew) const SizedBox(width: 4),
                      _Tag('SALE', const Color(0xFFFF6B6B)),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              _ActionBtn(
                icon: Icons.edit_outlined,
                color: const Color(0xFF6C63FF),
                onTap: onEdit,
              ),
              const SizedBox(height: 6),
              _ActionBtn(
                icon: Icons.delete_outline_rounded,
                color: const Color(0xFFFF6B6B),
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ADD / EDIT PRODUCT FORM
// ─────────────────────────────────────────────────────────────
class _ProductFormSheet extends StatefulWidget {
  final Product? product;
  const _ProductFormSheet({this.product});

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _form = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _originalPriceCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _sizesCtrl;
  late final TextEditingController _colorsCtrl;
  late final TextEditingController _imageUrlCtrl;
  late final TextEditingController _ratingCtrl;

  String _selectedCategory = 'Tops';
  bool _isNew = false;
  bool _isSale = false;
  bool _isLoading = false;

  final _categories = ['Tops', 'Bottoms', 'Dresses', 'Outerwear'];

  // Quick image suggestions
  final _quickImages = [
    ('Tops', 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600&h=800&fit=crop'),
    ('Jeans', 'https://images.unsplash.com/photo-1542272604-787c62d465d1?w=600&h=800&fit=crop'),
    ('Dress', 'https://images.unsplash.com/photo-1572804419446-b8a89e42fc73?w=600&h=800&fit=crop'),
    ('Jacket', 'https://images.unsplash.com/photo-1551028719-00167b16ebc5?w=600&h=800&fit=crop'),
    ('Blazer', 'https://images.unsplash.com/photo-1591047990366-ebc4de28526d?w=600&h=800&fit=crop'),
    ('Sweater', 'https://images.unsplash.com/photo-1526768752127-fac6461fbe38?w=600&h=800&fit=crop'),
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _priceCtrl = TextEditingController(text: p?.price != null ? p!.price.toString() : '');
    _originalPriceCtrl = TextEditingController(
        text: p?.originalPrice != 0 ? p?.originalPrice.toString() : '');
    _descriptionCtrl = TextEditingController(text: p?.description ?? '');
    _sizesCtrl = TextEditingController(
        text: p?.sizes.join(', ') ?? 'XS, S, M, L, XL');
    _colorsCtrl = TextEditingController(
        text: p?.colors.join(', ') ?? 'White, Black, Gray');
    _imageUrlCtrl = TextEditingController(text: p?.image ?? '');
    _ratingCtrl = TextEditingController(
        text: p?.rating != null ? p!.rating.toString() : '4.5');
    _isNew = p?.isNew ?? false;
    _isSale = p?.isSale ?? false;
    if (p != null && _categories.contains(p.category)) {
      _selectedCategory = p.category;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _priceCtrl, _originalPriceCtrl, _descriptionCtrl,
      _sizesCtrl, _colorsCtrl, _imageUrlCtrl, _ratingCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final product = Product(
        id: widget.product?.id ?? '',
        name: _nameCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text) ?? 0,
        originalPrice: double.tryParse(_originalPriceCtrl.text) ?? 0,
        image: _imageUrlCtrl.text.trim(),
        category: _selectedCategory,
        rating: double.tryParse(_ratingCtrl.text) ?? 4.5,
        description: _descriptionCtrl.text.trim(),
        sizes: _sizesCtrl.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        colors: _colorsCtrl.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        isNew: _isNew,
        isSale: _isSale,
      );

      if (widget.product == null) {
        await FirebaseService.addProduct(product);
      } else {
        await FirebaseService.updateProduct(product);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null
                ? '✅ Product added successfully!'
                : '✅ Product updated!'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFFF9A3C)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isEdit ? Icons.edit_rounded : Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isEdit ? 'Edit Product' : 'Add New Product',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Image URL ────────────────────────────
                    _FieldLabel('Product Image URL *'),
                    _Field(
                      controller: _imageUrlCtrl,
                      hint: 'https://images.unsplash.com/...',
                      onChanged: (_) => setState(() {}),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Image URL is required' : null,
                    ),
                    const SizedBox(height: 8),

                    // Image preview
                    if (_imageUrlCtrl.text.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: _imageUrlCtrl.text,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            height: 80,
                            color: const Color(0xFFF5F5F5),
                            child: const Center(
                              child: Text('Invalid URL or image not found',
                                  style:
                                      TextStyle(color: Color(0xFFBBBBBB))),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Quick image picks
                    const Text('Quick picks (tap to use):',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF999999))),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 64,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _quickImages.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final img = _quickImages[i];
                          return GestureDetector(
                            onTap: () {
                              _imageUrlCtrl.text = img.$2;
                              setState(() {});
                            },
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: img.$2,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(img.$1,
                                    style: const TextStyle(
                                        fontSize: 9,
                                        color: Color(0xFF999999))),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Name ────────────────────────────────
                    _FieldLabel('Product Name *'),
                    _Field(
                      controller: _nameCtrl,
                      hint: 'e.g. Classic White Tee',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 14),

                    // ── Price row ───────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Price (\$) *'),
                              _Field(
                                controller: _priceCtrl,
                                hint: '29.99',
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Original Price (\$)'),
                              _Field(
                                controller: _originalPriceCtrl,
                                hint: '39.99 (for sale)',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Category ────────────────────────────
                    _FieldLabel('Category *'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.grey[200]!, width: 1.5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          style: const TextStyle(
                              color: Color(0xFF333333), fontSize: 14),
                          items: _categories
                              .map((c) => DropdownMenuItem(
                                  value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Description ─────────────────────────
                    _FieldLabel('Description'),
                    _Field(
                      controller: _descriptionCtrl,
                      hint: 'Describe the product...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),

                    // ── Sizes & Colors ──────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Sizes (comma separated)'),
                              _Field(
                                  controller: _sizesCtrl,
                                  hint: 'XS, S, M, L, XL'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Colors (comma separated)'),
                              _Field(
                                  controller: _colorsCtrl,
                                  hint: 'White, Black'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Rating ──────────────────────────────
                    _FieldLabel('Rating (1.0 – 5.0)'),
                    _Field(
                      controller: _ratingCtrl,
                      hint: '4.5',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),

                    // ── Toggles ─────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Switch(
                                  value: _isNew,
                                  onChanged: (v) =>
                                      setState(() => _isNew = v),
                                  activeColor: const Color(0xFF6C63FF),
                                ),
                                const Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('New Arrival',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                    Text('Shows "NEW" badge',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF999999))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Switch(
                                  value: _isSale,
                                  onChanged: (v) =>
                                      setState(() => _isSale = v),
                                  activeColor: const Color(0xFFFF6B6B),
                                ),
                                const Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('On Sale',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                    Text('Shows "SALE" badge',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF999999))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Save button ─────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : Text(isEdit
                                ? 'Save Changes'
                                : 'Add Product'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Reusable small widgets
// ─────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555))),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const _Field({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF8F9FC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFFFF6B6B), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
        ),
      ),
    );
  }
}
