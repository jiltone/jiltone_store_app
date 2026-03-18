import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
        title: const Text('Admin Panel',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
        shadowColor: Colors.black12,
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
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return _buildEmptyState();
          }
          return _buildProductList(products);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_2_outlined,
                size: 40, color: Color(0xFFFF6B6B)),
          ),
          const SizedBox(height: 16),
          const Text('No products yet',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Tap "Add Product" to get started',
              style: TextStyle(color: Color(0xFF999999))),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            children: [
              _StatCard(
                  label: 'Total Products',
                  value: '${products.length}',
                  icon: Icons.inventory_2_rounded,
                  color: const Color(0xFFFF6B6B)),
              const SizedBox(width: 12),
              _StatCard(
                  label: 'On Sale',
                  value:
                      '${products.where((p) => p.isSale).length}',
                  icon: Icons.local_offer_rounded,
                  color: const Color(0xFFFF9A3C)),
              const SizedBox(width: 12),
              _StatCard(
                  label: 'New Arrivals',
                  value: '${products.where((p) => p.isNew).length}',
                  icon: Icons.new_releases_rounded,
                  color: const Color(0xFF6C63FF)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('All Products',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) =>
                  _ProductRow(product: products[i]),
            ),
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
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF999999))),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PRODUCT ROW (list item)
// ─────────────────────────────────────────────────────────────
class _ProductRow extends StatelessWidget {
  final Product product;
  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                  color: const Color(0xFFF0F0F0),
                  child: const Icon(Icons.image_outlined,
                      color: Colors.grey)),
              errorWidget: (_, __, ___) => Container(
                  color: const Color(0xFFF0F0F0),
                  child: const Icon(Icons.broken_image_outlined,
                      color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(product.category,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFFFF9A3C))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Color(0xFFFF6B6B),
                            fontWeight: FontWeight.w700)),
                    if (product.isNew) ...[
                      const SizedBox(width: 6),
                      _Badge('NEW', const Color(0xFF6C63FF)),
                    ],
                    if (product.isSale) ...[
                      const SizedBox(width: 6),
                      _Badge('SALE', const Color(0xFFFF6B6B)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionBtn(
                icon: Icons.edit_outlined,
                color: const Color(0xFF6C63FF),
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) =>
                      _ProductFormSheet(product: product),
                ),
              ),
              const SizedBox(width: 6),
              _ActionBtn(
                icon: Icons.delete_outline_rounded,
                color: const Color(0xFFFF6B6B),
                onTap: () => _confirmDelete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content:
            Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseService.deleteProduct(product);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
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
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ADD / EDIT PRODUCT FORM (bottom sheet)
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
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _sizesCtrl;
  late final TextEditingController _colorsCtrl;
  late final TextEditingController _imageUrlCtrl;
  late final TextEditingController _ratingCtrl;

  bool _isNew = false;
  bool _isSale = false;
  bool _isLoading = false;

  // Image picking
  Uint8List? _pickedImageBytes;
  String? _pickedFileName;

  final _categories = ['Tops', 'Bottoms', 'Dresses', 'Outerwear'];
  String _selectedCategory = 'Tops';

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _priceCtrl =
        TextEditingController(text: p?.price.toString() ?? '');
    _originalPriceCtrl =
        TextEditingController(text: p?.originalPrice != 0 ? p?.originalPrice.toString() : '');
    _categoryCtrl =
        TextEditingController(text: p?.category ?? 'Tops');
    _descriptionCtrl =
        TextEditingController(text: p?.description ?? '');
    _sizesCtrl = TextEditingController(
        text: p?.sizes.join(', ') ?? 'XS, S, M, L, XL');
    _colorsCtrl = TextEditingController(
        text: p?.colors.join(', ') ?? 'White, Black, Gray');
    _imageUrlCtrl = TextEditingController(text: p?.image ?? '');
    _ratingCtrl =
        TextEditingController(text: p?.rating.toString() ?? '4.5');
    _isNew = p?.isNew ?? false;
    _isSale = p?.isSale ?? false;
    if (p != null && _categories.contains(p.category)) {
      _selectedCategory = p.category;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _priceCtrl, _originalPriceCtrl, _categoryCtrl,
      _descriptionCtrl, _sizesCtrl, _colorsCtrl, _imageUrlCtrl, _ratingCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _pickedImageBytes = bytes;
      _pickedFileName = picked.name;
    });
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String imageUrl = _imageUrlCtrl.text.trim();

      // Upload image if user picked one
      if (_pickedImageBytes != null && _pickedFileName != null) {
        final ts = DateTime.now().millisecondsSinceEpoch;
        imageUrl = await FirebaseService.uploadProductImage(
          imageFile: _pickedImageBytes!,
          fileName: '${ts}_$_pickedFileName',
        );
      }

      final product = Product(
        id: widget.product?.id ?? '',
        name: _nameCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text) ?? 0,
        originalPrice:
            double.tryParse(_originalPriceCtrl.text) ?? 0,
        image: imageUrl,
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

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFFF6B6B),
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
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
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
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit Product' : 'Add New Product',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 20),

                    // ── Image picker ────────────────────────
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.grey[200]!, width: 1.5),
                        ),
                        child: _pickedImageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Image.memory(_pickedImageBytes!,
                                    fit: BoxFit.cover,
                                    width: double.infinity),
                              )
                            : _imageUrlCtrl.text.isNotEmpty
                                ? ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(13),
                                    child: CachedNetworkImage(
                                        imageUrl: _imageUrlCtrl.text,
                                        fit: BoxFit.cover,
                                        width: double.infinity),
                                  )
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF6B6B)
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                            Icons.cloud_upload_outlined,
                                            color: Color(0xFFFF6B6B),
                                            size: 30),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text('Tap to upload image',
                                          style: TextStyle(
                                              color: Color(0xFF999999),
                                              fontSize: 13)),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // OR paste URL
                    _FieldLabel('Or paste image URL'),
                    _Field(
                        controller: _imageUrlCtrl,
                        hint: 'https://example.com/image.jpg',
                        onChanged: (_) => setState(() {})),
                    const SizedBox(height: 12),

                    // ── Name ────────────────────────────────
                    _FieldLabel('Product Name *'),
                    _Field(
                        controller: _nameCtrl,
                        hint: 'e.g. Classic White Tee',
                        validator: (v) =>
                            v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 12),

                    // ── Price row ───────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Price *'),
                              _Field(
                                  controller: _priceCtrl,
                                  hint: '29.99',
                                  keyboardType:
                                      TextInputType.number,
                                  validator: (v) => v!.isEmpty
                                      ? 'Required'
                                      : null),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Original Price'),
                              _Field(
                                  controller: _originalPriceCtrl,
                                  hint: '39.99',
                                  keyboardType:
                                      TextInputType.number),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

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
                          items: _categories
                              .map((c) => DropdownMenuItem(
                                  value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Description ─────────────────────────
                    _FieldLabel('Description'),
                    _Field(
                        controller: _descriptionCtrl,
                        hint: 'Enter product description...',
                        maxLines: 3),
                    const SizedBox(height: 12),

                    // ── Sizes & Colors ──────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
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
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Colors (comma separated)'),
                              _Field(
                                  controller: _colorsCtrl,
                                  hint: 'White, Black, Gray'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Rating ──────────────────────────────
                    _FieldLabel('Rating (1-5)'),
                    _Field(
                        controller: _ratingCtrl,
                        hint: '4.5',
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 16),

                    // ── Toggles ─────────────────────────────
                    Row(
                      children: [
                        _Toggle(
                          label: 'New Arrival',
                          value: _isNew,
                          onChanged: (v) =>
                              setState(() => _isNew = v),
                        ),
                        const SizedBox(width: 16),
                        _Toggle(
                          label: 'On Sale',
                          value: _isSale,
                          onChanged: (v) =>
                              setState(() => _isSale = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Save button ─────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14)),
                          textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5))
                            : Text(
                                isEdit
                                    ? 'Save Changes'
                                    : 'Add Product'),
                      ),
                    ),
                    const SizedBox(height: 10),
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

// ── Small helpers ─────────────────────────────────────────────
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
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
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
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;
  const _Toggle(
      {required this.label,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFFF6B6B),
        ),
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
