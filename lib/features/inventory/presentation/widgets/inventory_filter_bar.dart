import 'package:flutter/material.dart';

class InventoryFilterBar extends StatelessWidget {
  const InventoryFilterBar({
    required this.searchController,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.visibleProductCount,
    required this.totalProductCount,
    super.key,
  });

  static const String _allCategoriesValue = '';

  final TextEditingController searchController;
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final int visibleProductCount;
  final int totalProductCount;

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

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final Widget search = TextField(
                  key: const Key('inventory-search-field'),
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: 'Search products',
                    hintText: 'Name, SKU, description or category',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: searchController.clear,
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                );
                final Widget category = InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.filter_list),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      key: const Key('inventory-category-filter'),
                      value: currentCategory,
                      isExpanded: true,
                      isDense: true,
                      items: <DropdownMenuItem<String>>[
                        const DropdownMenuItem<String>(
                          value: _allCategoriesValue,
                          child: Text('All categories'),
                        ),
                        ...availableCategories.map(
                          (String category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (String? value) => onCategoryChanged(
                        value == _allCategoriesValue ? null : value,
                      ),
                    ),
                  ),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (constraints.maxWidth < 600) ...[
                      search,
                      const SizedBox(height: 12),
                      category,
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: search),
                          const SizedBox(width: 12),
                          Expanded(child: category),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Text(
                      '$visibleProductCount of $totalProductCount products',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
