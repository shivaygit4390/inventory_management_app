import 'package:flutter/material.dart';
import 'package:inventory_management_app/core/constants/product_image_constants.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/presentation/validation/product_form_validators.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/product_image.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/product_text_form_field.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({
    required this.onSubmit,
    this.initialProduct,
    this.submitLabel,
    this.isSubmitting = false,
    super.key,
  });

  final Product? initialProduct;
  final ValueChanged<Product> onSubmit;
  final String? submitLabel;
  final bool isSubmitting;

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockQuantityController;
  late final TextEditingController _skuController;
  late final TextEditingController _imageUrlController;

  bool get _isEditing => widget.initialProduct != null;

  @override
  void initState() {
    super.initState();
    final Product? product = widget.initialProduct;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _categoryController = TextEditingController(text: product?.category ?? '');
    _priceController = TextEditingController(
      text: product == null ? '' : _formatPrice(product.price),
    );
    _stockQuantityController = TextEditingController(
      text: product?.stockQuantity.toString() ?? '',
    );
    _skuController = TextEditingController(text: product?.sku ?? '');
    _imageUrlController = TextEditingController(
      text: product?.imageUrl ?? ProductImageConstants.defaultImageUrl,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _stockQuantityController.dispose();
    _skuController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProductTextFormField(
            controller: _nameController,
            label: 'Product name',
            hint: 'e.g. Wireless Mouse',
            prefixIcon: Icons.inventory_2_outlined,
            validator: ProductFormValidators.name,
          ),
          const SizedBox(height: 16),
          ProductTextFormField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Describe the product',
            prefixIcon: Icons.notes_outlined,
            maxLines: 3,
            validator: ProductFormValidators.description,
          ),
          const SizedBox(height: 16),
          _ResponsiveFieldPair(
            first: ProductTextFormField(
              controller: _categoryController,
              label: 'Category',
              hint: 'e.g. Electronics',
              prefixIcon: Icons.category_outlined,
              validator: ProductFormValidators.category,
            ),
            second: ProductTextFormField(
              controller: _skuController,
              label: 'SKU',
              hint: 'e.g. WM-001',
              prefixIcon: Icons.qr_code_outlined,
              validator: ProductFormValidators.sku,
            ),
          ),
          const SizedBox(height: 16),
          _ResponsiveFieldPair(
            first: ProductTextFormField(
              controller: _priceController,
              label: 'Price',
              hint: '0.00',
              prefixIcon: Icons.currency_rupee,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: ProductFormValidators.price,
            ),
            second: ProductTextFormField(
              controller: _stockQuantityController,
              label: 'Stock quantity',
              hint: '0',
              prefixIcon: Icons.numbers_outlined,
              keyboardType: TextInputType.number,
              validator: ProductFormValidators.stockQuantity,
            ),
          ),
          const SizedBox(height: 16),
          ProductTextFormField(
            controller: _imageUrlController,
            label: 'Image URL',
            hint: 'https://example.com/product.png',
            prefixIcon: Icons.image_outlined,
            textInputAction: TextInputAction.done,
            validator: ProductFormValidators.imageUrl,
          ),
          const SizedBox(height: 16),
          Text(
            'Image preview',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _imageUrlController,
              builder:
                  (
                    BuildContext context,
                    TextEditingValue value,
                    Widget? child,
                  ) {
                    return ProductImage.fromUrl(
                      key: ValueKey<String>(value.text.trim()),
                      imageUrl: value.text.trim(),
                      fit: BoxFit.contain,
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                    );
                  },
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const Key('product-form-submit'),
            onPressed: widget.isSubmitting ? null : _submit,
            icon: widget.isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_isEditing ? Icons.save_outlined : Icons.add),
            label: Text(
              widget.isSubmitting
                  ? 'Saving…'
                  : widget.submitLabel ??
                        (_isEditing ? 'Save changes' : 'Add product'),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    widget.onSubmit(
      Product(
        id: widget.initialProduct?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        stockQuantity: int.parse(_stockQuantityController.text.trim()),
        sku: _skuController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
      ),
    );
  }

  static String _formatPrice(double price) {
    return price == price.roundToDouble()
        ? price.toStringAsFixed(0)
        : price.toString();
  }
}

class _ResponsiveFieldPair extends StatelessWidget {
  const _ResponsiveFieldPair({required this.first, required this.second});

  static const double _wideLayoutBreakpoint = 600;

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < _wideLayoutBreakpoint) {
          return Column(children: [first, const SizedBox(height: 16), second]);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 16),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}
