import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_state.dart';
import 'package:inventory_management_app/features/inventory/presentation/pages/product_form_page.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/delete_product_dialog.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/product_image.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({required this.product, super.key});

  final Product product;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InventoryBloc, InventoryState>(
      listenWhen: (InventoryState previous, InventoryState current) {
        return switch (current) {
          InventoryMutationSuccess(
            :final Product product,
            mutationType: InventoryMutationType.delete,
          ) =>
            product.id == _product.id,
          InventoryMutationFailure(
            mutationType: InventoryMutationType.delete,
          ) =>
            true,
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
        final bool isDeleting =
            state is InventoryMutationInProgress &&
            state.mutationType == InventoryMutationType.delete;

        return PopScope(
          canPop: !isDeleting,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Product details'),
              actions: [
                IconButton(
                  tooltip: 'Edit product',
                  onPressed: isDeleting ? null : _openEditProduct,
                  icon: const Icon(Icons.edit_outlined),
                ),
                if (isDeleting)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Center(
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  )
                else
                  IconButton(
                    tooltip: 'Delete product',
                    onPressed: _confirmDeletion,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            body: _ProductDetailsBody(product: _product),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeletion() async {
    final bool confirmed = await showDeleteProductDialog(
      context,
      product: _product,
    );
    if (!mounted || !confirmed) {
      return;
    }

    context.read<InventoryBloc>().add(
      InventoryProductDeletionRequested(_product),
    );
  }

  Future<void> _openEditProduct() async {
    final Product? updatedProduct = await Navigator.of(context).push<Product>(
      MaterialPageRoute<Product>(
        builder: (BuildContext context) =>
            ProductFormPage(initialProduct: _product),
      ),
    );
    if (!mounted || updatedProduct == null) {
      return;
    }

    setState(() => _product = updatedProduct);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${updatedProduct.name} was updated.')),
    );
  }
}

class _ProductDetailsBody extends StatelessWidget {
  const _ProductDetailsBody({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Hero(
                    tag: 'product-image-${product.id}',
                    child: ProductImage(
                      product: product,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Chip(label: Text(product.category)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${product.price.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Description',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _DetailRow(label: 'SKU', value: product.sku),
                        const Divider(height: 24),
                        _DetailRow(
                          label: 'Stock quantity',
                          value: '${product.stockQuantity}',
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          label: 'Availability',
                          value: product.isInStock
                              ? 'In stock'
                              : 'Out of stock',
                          valueColor: product.isInStock
                              ? colors.tertiary
                              : colors.error,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(child: Text(label, style: textTheme.bodyMedium)),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: textTheme.bodyLarge?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
