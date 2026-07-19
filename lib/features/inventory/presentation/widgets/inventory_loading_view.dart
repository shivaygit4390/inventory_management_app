import 'package:flutter/material.dart';
import 'package:inventory_management_app/app/theme/app_theme.dart';

class InventoryLoadingView extends StatelessWidget {
  const InventoryLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Colors.white,
                    Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.inventoryTheme.subtleBorder),
                boxShadow: context.inventoryTheme.softShadow,
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: context.inventoryTheme.accentGradient,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x385254D8),
                            blurRadius: 22,
                            offset: Offset(0, 9),
                          ),
                        ],
                      ),
                      child: const SizedBox.square(
                        dimension: 72,
                        child: Padding(
                          padding: EdgeInsets.all(21),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Loading inventory',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fetching the latest product information…',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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
