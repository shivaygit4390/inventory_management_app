import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';

abstract final class InventoryProductFilter {
  static List<Product> apply({
    required Iterable<Product> products,
    String query = '',
    String? category,
  }) {
    final String normalizedQuery = query.trim().toLowerCase();
    final String? normalizedCategory = _normalizeCategory(category);

    return List<Product>.unmodifiable(
      products.where((Product product) {
        final bool matchesCategory =
            normalizedCategory == null ||
            product.category.trim().toLowerCase() == normalizedCategory;
        if (!matchesCategory) {
          return false;
        }

        if (normalizedQuery.isEmpty) {
          return true;
        }

        return <String>[
          product.name,
          product.description,
          product.sku,
          product.category,
        ].any((String value) => value.toLowerCase().contains(normalizedQuery));
      }),
    );
  }

  static List<String> categories(Iterable<Product> products) {
    final Map<String, String> uniqueCategories = <String, String>{};
    for (final Product product in products) {
      final String category = product.category.trim();
      if (category.isNotEmpty) {
        uniqueCategories.putIfAbsent(category.toLowerCase(), () => category);
      }
    }
    final List<String> categories = uniqueCategories.values.toList()
      ..sort(
        (String first, String second) =>
            first.toLowerCase().compareTo(second.toLowerCase()),
      );
    return List<String>.unmodifiable(categories);
  }

  static String? _normalizeCategory(String? category) {
    final String normalizedCategory = category?.trim().toLowerCase() ?? '';
    return normalizedCategory.isEmpty ? null : normalizedCategory;
  }
}
