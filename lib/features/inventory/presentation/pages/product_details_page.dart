import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management_app/app/theme/app_theme.dart';
import 'package:inventory_management_app/app/widgets/inventory_scaffold.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_state.dart';
import 'package:inventory_management_app/features/inventory/presentation/pages/product_form_page.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/delete_product_dialog.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/inventory_feedback.dart';
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
            InventoryFeedback.error(context, message);
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
          child: InventoryScaffold(
            appBar: InventoryAppBar(
              title: 'Product details',
              subtitle: 'Catalog item overview',
              height: 62,
              useGradientBackground: true,
              leading: IconButton(
                tooltip: 'Back',
                onPressed: isDeleting
                    ? null
                    : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              actions: [
                _HeaderActionButton(
                  tooltip: 'Edit product',
                  onPressed: isDeleting ? null : _openEditProduct,
                  icon: Icons.edit_rounded,
                ),
                const SizedBox(width: 8),
                if (isDeleting)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.7,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                else
                  _HeaderActionButton(
                    tooltip: 'Delete product',
                    onPressed: _confirmDeletion,
                    icon: Icons.delete_rounded,
                    isDestructive: true,
                  ),
                const SizedBox(width: 10),
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
    InventoryFeedback.success(context, '${updatedProduct.name} was updated.');
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.isDestructive = false,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isDestructive
            ? const Color(0xFFFFE8EA).withValues(alpha: enabled ? 0.94 : 0.28)
            : Colors.white.withValues(alpha: enabled ? 0.22 : 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: Colors.white.withValues(alpha: enabled ? 0.34 : 0.14),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox.square(
            dimension: 42,
            child: Icon(
              icon,
              size: 20,
              color: isDestructive
                  ? Theme.of(context).colorScheme.error
                  : Colors.white.withValues(alpha: enabled ? 1 : 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductDetailsBody extends StatelessWidget {
  const _ProductDetailsBody({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: ResponsivePagePadding(
          maxWidth: 1120,
          top: 14,
          bottom: 42,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Widget visual = _ProductVisual(product: product);
              final Widget information = _ProductInformation(product: product);

              if (constraints.maxWidth < 820) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [visual, const SizedBox(height: 18), information],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 10, child: visual),
                  const SizedBox(width: 24),
                  Expanded(flex: 9, child: information),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProductVisual extends StatelessWidget {
  const _ProductVisual({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.inventoryTheme.subtleBorder),
        boxShadow: context.inventoryTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 11,
              child: Hero(
                tag: 'product-image-${product.id}',
                child: ProductImage(
                  product: product,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  borderRadius: const BorderRadius.all(Radius.circular(18)),
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 10,
              child: _AvailabilityBadge(isInStock: product.isInStock),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductInformation extends StatelessWidget {
  const _ProductInformation({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                colors.secondaryContainer,
                Colors.white.withValues(alpha: 0.82),
              ],
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: context.inventoryTheme.subtleBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            child: Text(
              product.category,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '₹${product.price.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 18),
        _SectionCard(
          icon: Icons.notes_rounded,
          title: 'About this product',
          accent: colors.primary,
          child: Text(
            product.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.78),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Widget skuTile = _InfoTile(
              icon: Icons.qr_code_2_rounded,
              label: 'SKU',
              value: product.sku,
              accent: colors.primary,
              surfaceColor: colors.primaryContainer.withValues(alpha: 0.16),
            );
            final Widget stockTile = _InfoTile(
              icon: Icons.inventory_rounded,
              label: 'Stock quantity',
              value: '${product.stockQuantity}',
              accent: context.inventoryTheme.warning,
              surfaceColor: context.inventoryTheme.warning.withValues(
                alpha: 0.1,
              ),
            );
            final Color availabilityColor = product.isInStock
                ? context.inventoryTheme.success
                : colors.error;

            if (constraints.maxWidth < 600) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: SizedBox(height: 122, child: skuTile)),
                      const SizedBox(width: 10),
                      Expanded(child: SizedBox(height: 122, child: stockTile)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _InfoTile(
                    icon: product.isInStock
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    label: 'Availability',
                    value: product.isInStock ? 'In stock' : 'Out of stock',
                    accent: availabilityColor,
                    surfaceColor: availabilityColor.withValues(alpha: 0.1),
                    horizontal: true,
                  ),
                ],
              );
            }

            final List<Widget> tiles = [
              skuTile,
              stockTile,
              _InfoTile(
                icon: product.isInStock
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                label: 'Availability',
                value: product.isInStock ? 'In stock' : 'Out of stock',
                accent: availabilityColor,
                surfaceColor: availabilityColor.withValues(alpha: 0.1),
              ),
            ];

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int index = 0; index < tiles.length; index++) ...[
                  Expanded(child: tiles[index]),
                  if (index != tiles.length - 1) const SizedBox(width: 10),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Colors.white, accent.withValues(alpha: 0.025)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.inventoryTheme.subtleBorder),
        boxShadow: context.inventoryTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox.square(
                    dimension: 30,
                    child: Icon(icon, color: accent, size: 18),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.surfaceColor,
    this.horizontal = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final Color surfaceColor;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Colors.white, surfaceColor],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: horizontal
            ? Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SizedBox.square(
                      dimension: 38,
                      child: Icon(icon, color: accent, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: textTheme.labelSmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelLarge?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox.square(
                      dimension: 30,
                      child: Icon(icon, color: accent, size: 18),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.isInStock});

  final bool isInStock;

  @override
  Widget build(BuildContext context) {
    final Color color = isInStock
        ? context.inventoryTheme.success
        : Theme.of(context).colorScheme.error;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x1A17203D), blurRadius: 12),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
            Text(
              isInStock ? 'Available' : 'Out of stock',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
