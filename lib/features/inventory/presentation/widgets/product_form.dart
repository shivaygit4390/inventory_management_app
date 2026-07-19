import 'package:flutter/material.dart';
import 'package:inventory_management_app/app/theme/app_theme.dart';
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
  static const List<String> _categoryOptions = <String>[
    'Electronics',
    'Accessories',
    'Storage devices',
    'Audio & Multimedia',
    'Others',
  ];

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
    final String initialCategory = product?.category.trim() ?? '';
    _categoryController = TextEditingController(
      text: _categoryOptions.contains(initialCategory) ? initialCategory : '',
    );
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
    final Widget identitySection = _FormSection(
      icon: Icons.badge_rounded,
      iconColor: Theme.of(context).colorScheme.primary,
      title: 'Product identity',
      description: 'Give the item a clear name and useful description.',
      child: Column(
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
        ],
      ),
    );
    final Widget classificationSection = _FormSection(
      icon: Icons.sell_rounded,
      iconColor: Theme.of(context).colorScheme.secondary,
      title: 'Classification',
      description: 'Organize the item so it is easy to find later.',
      child: _ResponsiveFieldPair(
        first: _CategoryDropdownField(
          controller: _categoryController,
          categories: _categoryOptions,
        ),
        second: ProductTextFormField(
          controller: _skuController,
          label: 'SKU',
          hint: 'e.g. WM-001',
          prefixIcon: Icons.qr_code_outlined,
          validator: ProductFormValidators.sku,
        ),
      ),
    );
    final Widget inventorySection = _FormSection(
      icon: Icons.analytics_rounded,
      iconColor: context.inventoryTheme.warning,
      title: 'Price and stock',
      description: 'Set the selling price and currently available quantity.',
      child: _ResponsiveFieldPair(
        first: ProductTextFormField(
          controller: _priceController,
          label: 'Price',
          hint: '0.00',
          prefixIcon: Icons.currency_rupee,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
    );
    final Widget imageSection = _FormSection(
      icon: Icons.image_rounded,
      iconColor: context.inventoryTheme.success,
      title: 'Product image',
      description: 'Use a secure HTTPS image URL for a reliable preview.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProductTextFormField(
            controller: _imageUrlController,
            label: 'Image URL',
            hint: 'https://example.com/product.png',
            prefixIcon: Icons.link_rounded,
            textInputAction: TextInputAction.done,
            validator: ProductFormValidators.imageUrl,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.visibility_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Image preview',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
                      borderRadius: const BorderRadius.all(Radius.circular(18)),
                    );
                  },
            ),
          ),
        ],
      ),
    );

    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool useTwoColumns = constraints.maxWidth >= 900;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (useTwoColumns)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          identitySection,
                          const SizedBox(height: 18),
                          classificationSection,
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        children: [
                          inventorySection,
                          const SizedBox(height: 18),
                          imageSection,
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                identitySection,
                const SizedBox(height: 18),
                classificationSection,
                const SizedBox(height: 18),
                inventorySection,
                const SizedBox(height: 18),
                imageSection,
              ],
              const SizedBox(height: 22),
              Align(
                alignment: useTwoColumns
                    ? Alignment.centerRight
                    : Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: useTwoColumns ? 260 : constraints.maxWidth,
                  ),
                  child: FilledButton.icon(
                    key: const Key('product-form-submit'),
                    onPressed: widget.isSubmitting ? null : _submit,
                    icon: widget.isSubmitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            _isEditing
                                ? Icons.check_rounded
                                : Icons.add_rounded,
                          ),
                    label: Text(
                      widget.isSubmitting
                          ? 'Saving…'
                          : widget.submitLabel ??
                                (_isEditing ? 'Save changes' : 'Add product'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.inventoryTheme.subtleBorder),
        boxShadow: context.inventoryTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox.square(
                    dimension: 38,
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.68,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _CategoryDropdownField extends StatefulWidget {
  const _CategoryDropdownField({
    required this.controller,
    required this.categories,
  });

  final TextEditingController controller;
  final List<String> categories;

  @override
  State<_CategoryDropdownField> createState() => _CategoryDropdownFieldState();
}

class _CategoryDropdownFieldState extends State<_CategoryDropdownField> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    final String currentValue = widget.controller.text.trim();
    final ThemeData theme = Theme.of(context);
    final String displayedValue = currentValue.isEmpty
        ? 'Select category'
        : currentValue;

    return FormField<String>(
      key: const Key('product-category-dropdown'),
      initialValue: widget.categories.contains(currentValue)
          ? currentValue
          : null,
      validator: (_) =>
          ProductFormValidators.category(widget.controller.text.trim()),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (FormFieldState<String> fieldState) {
        _errorText = fieldState.errorText;

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final String? selectedCategory = await _showCategoryMenu(context);
              if (selectedCategory == null) {
                return;
              }
              widget.controller.text = selectedCategory;
              fieldState.didChange(selectedCategory);
              setState(() {});
            },
            child: InputDecorator(
              isEmpty: currentValue.isEmpty,
              decoration: InputDecoration(
                labelText: 'Category',
                prefixIcon: const Icon(Icons.category_outlined),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                errorText: _errorText,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayedValue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: currentValue.isEmpty
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String?> _showCategoryMenu(BuildContext context) {
    final RenderBox fieldBox = context.findRenderObject()! as RenderBox;
    final RenderBox overlayBox =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final Offset fieldOffset = fieldBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    const double menuVerticalGap = 4;
    const double estimatedMenuHeight = 256;
    final double spaceBelow =
        overlayBox.size.height - fieldOffset.dy - fieldBox.size.height;
    final bool openAbove = spaceBelow < estimatedMenuHeight;
    final double menuTop = openAbove
        ? (fieldOffset.dy - estimatedMenuHeight - menuVerticalGap).clamp(
            0,
            overlayBox.size.height,
          )
        : fieldOffset.dy + fieldBox.size.height + menuVerticalGap;
    final double menuBottom = openAbove
        ? overlayBox.size.height - fieldOffset.dy + menuVerticalGap
        : 0;
    final RelativeRect position = RelativeRect.fromLTRB(
      fieldOffset.dx,
      menuTop,
      overlayBox.size.width - fieldOffset.dx - fieldBox.size.width,
      menuBottom,
    );

    return showMenu<String>(
      context: context,
      position: position,
      constraints: BoxConstraints(minWidth: fieldBox.size.width),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      popUpAnimationStyle: AnimationStyle.noAnimation,
      items: widget.categories
          .map(
            (String category) => PopupMenuItem<String>(
              value: category,
              child: Text(
                category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
    );
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
