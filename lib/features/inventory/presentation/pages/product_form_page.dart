import 'package:flutter/material.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/product_form.dart';

class ProductFormPage extends StatelessWidget {
  const ProductFormPage({
    required this.onSubmit,
    this.initialProduct,
    super.key,
  });

  final Product? initialProduct;
  final ValueChanged<Product> onSubmit;

  bool get _isEditing => initialProduct != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit product' : 'Add product')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ProductForm(
                initialProduct: initialProduct,
                onSubmit: onSubmit,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
