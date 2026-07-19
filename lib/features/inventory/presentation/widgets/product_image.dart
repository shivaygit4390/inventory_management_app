import 'package:flutter/material.dart';
import 'package:inventory_management_app/core/utils/url_validator.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';

class ProductImage extends StatelessWidget {
  ProductImage({
    required Product product,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    super.key,
  }) : imageUrl = product.imageUrl,
       semanticLabel = product.name;

  const ProductImage.fromUrl({
    required this.imageUrl,
    this.semanticLabel = 'Product image preview',
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    super.key,
  });

  final String imageUrl;
  final String semanticLabel;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    if (!UrlValidator.isHttps(imageUrl)) {
      return _ProductImagePlaceholder(
        width: width,
        height: height,
        borderRadius: borderRadius,
        icon: Icons.broken_image_outlined,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: semanticLabel,
        gaplessPlayback: true,
        loadingBuilder:
            (
              BuildContext context,
              Widget child,
              ImageChunkEvent? loadingProgress,
            ) {
              if (loadingProgress == null) {
                return child;
              }

              final int? expectedBytes = loadingProgress.expectedTotalBytes;
              final double? progress =
                  expectedBytes == null || expectedBytes <= 0
                  ? null
                  : (loadingProgress.cumulativeBytesLoaded / expectedBytes)
                        .clamp(0.0, 1.0)
                        .toDouble();
              return _ProductImagePlaceholder(
                width: width,
                height: height,
                borderRadius: BorderRadius.zero,
                progress: progress,
              );
            },
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
          return _ProductImagePlaceholder(
            width: width,
            height: height,
            borderRadius: BorderRadius.zero,
            icon: Icons.broken_image_outlined,
          );
        },
      ),
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  const _ProductImagePlaceholder({
    required this.width,
    required this.height,
    required this.borderRadius,
    this.icon,
    this.progress,
  });

  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final IconData? icon;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: borderRadius,
      child: ColoredBox(
        color: colors.surfaceContainerHighest,
        child: SizedBox(
          width: width,
          height: height,
          child: Center(
            child: icon == null
                ? SizedBox.square(
                    dimension: 28,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2.5,
                    ),
                  )
                : Icon(icon, color: colors.onSurfaceVariant, size: 40),
          ),
        ),
      ),
    );
  }
}
