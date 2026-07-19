import 'package:flutter/material.dart';
import 'package:inventory_management_app/core/utils/url_validator.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';

class ProductImage extends StatelessWidget {
  ProductImage({
    required Product product,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    super.key,
  }) : imageUrl = product.imageUrl,
       semanticLabel = product.name;

  const ProductImage.fromUrl({
    required this.imageUrl,
    this.semanticLabel = 'Product image preview',
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
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
        label: 'Image unavailable',
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: ColoredBox(
        color: const Color(0xFFF1F0FF),
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          semanticLabel: semanticLabel,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
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
                  label: 'Loading image',
                );
              },
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stack) {
                return _ProductImagePlaceholder(
                  width: width,
                  height: height,
                  borderRadius: BorderRadius.zero,
                  icon: Icons.broken_image_outlined,
                  label: 'Image unavailable',
                );
              },
        ),
      ),
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  const _ProductImagePlaceholder({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.label,
    this.icon,
    this.progress,
  });

  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final String label;
  final IconData? icon;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Semantics(
      label: label,
      image: true,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFFF0EFFF), Color(0xFFE8F7F6)],
            ),
          ),
          child: SizedBox(
            width: width,
            height: height,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool showLabel =
                    !constraints.hasBoundedHeight ||
                    constraints.maxHeight >= 118;

                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon == null)
                        SizedBox.square(
                          dimension: 34,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 3,
                          ),
                        )
                      else
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.72),
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox.square(
                            dimension: 58,
                            child: Icon(icon, color: colors.primary, size: 29),
                          ),
                        ),
                      if (showLabel) ...[
                        const SizedBox(height: 10),
                        Text(
                          label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
