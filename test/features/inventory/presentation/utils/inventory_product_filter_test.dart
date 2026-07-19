import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/presentation/utils/inventory_product_filter.dart';

void main() {
  const Product mouse = Product(
    id: '1',
    name: 'Wireless Mouse',
    description: 'Ergonomic wireless mouse',
    category: 'Electronics',
    price: 799,
    stockQuantity: 25,
    sku: 'WM-001',
    imageUrl: 'https://cdn.example.com/mouse.png',
  );
  const Product keyboard = Product(
    id: '2',
    name: 'Mechanical Keyboard',
    description: 'RGB mechanical keyboard',
    category: 'Electronics',
    price: 2499,
    stockQuantity: 12,
    sku: 'KB-002',
    imageUrl: 'https://cdn.example.com/keyboard.png',
  );
  const Product hub = Product(
    id: '3',
    name: 'USB-C Hub',
    description: '6-in-1 adapter',
    category: 'Accessories',
    price: 1499,
    stockQuantity: 18,
    sku: 'HUB-003',
    imageUrl: 'https://cdn.example.com/hub.png',
  );
  const List<Product> products = <Product>[mouse, keyboard, hub];

  group('InventoryProductFilter', () {
    test('searches case-insensitively across important product fields', () {
      expect(
        InventoryProductFilter.apply(products: products, query: 'wireLESS'),
        <Product>[mouse],
      );
      expect(
        InventoryProductFilter.apply(products: products, query: 'KB-002'),
        <Product>[keyboard],
      );
      expect(
        InventoryProductFilter.apply(products: products, query: 'adapter'),
        <Product>[hub],
      );
    });

    test('filters categories case-insensitively', () {
      expect(
        InventoryProductFilter.apply(
          products: products,
          category: ' electronics ',
        ),
        <Product>[mouse, keyboard],
      );
    });

    test('combines search and category with AND behavior', () {
      expect(
        InventoryProductFilter.apply(
          products: products,
          query: 'keyboard',
          category: 'Electronics',
        ),
        <Product>[keyboard],
      );
      expect(
        InventoryProductFilter.apply(
          products: products,
          query: 'mouse',
          category: 'Accessories',
        ),
        isEmpty,
      );
    });

    test('returns sorted unique category labels', () {
      final Product duplicateCase = Product(
        id: '4',
        name: 'Monitor',
        description: 'Display',
        category: 'electronics',
        price: 10000,
        stockQuantity: 1,
        sku: 'MON-004',
        imageUrl: 'https://cdn.example.com/monitor.png',
      );

      expect(
        InventoryProductFilter.categories(<Product>[
          ...products,
          duplicateCase,
        ]),
        <String>['Accessories', 'Electronics'],
      );
    });

    test('returns an unmodifiable result', () {
      final List<Product> result = InventoryProductFilter.apply(
        products: products,
      );

      expect(() => result.add(mouse), throwsUnsupportedError);
    });
  });
}
