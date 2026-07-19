import 'package:flutter/material.dart';
import 'package:inventory_management_app/app/theme/app_theme.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';

class InventoryOverview extends StatelessWidget {
  const InventoryOverview({required this.products, super.key});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final int stockUnits = products.fold<int>(
      0,
      (int total, Product product) => total + product.stockQuantity,
    );
    final int lowStock = products
        .where(
          (Product product) =>
              product.stockQuantity > 0 && product.stockQuantity <= 5,
        )
        .length;
    final bool useDenseSpacing = MediaQuery.sizeOf(context).height < 500;

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          useDenseSpacing ? 8 : 14,
          16,
          useDenseSpacing ? 8 : 12,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: context.inventoryTheme.heroGradient,
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x305254D8),
                      blurRadius: 28,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      right: -52,
                      top: -76,
                      child: _DecorativeCircle(size: 190),
                    ),
                    const Positioned(
                      right: 122,
                      bottom: -74,
                      child: _DecorativeCircle(size: 126, opacity: 0.07),
                    ),
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            final bool useCompactLayout =
                                constraints.maxWidth < 720;
                            final Widget metrics = _Metrics(
                              productCount: products.length,
                              stockUnits: stockUnits,
                              lowStock: lowStock,
                              compact: useCompactLayout,
                            );

                            return Padding(
                              padding: EdgeInsets.all(
                                useCompactLayout
                                    ? useDenseSpacing
                                          ? 12
                                          : 16
                                    : 24,
                              ),
                              child: useCompactLayout
                                  ? _CompactOverview(
                                      metrics: metrics,
                                      dense: useDenseSpacing,
                                    )
                                  : Row(
                                      children: [
                                        const Expanded(
                                          flex: 4,
                                          child: _Introduction(),
                                        ),
                                        const SizedBox(width: 32),
                                        Expanded(flex: 5, child: metrics),
                                      ],
                                    ),
                            );
                          },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactOverview extends StatelessWidget {
  const _CompactOverview({required this.metrics, required this.dense});

  final Widget metrics;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Inventory overview',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            const _LiveInventoryBadge(compact: true),
          ],
        ),
        if (!dense) ...[
          const SizedBox(height: 3),
          Text(
            'Current catalog and stock summary',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.74),
            ),
          ),
        ],
        SizedBox(height: dense ? 8 : 11),
        metrics,
      ],
    );
  }
}

class _Introduction extends StatelessWidget {
  const _Introduction();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LiveInventoryBadge(),
        const SizedBox(height: 13),
        Text(
          'Inventory overview',
          style: textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          'Review product availability, total stock and items that require attention.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.78),
          ),
        ),
      ],
    );
  }
}

class _LiveInventoryBadge extends StatelessWidget {
  const _LiveInventoryBadge({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 11,
          vertical: compact ? 5 : 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF7FF0C8),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              compact ? 'LIVE' : 'LIVE INVENTORY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({
    required this.productCount,
    required this.stockUnits,
    required this.lowStock,
    required this.compact,
  });

  final int productCount;
  final int stockUnits;
  final int lowStock;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            icon: Icons.grid_view_rounded,
            value: '$productCount',
            label: 'Products',
            accent: const Color(0xFFFFD08A),
            compact: compact,
          ),
        ),
        SizedBox(width: compact ? 6 : 10),
        Expanded(
          child: _MetricTile(
            icon: Icons.layers_rounded,
            value: '$stockUnits',
            label: 'Units',
            accent: const Color(0xFF8DE4DB),
            compact: compact,
          ),
        ),
        SizedBox(width: compact ? 6 : 10),
        Expanded(
          child: _MetricTile(
            icon: Icons.bolt_rounded,
            value: '$lowStock',
            label: 'Low stock',
            accent: const Color(0xFFFF9FA3),
            compact: compact,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    required this.compact,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(compact ? 13 : 18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 7, vertical: 7)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: compact
            ? Row(
                children: [
                  Icon(icon, color: accent, size: 15),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 10,
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
                  Icon(icon, color: accent, size: 19),
                  const SizedBox(height: 9),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, this.opacity = 0.09});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
