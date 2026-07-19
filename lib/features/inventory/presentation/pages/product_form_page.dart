import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management_app/app/widgets/inventory_scaffold.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_state.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/inventory_feedback.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/product_form.dart';

class ProductFormPage extends StatelessWidget {
  const ProductFormPage({this.initialProduct, super.key});

  final Product? initialProduct;

  bool get _isEditing => initialProduct != null;

  InventoryMutationType get _mutationType =>
      _isEditing ? InventoryMutationType.update : InventoryMutationType.create;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InventoryBloc, InventoryState>(
      listenWhen: (InventoryState previous, InventoryState current) {
        return switch (current) {
          InventoryMutationSuccess(:final mutationType) ||
          InventoryMutationFailure(
            :final mutationType,
          ) => mutationType == _mutationType,
          _ => false,
        };
      },
      listener: (BuildContext context, InventoryState state) {
        switch (state) {
          case InventoryMutationSuccess(:final Product product):
            Navigator.of(context).pop<Product>(product);
          case InventoryMutationFailure(:final String message):
            InventoryFeedback.error(context, message);
          default:
            break;
        }
      },
      builder: (BuildContext context, InventoryState state) {
        final bool isSubmitting = switch (state) {
          InventoryMutationInProgress(:final mutationType) =>
            mutationType == _mutationType,
          _ => false,
        };

        return PopScope(
          canPop: !isSubmitting,
          child: InventoryScaffold(
            appBar: InventoryAppBar(
              title: _isEditing ? 'Edit product' : 'Add product',
              subtitle: _isEditing
                  ? 'Refine product information'
                  : 'Enter product information',
              height: 62,
              useGradientBackground: true,
              leading: IconButton(
                tooltip: 'Back',
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
            body: SafeArea(
              top: false,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ResponsivePagePadding(
                  maxWidth: 1120,
                  top: 20,
                  bottom: 42,
                  child: ProductForm(
                    initialProduct: initialProduct,
                    isSubmitting: isSubmitting,
                    onSubmit: (Product product) => _submit(context, product),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submit(BuildContext context, Product product) {
    final InventoryEvent event = _isEditing
        ? InventoryProductUpdateRequested(product)
        : InventoryProductCreationRequested(product);
    context.read<InventoryBloc>().add(event);
  }
}
