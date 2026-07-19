import 'package:flutter/material.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    required this.product,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    super.key,
  });

  final Product product;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.asset(
        product.imageUrl,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: product.name,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
          return ColoredBox(
            color: colors.surfaceContainerHighest,
            child: SizedBox(
              width: width,
              height: height,
              child: Icon(
                Icons.inventory_2_outlined,
                color: colors.onSurfaceVariant,
                size: 40,
              ),
            ),
          );
        },
      ),
    );
  }
}
