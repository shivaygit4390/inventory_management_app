import 'package:flutter/material.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';

Future<bool> showDeleteProductDialog(
  BuildContext context, {
  required Product product,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      final ThemeData theme = Theme.of(dialogContext);
      final ColorScheme colors = theme.colorScheme;

      return SafeArea(
        child: Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(
                      dimension: 70,
                      child: Icon(
                        Icons.delete_forever_rounded,
                        color: colors.error,
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Delete product?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '“${product.name}” will be permanently removed from inventory. '
                    'This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          key: const Key('confirm-product-deletion'),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.error,
                            foregroundColor: colors.onError,
                          ),
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          icon: const Icon(Icons.delete_rounded, size: 19),
                          label: const Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  return confirmed ?? false;
}
