import 'package:flutter/material.dart';
import 'package:inventory_management_app/app/theme/app_theme.dart';

class InventoryFilterBar extends StatelessWidget {
  const InventoryFilterBar({
    required this.searchController,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onReset,
    super.key,
  });

  static const String _allCategoriesValue = '';

  final TextEditingController searchController;
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final List<String> availableCategories = <String>[...categories];
    final String currentCategory = selectedCategory?.trim() ?? '';
    if (currentCategory.isNotEmpty &&
        !availableCategories.contains(currentCategory)) {
      availableCategories.add(currentCategory);
      availableCategories.sort(
        (String first, String second) =>
            first.toLowerCase().compareTo(second.toLowerCase()),
      );
    }
    final bool hasActiveFilters =
        searchController.text.trim().isNotEmpty || currentCategory.isNotEmpty;

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 5),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.inventoryTheme.subtleBorder),
                boxShadow: context.inventoryTheme.softShadow,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool useCompactLayout = constraints.maxWidth < 600;
                    final Widget search = TextField(
                      key: const Key('inventory-search-field'),
                      controller: searchController,
                      textInputAction: TextInputAction.search,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Search products',
                        hintText: 'Search prod...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, size: 22),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 42,
                          minHeight: 42,
                        ),
                        suffixIcon: searchController.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                onPressed: searchController.clear,
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                    );
                    final Widget category = _CategoryPopupField(
                      fieldKey: const Key('inventory-category-filter'),
                      label: useCompactLayout ? 'All' : 'All categories',
                      value: currentCategory,
                      categories: availableCategories,
                      useCompactLayout: useCompactLayout,
                      onChanged: onCategoryChanged,
                    );
                    final Widget resetAction = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          key: const Key('inventory-reset-filters'),
                          tooltip: 'Reset filters',
                          onPressed: hasActiveFilters ? onReset : null,
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.restart_alt_rounded, size: 18),
                        ),
                      ],
                    );

                    if (useCompactLayout) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: search),
                              const SizedBox(width: 8),
                              Expanded(flex: 2, child: category),
                              if (hasActiveFilters) ...[
                                const SizedBox(width: 4),
                                resetAction,
                              ],
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 2, child: search),
                        const SizedBox(width: 12),
                        Expanded(child: category),
                        if (hasActiveFilters) ...[
                          const SizedBox(width: 8),
                          resetAction,
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryPopupField extends StatelessWidget {
  const _CategoryPopupField({
    required this.fieldKey,
    required this.label,
    required this.value,
    required this.categories,
    required this.useCompactLayout,
    required this.onChanged,
  });

  final Key fieldKey;
  final String label;
  final String value;
  final List<String> categories;
  final bool useCompactLayout;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String displayedValue = value.isEmpty ? label : value;

    return Material(
      key: fieldKey,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showCategoryMenu(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Category',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            prefixIcon: useCompactLayout
                ? null
                : const Icon(Icons.tune_rounded, size: 20),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 38,
              minHeight: 42,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayedValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCategoryMenu(BuildContext context) async {
    final RenderBox fieldBox = context.findRenderObject()! as RenderBox;
    final RenderBox overlayBox =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final Offset fieldOffset = fieldBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final RelativeRect position = RelativeRect.fromLTRB(
      fieldOffset.dx,
      fieldOffset.dy + fieldBox.size.height + 4,
      overlayBox.size.width - fieldOffset.dx - fieldBox.size.width,
      0,
    );

    final String? selectedValue = await showMenu<String>(
      context: context,
      position: position,
      constraints: BoxConstraints(minWidth: fieldBox.size.width),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: InventoryFilterBar._allCategoriesValue,
          child: Text(label),
        ),
        ...categories.map(
          (String category) => PopupMenuItem<String>(
            value: category,
            child: Text(category, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );

    if (selectedValue == null) {
      return;
    }
    onChanged(
      selectedValue == InventoryFilterBar._allCategoriesValue
          ? null
          : selectedValue,
    );
  }
}
