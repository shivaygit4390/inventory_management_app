import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_state.dart';
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
            final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
              context,
            );
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
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

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit product' : 'Add product'),
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
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
